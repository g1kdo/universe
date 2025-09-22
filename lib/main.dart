import 'package:firebase_core/firebase_core.dart';
import 'package:universe/providers/theme.dart';
import 'package:universe/ui/screens/welcome_screen.dart';
import 'package:universe/ui/screens/authentication/login_screen.dart';
import 'package:universe/ui/screens/authentication/signup_screen.dart';
import 'package:universe/ui/screens/home_screen.dart';
import 'package:universe/ui/screens/settings_screen.dart';
import 'package:universe/ui/screens/achievements_screen.dart';
import 'package:universe/ui/screens/privacy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: const UniVerseApp()));
}

class UniVerseApp extends ConsumerWidget {
  const UniVerseApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    var theme = ref.watch(themeProvider);
    return MaterialApp(
      title: 'UniVerse',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: theme,
      home: const WelcomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/achievements': (context) => const AchievementsScreen(),
        '/privacy': (context) => const PrivacyScreen(),
      },
    );
  }
}
