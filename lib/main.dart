import 'package:flutter/material.dart';

void main() => runApp(const TodoApp());

enum ListPriority { normal, priority }

class TodoListItem {
  TodoListItem({
    required this.id,
    required this.title,
    this.isDone = false,
    this.priority = ListPriority.normal,
  });

  final String id;
  String title;
  bool isDone;
  ListPriority priority;
}

class Folder {
  Folder({
    required this.id,
    required this.name,
    required this.icon,
    List<TodoListItem>? lists,
  }) : lists = lists ?? <TodoListItem>[];

  final String id;
  String name;
  IconData icon;
  final List<TodoListItem> lists;

  int get completedCount => lists.where((item) => item.isDone).length;
}

class ProfileData {
  String fullName = 'Andy Akbar';
  String major = 'Information Systems';
  DateTime dob = DateTime(2007, 5, 28);
  String email = 'akbarristek@gmail.com';
  String avatarUrl =
      'https://i.pinimg.com/1200x/2e/3f/92/2e3f92b57d199af8d7777aa067fa448c.jpg';
}

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
      home: MainShell(
        accent: _accent,
        mode: _mode,
        onAccentChanged: _setAccent,
        onModeChanged: _setMode,
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.accent,
    required this.mode,
    required this.onAccentChanged,
    required this.onModeChanged,
  });

  final Color accent;
  final ThemeMode mode;
  final void Function(Color color) onAccentChanged;
  final void Function(ThemeMode mode) onModeChanged;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  String _search = '';

  final ProfileData _profile = ProfileData();

  final List<Folder> _folders = <Folder>[
    Folder(
      id: 'f1',
      name: 'College',
      icon: Icons.school_rounded,
      lists: <TodoListItem>[
        TodoListItem(
          id: 'l1',
          title: 'TP2 DDP',
          priority: ListPriority.priority,
        ),
        TodoListItem(id: 'l2', title: 'Meeting Menpes', isDone: true),
      ],
    ),
    Folder(
      id: 'f2',
      name: 'Personal',
      icon: Icons.person_rounded,
      lists: <TodoListItem>[
        TodoListItem(id: 'l3', title: 'Beli Aina buat sahur'),
      ],
    ),
    Folder(id: 'f3', name: 'Fitness', icon: Icons.fitness_center_rounded),
  ];

  int get _totalLists =>
      _folders.fold<int>(0, (sum, folder) => sum + folder.lists.length);
  int get _completedLists =>
      _folders.fold<int>(0, (sum, folder) => sum + folder.completedCount);

  void _addFolder(String name, IconData icon) {
    setState(() {
      _folders.insert(
        0,
        Folder(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: name,
          icon: icon,
        ),
      );
    });
  }

  void _editFolder(Folder folder, String newName, IconData newIcon) {
    setState(() {
      folder.name = newName;
      folder.icon = newIcon;
    });
  }

  void _addListToFolder(Folder folder, TodoListItem item) {
    setState(() {
      folder.lists.insert(0, item);
    });
  }

  void _toggleList(Folder folder, String listId) {
    setState(() {
      final int index = folder.lists.indexWhere((item) => item.id == listId);
      if (index != -1) {
        folder.lists[index].isDone = !folder.lists[index].isDone;
      }
    });
  }

  void _deleteList(Folder folder, String listId) {
    setState(() {
      folder.lists.removeWhere((item) => item.id == listId);
    });
  }

  void _editList(Folder folder, TodoListItem updated) {
    setState(() {
      final int index = folder.lists.indexWhere(
        (item) => item.id == updated.id,
      );
      if (index != -1) {
        folder.lists[index] = updated;
      }
    });
  }

  int _deleteAllCompletedTasks() {
    int removed = 0;
    setState(() {
      for (final Folder folder in _folders) {
        final int before = folder.lists.length;
        folder.lists.removeWhere((item) => item.isDone);
        removed += before - folder.lists.length;
      }
    });
    return removed;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final List<Folder> filteredFolders = _folders.where((folder) {
      final String q = _search.trim().toLowerCase();
      if (q.isEmpty) {
        return true;
      }
      return folder.name.toLowerCase().contains(q) ||
          folder.lists.any((item) => item.title.toLowerCase().contains(q));
    }).toList();

    final Folder? firstFolder = _folders.isNotEmpty ? _folders.first : null;
    final TodoListItem? firstTask =
        firstFolder != null && firstFolder.lists.isNotEmpty
        ? firstFolder.lists.first
        : null;

    return Scaffold(
      appBar: _tab == 0
          ? AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Good Morning,'),
                  Text(
                    _profile.fullName.split(' ').first,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                IconButton(
                  tooltip: 'Settings',
                  icon: const Icon(Icons.settings_rounded),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('not implemented yet.'),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            )
          : AppBar(
              title: const Text('Profile'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings screen in Part 8.'),
                      ),
                    );
                  },
                  child: const Text('Settings'),
                ),
                const SizedBox(width: 8),
              ],
            ),
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: <Widget>[
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: <Widget>[
                TextField(
                  onChanged: (String value) => setState(() => _search = value),
                  decoration: const InputDecoration(
                    hintText: 'Search folders or tasks...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Folders (filtered): ${filteredFolders.length}'),
                Text('Total tasks: $_totalLists'),
                Text('Completed tasks: $_completedLists'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    FilledButton(
                      onPressed: () =>
                          _addFolder('New Folder', Icons.folder_rounded),
                      child: const Text('Add Folder'),
                    ),
                    FilledButton(
                      onPressed: firstFolder == null
                          ? null
                          : () => _editFolder(
                              firstFolder,
                              '${firstFolder.name} (Edited)',
                              Icons.work_rounded,
                            ),
                      child: const Text('Edit First Folder'),
                    ),
                    FilledButton(
                      onPressed: firstFolder == null
                          ? null
                          : () => _addListToFolder(
                              firstFolder,
                              TodoListItem(
                                id: DateTime.now().microsecondsSinceEpoch
                                    .toString(),
                                title: 'New Task',
                              ),
                            ),
                      child: const Text('Add Task'),
                    ),
                    FilledButton(
                      onPressed: firstFolder == null || firstTask == null
                          ? null
                          : () => _toggleList(firstFolder, firstTask.id),
                      child: const Text('Toggle First Task'),
                    ),
                    FilledButton(
                      onPressed: firstFolder == null || firstTask == null
                          ? null
                          : () => _editList(
                              firstFolder,
                              TodoListItem(
                                id: firstTask.id,
                                title: '${firstTask.title} (Edited)',
                                isDone: firstTask.isDone,
                                priority: ListPriority.priority,
                              ),
                            ),
                      child: const Text('Edit First Task'),
                    ),
                    FilledButton(
                      onPressed: firstFolder == null || firstTask == null
                          ? null
                          : () => _deleteList(firstFolder, firstTask.id),
                      child: const Text('Delete First Task'),
                    ),
                    FilledButton(
                      onPressed: _deleteAllCompletedTasks,
                      child: const Text('Delete Completed'),
                    ),
                  ],
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: <Widget>[
                Text('Name: ${_profile.fullName}'),
                Text('Major: ${_profile.major}'),
                Text(
                  'DOB: ${_profile.dob.month}/${_profile.dob.day}/${_profile.dob.year}',
                ),
                Text('Email: ${_profile.email}'),
              ],
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _FloatingPlus(
        accent: widget.accent,
        onPressed: () {
          if (_tab == 0) {
            _addFolder('Quick Folder', Icons.folder_copy_rounded);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit profile flow in Part 7.')),
            );
          }
        },
      ),
      bottomNavigationBar: _BottomBar(
        tab: _tab,
        onChange: (int value) => setState(() => _tab = value),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.tab, required this.onChange});

  final int tab;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: onChange,
      destinations: const <NavigationDestination>[
        NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
        NavigationDestination(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _FloatingPlus extends StatelessWidget {
  const _FloatingPlus({required this.accent, required this.onPressed});

  final Color accent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: accent,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }
}
