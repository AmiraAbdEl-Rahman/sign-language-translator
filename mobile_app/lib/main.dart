import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/settings_controller.dart';
import 'controllers/translation_controller.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/translate_screen.dart';
import 'screens/vocabulary_screen.dart';
import 'widgets/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = SettingsController();
  await settings.load();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider(create: (_) => TranslationController(settings)),
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.select<SettingsController, bool>((s) => s.darkMode);
    return MaterialApp(
      title: 'Sign Language Translator',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(false),
      darkTheme: buildTheme(true),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: const _Root(),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();
  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool _showSplash = true;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) return const SplashScreen();
    const titles = ['Sign Language Translator', 'Translation', 'History', 'Vocabulary', 'Settings'];
    return Scaffold(
      appBar: AppBar(title: Text(titles[_tab])),
      body: IndexedStack(index: _tab, children: [
        HomeScreen(onNavigate: _go),
        const TranslateScreen(),
        if (_tab == 2) const HistoryScreen() else const SizedBox.shrink(),
        const VocabularyScreen(),
        const SettingsScreen(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.videocam_outlined), selectedIcon: Icon(Icons.videocam), label: 'Translate'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Vocabulary'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  void _go(int i) {
    if (i != 1) context.read<TranslationController>().stop();
    setState(() => _tab = i);
  }
}
