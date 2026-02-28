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
                      const SnackBar(content: Text('not implemented yet.')),
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
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    onChanged: (String value) =>
                        setState(() => _search = value),
                    decoration: const InputDecoration(
                      hintText: 'Search folders...',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _StatCard(
                          icon: Icons.list_alt_rounded,
                          value: _totalLists.toString(),
                          label: 'TOTAL TASKS',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle_rounded,
                          value: _completedLists.toString(),
                          label: 'COMPLETED',
                          iconColor: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          'My Folders',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showNewFolderDialog(context),
                        child: const Text('+ New Folder'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.05,
                        ),
                    itemCount: filteredFolders.length + 1,
                    itemBuilder: (BuildContext context, int idx) {
                      if (idx == filteredFolders.length) {
                        return _AddCard(
                          title: 'Add List',
                          onTap: () => _showAddListQuickPick(context),
                        );
                      }

                      final Folder folder = filteredFolders[idx];
                      return _FolderCard(
                        folder: folder,
                        accent: widget.accent,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Folder detail for "${folder.name}" in Part 6.',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
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
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _deleteAllCompletedTasks,
                  child: const Text('Delete Completed Tasks'),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () {
                    if (_folders.isEmpty) {
                      return;
                    }
                    final Folder firstFolder = _folders.first;
                    _editFolder(
                      firstFolder,
                      '${firstFolder.name} (Edited)',
                      firstFolder.icon,
                    );
                  },
                  child: const Text('Edit First Folder (temp)'),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () {
                    if (_folders.isEmpty || _folders.first.lists.isEmpty) {
                      return;
                    }
                    final Folder firstFolder = _folders.first;
                    final TodoListItem firstItem = firstFolder.lists.first;
                    _toggleList(firstFolder, firstItem.id);
                  },
                  child: const Text('Toggle First Task (temp)'),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () {
                    if (_folders.isEmpty || _folders.first.lists.isEmpty) {
                      return;
                    }
                    final Folder firstFolder = _folders.first;
                    final TodoListItem firstItem = firstFolder.lists.first;
                    _editList(
                      firstFolder,
                      TodoListItem(
                        id: firstItem.id,
                        title: '${firstItem.title} (Edited)',
                        isDone: firstItem.isDone,
                        priority: firstItem.priority,
                      ),
                    );
                  },
                  child: const Text('Edit First Task (temp)'),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () {
                    if (_folders.isEmpty || _folders.first.lists.isEmpty) {
                      return;
                    }
                    final Folder firstFolder = _folders.first;
                    final TodoListItem firstItem = firstFolder.lists.first;
                    _deleteList(firstFolder, firstItem.id);
                  },
                  child: const Text('Delete First Task (temp)'),
                ),
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

  Future<void> _showNewFolderDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final String? name = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Folder'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Folder name'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, nameController.text.trim()),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (name == null || name.isEmpty) {
      return;
    }
    _addFolder(name, Icons.folder_rounded);
  }

  Future<void> _showAddListQuickPick(BuildContext context) async {
    if (_folders.isEmpty) {
      return;
    }

    final Folder? folder = await showModalBottomSheet<Folder>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: _folders.length,
          separatorBuilder: (_, index) => const SizedBox(height: 10),
          itemBuilder: (BuildContext context, int index) {
            final Folder item = _folders[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Icon(item.icon)),
                title: Text(item.name),
                subtitle: Text('${item.lists.length} tasks'),
                onTap: () => Navigator.pop(context, item),
              ),
            );
          },
        );
      },
    );

    if (folder == null) {
      return;
    }

    _addListToFolder(
      folder,
      TodoListItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: 'New List',
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              radius: 16,
              backgroundColor: cs.onSurface.withValues(alpha: 0.1),
              child: Icon(
                icon,
                size: 18,
                color: iconColor ?? cs.onSurface.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                color: cs.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  const _FolderCard({
    required this.folder,
    required this.accent,
    required this.onTap,
  });

  final Folder folder;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 16,
                backgroundColor: accent.withValues(alpha: 0.22),
                child: Icon(folder.icon, size: 18, color: accent),
              ),
              const Spacer(),
              Text(
                folder.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${folder.lists.length} tasks',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCard extends StatelessWidget {
  const _AddCard({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cs.onSurface.withValues(alpha: 0.18)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 18,
                backgroundColor: cs.onSurface.withValues(alpha: 0.1),
                child: Icon(
                  Icons.add_rounded,
                  color: cs.onSurface.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
