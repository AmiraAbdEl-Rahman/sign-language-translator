import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/translation_controller.dart';
import '../models/sign.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});
  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  Future<List<Sign>>? _future;
  String _query = '';
  String _category = 'All';

  @override
  void initState() {
    super.initState();
    _future = context.read<TranslationController>().api.getSigns();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Sign>>(
      future: _future,
      builder: (context, snap) {
        final all = snap.data ?? Sign.fallback;
        final cats = ['All', ...{for (final s in all) s.category}];
        final shown = all
            .where((s) => (_category == 'All' || s.category == _category) && s.labelEn.toLowerCase().contains(_query.toLowerCase()))
            .toList();
        return ListView(padding: const EdgeInsets.all(16), children: [
          Text('Vocabulary', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search signs', border: OutlineInputBorder()),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: [
            for (final c in cats) ChoiceChip(label: Text(c), selected: c == _category, onSelected: (_) => setState(() => _category = c)),
          ]),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.3,
            children: [
              for (final s in shown)
                Card(
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(s.labelEn, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(s.labelAr, style: const TextStyle(fontSize: 14)),
                      Text(s.category, style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  ),
                ),
            ],
          ),
        ]);
      },
    );
  }
}
