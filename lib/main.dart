import 'dart:math';

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
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => SettingsPage(
                          currentAccent: widget.accent,
                          mode: widget.mode,
                          onAccentChanged: widget.onAccentChanged,
                          onModeChanged: widget.onModeChanged,
                        ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => SettingsPage(
                          currentAccent: widget.accent,
                          mode: widget.mode,
                          onAccentChanged: widget.onAccentChanged,
                          onModeChanged: widget.onModeChanged,
                        ),
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
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => FolderDetailPage(
                                folder: folder,
                                accent: widget.accent,
                                onAddList: (TodoListItem item) =>
                                    _addListToFolder(folder, item),
                                onToggle: (String id) =>
                                    _toggleList(folder, id),
                                onDelete: (String id) =>
                                    _deleteList(folder, id),
                                onEdit: (TodoListItem updated) =>
                                    _editList(folder, updated),
                                onEditFolder:
                                    (String newName, IconData newIcon) =>
                                        _editFolder(folder, newName, newIcon),
                              ),
                            ),
                          );
                          setState(() {});
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            ProfilePage(
              profile: _profile,
              totalDone: _completedLists,
              totalPending: max(_totalLists - _completedLists, 0),
              accent: widget.accent,
              onDeleteCompletedTasks: _deleteAllCompletedTasks,
              onChanged: () => setState(() {}),
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
            _showEditProfileDialog(context);
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

  Future<void> _showEditProfileDialog(BuildContext context) async {
    final TextEditingController name = TextEditingController(
      text: _profile.fullName,
    );
    final TextEditingController major = TextEditingController(
      text: _profile.major,
    );
    final TextEditingController email = TextEditingController(
      text: _profile.email,
    );

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: name,
                decoration: const InputDecoration(hintText: 'Full name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: major,
                decoration: const InputDecoration(hintText: 'Major'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: email,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      setState(() {
        _profile.fullName = name.text.trim().isEmpty
            ? _profile.fullName
            : name.text.trim();
        _profile.major = major.text.trim();
        _profile.email = email.text.trim();
      });
    }

    name.dispose();
    major.dispose();
    email.dispose();
  }
}

class FolderDetailPage extends StatefulWidget {
  const FolderDetailPage({
    super.key,
    required this.folder,
    required this.accent,
    required this.onAddList,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    required this.onEditFolder,
  });

  final Folder folder;
  final Color accent;
  final ValueChanged<TodoListItem> onAddList;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onDelete;
  final ValueChanged<TodoListItem> onEdit;
  final void Function(String newName, IconData newIcon) onEditFolder;

  @override
  State<FolderDetailPage> createState() => _FolderDetailPageState();
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.profile,
    required this.totalDone,
    required this.totalPending,
    required this.accent,
    required this.onDeleteCompletedTasks,
    required this.onChanged,
  });

  final ProfileData profile;
  final int totalDone;
  final int totalPending;
  final Color accent;
  final int Function() onDeleteCompletedTasks;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    String dateFmt(DateTime date) => '${date.month}/${date.day}/${date.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage(profile.avatarUrl),
              ),
              Container(
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: const <BoxShadow>[
                    BoxShadow(blurRadius: 16, color: Color(0x33000000)),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('(feature not implemented).'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            profile.fullName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            profile.major,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.65),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _MiniMetric(value: '$totalDone', label: 'TASKS DONE'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniMetric(value: '$totalPending', label: 'PENDING'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: totalDone == 0
                  ? null
                  : () async {
                      final bool? confirmed = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Finished Tasks'),
                            content: const Text(
                              'This will remove all completed tasks from every folder.',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmed != true || !context.mounted) {
                        return;
                      }
                      final int removed = onDeleteCompletedTasks();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            removed > 0
                                ? '$removed finished task(s) deleted.'
                                : 'No finished tasks to delete.',
                          ),
                        ),
                      );
                    },
              icon: const Icon(Icons.delete_sweep_rounded),
              label: const Text('Delete All Finished Tasks'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          'Personal Info',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final bool saved = await _editPersonalInfo(
                            context,
                            profile,
                          );
                          if (saved) {
                            onChanged();
                          }
                        },
                        icon: Icon(Icons.edit_rounded, size: 16, color: accent),
                        label: Text(
                          'Edit',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.person_rounded,
                    label: 'FULL NAME',
                    value: profile.fullName,
                  ),
                  _InfoRow(
                    icon: Icons.school_rounded,
                    label: 'MAJOR',
                    value: profile.major,
                  ),
                  _InfoRow(
                    icon: Icons.cake_rounded,
                    label: 'DATE OF BIRTH',
                    value: dateFmt(profile.dob),
                  ),
                  _InfoRow(
                    icon: Icons.email_rounded,
                    label: 'EMAIL',
                    value: profile.email,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<bool> _editPersonalInfo(
    BuildContext context,
    ProfileData profile,
  ) async {
    final TextEditingController name = TextEditingController(
      text: profile.fullName,
    );
    final TextEditingController major = TextEditingController(
      text: profile.major,
    );
    final TextEditingController email = TextEditingController(
      text: profile.email,
    );
    DateTime dateOfBirth = profile.dob;

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder:
              (
                BuildContext context,
                void Function(void Function()) setLocalState,
              ) {
                return AlertDialog(
                  title: const Text('Edit Personal Info'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(
                          hintText: 'Full name',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: major,
                        decoration: const InputDecoration(hintText: 'Major'),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: dateOfBirth,
                            firstDate: DateTime(1970),
                            lastDate: DateTime(DateTime.now().year + 1),
                          );
                          if (picked != null) {
                            setLocalState(() => dateOfBirth = picked);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.06),
                          ),
                          child: Text(
                            'DOB: ${dateOfBirth.month}/${dateOfBirth.day}/${dateOfBirth.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: email,
                        decoration: const InputDecoration(hintText: 'Email'),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {
                        profile.fullName = name.text.trim().isEmpty
                            ? profile.fullName
                            : name.text.trim();
                        profile.major = major.text.trim();
                        profile.email = email.text.trim();
                        profile.dob = dateOfBirth;
                        Navigator.pop(context, true);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              },
        );
      },
    );

    name.dispose();
    major.dispose();
    email.dispose();

    return result == true;
  }
}

class _FolderDetailPageState extends State<FolderDetailPage> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    final List<TodoListItem> lists = widget.folder.lists.where((
      TodoListItem item,
    ) {
      final String query = _q.trim().toLowerCase();
      if (query.isEmpty) {
        return true;
      }
      return item.title.toLowerCase().contains(query);
    }).toList();

    lists.sort((TodoListItem a, TodoListItem b) {
      final int aPriorityRank = a.priority == ListPriority.priority ? 0 : 1;
      final int bPriorityRank = b.priority == ListPriority.priority ? 0 : 1;

      if (aPriorityRank != bPriorityRank) {
        return aPriorityRank.compareTo(bPriorityRank);
      }
      if (a.isDone != b.isDone) {
        return a.isDone ? 1 : -1;
      }
      return 0;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
        actions: <Widget>[
          IconButton(
            tooltip: 'Edit Folder',
            icon: const Icon(Icons.edit_rounded),
            onPressed: () async {
              final TextEditingController nameController =
                  TextEditingController(text: widget.folder.name);
              final String? newName = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Edit Folder'),
                    content: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Folder name',
                      ),
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
                        child: const Text('Save'),
                      ),
                    ],
                  );
                },
              );
              nameController.dispose();
              if (newName == null || newName.isEmpty) {
                return;
              }
              widget.onEditFolder(newName, widget.folder.icon);
              setState(() {});
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            children: <Widget>[
              TextField(
                onChanged: (String value) => setState(() => _q = value),
                decoration: const InputDecoration(
                  hintText: 'Search lists...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: lists.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final TodoListItem item = lists[index];
                    final bool isPriority =
                        item.priority == ListPriority.priority;

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        leading: GestureDetector(
                          onTap: () {
                            widget.onToggle(item.id);
                            setState(() {});
                          },
                          child: _CheckDot(
                            checked: item.isDone,
                            accent: widget.accent,
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            decoration: item.isDone
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isDone
                                ? cs.onSurface.withValues(alpha: 0.45)
                                : cs.onSurface,
                          ),
                        ),
                        subtitle: isPriority
                            ? Text(
                                'PRIORITY',
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w800,
                                  color: widget.accent.withValues(alpha: 0.9),
                                ),
                              )
                            : null,
                        trailing: PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_horiz_rounded,
                            color: cs.onSurface.withValues(alpha: 0.8),
                          ),
                          onSelected: (String value) async {
                            if (value == 'edit') {
                              final TodoListItem? updated =
                                  await _showListEditorDialog(existing: item);
                              if (updated == null) {
                                return;
                              }
                              widget.onEdit(updated);
                              setState(() {});
                            }
                            if (value == 'delete') {
                              widget.onDelete(item.id);
                              setState(() {});
                            }
                          },
                          itemBuilder: (_) => const <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () async {
                    final TodoListItem? created = await _showListEditorDialog();
                    if (created == null) {
                      return;
                    }
                    widget.onAddList(created);
                    setState(() {});
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New List'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<TodoListItem?> _showListEditorDialog({TodoListItem? existing}) async {
    final bool isEdit = existing != null;
    final TextEditingController titleController = TextEditingController(
      text: existing?.title ?? '',
    );
    ListPriority selectedPriority = existing?.priority ?? ListPriority.normal;

    final TodoListItem? result = await showDialog<TodoListItem>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder:
              (
                BuildContext context,
                void Function(void Function()) setLocalState,
              ) {
                return AlertDialog(
                  title: Text(isEdit ? 'Edit List' : 'New List'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintText: 'List title',
                        ),
                        autofocus: true,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _PriorityChip(
                              text: 'Normal',
                              selected: selectedPriority == ListPriority.normal,
                              onTap: () => setLocalState(
                                () => selectedPriority = ListPriority.normal,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _PriorityChip(
                              text: 'Priority',
                              selected:
                                  selectedPriority == ListPriority.priority,
                              onTap: () => setLocalState(
                                () => selectedPriority = ListPriority.priority,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {
                        final String title = titleController.text.trim();
                        if (title.isEmpty) {
                          return;
                        }
                        Navigator.pop(
                          context,
                          TodoListItem(
                            id:
                                existing?.id ??
                                DateTime.now().microsecondsSinceEpoch
                                    .toString(),
                            title: title,
                            isDone: existing?.isDone ?? false,
                            priority: selectedPriority,
                          ),
                        );
                      },
                      child: Text(isEdit ? 'Save' : 'Create'),
                    ),
                  ],
                );
              },
        );
      },
    );

    titleController.dispose();
    return result;
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          children: <Widget>[
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w800,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 16,
            backgroundColor: cs.onSurface.withValues(alpha: 0.1),
            child: Icon(
              icon,
              size: 18,
              color: cs.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckDot extends StatelessWidget {
  const _CheckDot({required this.checked, required this.accent});

  final bool checked;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? accent : Colors.transparent,
        border: Border.all(
          width: 1.8,
          color: checked ? accent : cs.onSurface.withValues(alpha: 0.5),
        ),
      ),
      child: checked
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? cs.primary.withValues(alpha: 0.22)
              : cs.onSurface.withValues(alpha: 0.06),
          border: Border.all(
            color: selected
                ? cs.primary.withValues(alpha: 0.7)
                : Colors.transparent,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected ? cs.primary : cs.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.currentAccent,
    required this.mode,
    required this.onAccentChanged,
    required this.onModeChanged,
  });

  final Color currentAccent;
  final ThemeMode mode;
  final ValueChanged<Color> onAccentChanged;
  final ValueChanged<ThemeMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final List<Color> colors = <Color>[
      const Color(0xFF7C4DFF),
      const Color(0xFF2962FF),
      const Color(0xFFD50000),
      const Color(0xFF1E88E5),
      const Color(0xFF00C853),
      const Color(0xFFFF6D00),
      const Color(0xFFE91E63),
    ];

    final bool isDark = mode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: <Widget>[
            Text(
              'APPEARANCE',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: cs.onSurface.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.palette_rounded,
                            size: 18,
                            color: cs.onSurface.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Theme Color',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: colors.map((Color color) {
                        final bool selected =
                            color.toARGB32() == currentAccent.toARGB32();
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () => onAccentChanged(color),
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: cs.onSurface.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.dark_mode_rounded,
                            size: 18,
                            color: cs.onSurface.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Dark Mode',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Switch(
                          value: isDark,
                          onChanged: (bool value) => onModeChanged(
                            value ? ThemeMode.dark : ThemeMode.light,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'GENERAL',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: const <Widget>[
                  _SettingsTile(
                    icon: Icons.notifications_rounded,
                    title: 'Notifications',
                  ),
                  Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.vibration_rounded,
                    title: 'Sounds & Haptics',
                  ),
                  Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.language_rounded,
                    title: 'Language & Region',
                    trailing: 'English (US)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'SUPPORT',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: const <Widget>[
                  _SettingsTile(
                    icon: Icons.help_center_rounded,
                    title: 'Help Center',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, this.trailing});

  final IconData icon;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: cs.onSurface.withValues(alpha: 0.1),
        child: Icon(
          icon,
          size: 18,
          color: cs.onSurface.withValues(alpha: 0.85),
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      trailing: trailing == null
          ? Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurface.withValues(alpha: 0.5),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  trailing!,
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title (feature not implemented).')),
        );
      },
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
