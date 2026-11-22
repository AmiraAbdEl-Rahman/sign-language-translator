import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/translation_controller.dart';
import '../models/history_entry.dart';
import '../widgets/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<HistoryEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<TranslationController>().history.getAll();
  }

  void _reload() => setState(() => _future = context.read<TranslationController>().history.getAll());

  Future<void> _clear() async {
    final repo = context.read<TranslationController>().history;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('All saved translations will be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear history')),
        ],
      ),
    );
    if (ok == true) {
      await repo.clear();
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HistoryEntry>>(
      future: _future,
      builder: (context, snap) {
        final items = snap.data ?? [];
        return ListView(padding: const EdgeInsets.all(16), children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('History', style: Theme.of(context).textTheme.titleLarge),
            Row(children: [
              IconButton(onPressed: _reload, icon: const Icon(Icons.refresh), tooltip: 'Refresh'),
              TextButton(onPressed: items.isEmpty ? null : _clear, child: const Text('Clear history')),
            ]),
          ]),
          if (items.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No translations yet. Open Translate and start the camera.'))),
          for (final e in items)
            Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.transparent, child: Text(e.label[0], style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.w800))),
                title: Text(e.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(TimeOfDay.fromDateTime(e.createdAt.toLocal()).format(context)),
                trailing: Chip(label: Text('${(e.confidence * 100).round()}%')),
              ),
            ),
        ]);
      },
    );
  }
}
