import 'package:flutter/material.dart';

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  Color _accent = const Color(0xFF7C4DFF);
  ThemeMode _mode = ThemeMode.dark;

  void _setAccent(Color color) {
    setState(() => _accent = color);
  }

  void _setMode(ThemeMode mode) {
    setState(() => _mode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final darkScheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.dark,
    );

    final lightScheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.light,
    );

    ThemeData themed(ColorScheme scheme) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surface,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-do app',
      themeMode: _mode,
      theme: themed(lightScheme),
      darkTheme: themed(darkScheme),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('To-do app'),
          actions: [
            IconButton(
              onPressed: () {
                _setMode(
                  _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
                );
              },
              icon: Icon(
                _mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              ),
            ),
          ],
        ),
        body: const Center(child: Text('Commit 1')),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _setAccent(const Color(0xFF2962FF)),
          child: const Icon(Icons.palette),
        ),
      ),
    );
  }
}
