import 'package:flutter/material.dart';

import 'models/tournament.dart';
import 'routes.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/shell_screen.dart';

void main() => runApp(const MyApp());

/// Stateful because the theme mode lives here, above MaterialApp.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  // The only colour literal in lib/: the seed the whole palette grows from.
  static const _seed = Colors.deepOrange;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'CS2 Cups',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: _seed)),
    darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.dark,
      ),
    ),
    themeMode: _themeMode,
    initialRoute: Routes.shell,
    routes: {
      Routes.shell: (_) => ShellScreen(
        themeMode: _themeMode,
        onThemeModeChanged: (m) => setState(() => _themeMode = m),
      ),
    },
    // Typed argument classes: the pattern checks the type, no `as` cast.
    onGenerateRoute: (settings) =>
        switch ((settings.name, settings.arguments)) {
          (Routes.detail, DetailArgs args) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => DetailScreen(args: args),
          ),
          (Routes.form, FormArgs args) => MaterialPageRoute<Tournament>(
            settings: settings,
            builder: (_) => FormScreen(args: args),
          ),
          _ => null,
        },
    onUnknownRoute: (settings) => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const NotFoundScreen(),
    ),
  );
}
