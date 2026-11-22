import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.navy, AppColors.teal]),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sign_language, size: 96, color: Colors.white),
              SizedBox(height: 16),
              Text('Sign Language\nTranslator',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, height: 1.15)),
              SizedBox(height: 8),
              Text('Speak with your hands. Be heard everywhere.', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 28),
              SizedBox(width: 120, child: LinearProgressIndicator(color: Colors.white, backgroundColor: Colors.white24)),
            ],
          ),
        ),
      ),
    );
  }
}
