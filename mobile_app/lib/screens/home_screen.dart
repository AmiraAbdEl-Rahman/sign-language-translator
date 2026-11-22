import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int tab) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Welcome', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              SizedBox(height: 4),
              Text('Translate sign language into text and voice.'),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: AppColors.teal,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => onNavigate(1),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Column(children: [
                CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.videocam, color: AppColors.teal, size: 32)),
                SizedBox(height: 10),
                Text('Start translating', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                Text('Opens the camera', style: TextStyle(color: Colors.white70)),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          _tile(context, Icons.history, 'History', 2),
          _tile(context, Icons.menu_book, 'Vocabulary', 3),
          _tile(context, Icons.settings, 'Settings', 4),
        ]),
      ],
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, int tab) => Expanded(
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onNavigate(tab),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(children: [Icon(icon, color: AppColors.teal), const SizedBox(height: 6), Text(label)]),
            ),
          ),
        ),
      );
}
