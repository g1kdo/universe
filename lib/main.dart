import 'package:universe/providers/theme.dart';
import 'package:universe/ui/screens/welcome_screen.dart'; // Import the new welcome screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
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
    );
  }
}
