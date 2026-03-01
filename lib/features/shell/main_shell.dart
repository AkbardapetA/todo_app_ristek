import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/folder.dart';
import '../../models/list_priority.dart';
import '../../models/profile_data.dart';
import '../../models/todo_list_item.dart';
import '../../widgets/bottom_bar.dart';
import '../../widgets/floating_plus.dart';
import '../folder_detail/folder_detail_page.dart';
import '../home/widgets/add_card.dart';
import '../home/widgets/folder_card.dart';
import '../home/widgets/stat_card.dart';
import '../profile/profile_page.dart';
import '../settings/settings_page.dart';
import '../shared/sheets/folder_create_result.dart';
import '../shared/sheets/new_folder_sheet.dart';
import '../shared/sheets/new_list_sheet.dart';
import '../shared/sheets/pick_folder_sheet.dart';

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
  final ValueChanged<Color> onAccentChanged;
  final ValueChanged<ThemeMode> onModeChanged;

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
    setState(() => folder.lists.insert(0, item));
  }

  void _toggleList(Folder folder, String listId) {
    setState(() {
      final int index = folder.lists.indexWhere((item) => item.id == listId);
      if (index != -1) folder.lists[index].isDone = !folder.lists[index].isDone;
    });
  }

  void _deleteList(Folder folder, String listId) {
    setState(() => folder.lists.removeWhere((item) => item.id == listId));
  }

  void _editList(Folder folder, TodoListItem updated) {
    setState(() {
      final int index = folder.lists.indexWhere(
        (item) => item.id == updated.id,
      );
      if (index != -1) folder.lists[index] = updated;
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
      if (q.isEmpty) return true;
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
                  onPressed: _openSettings,
                ),
                const SizedBox(width: 8),
              ],
            )
          : AppBar(
              title: const Text('Profile'),
              actions: <Widget>[
                TextButton(
                  onPressed: _openSettings,
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
                        child: StatCard(
                          icon: Icons.list_alt_rounded,
                          value: _totalLists.toString(),
                          label: 'TOTAL TASKS',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
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
                        onPressed: _showNewFolderSheet,
                        child: const Text('+ New Folder'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (filteredFolders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _search.trim().isEmpty
                            ? 'No folders yet. Create one to get started.'
                            : 'No folders match your search.',
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
                        return AddCard(
                          title: 'Add List',
                          onTap: _showAddListQuickPick,
                        );
                      }

                      final Folder folder = filteredFolders[idx];
                      return FolderCard(
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
                          if (!mounted) return;
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
      floatingActionButton: FloatingPlus(
        accent: widget.accent,
        onPressed: () {
          if (_tab == 0) {
            _showNewFolderSheet();
          } else {
            _showEditProfileDialog();
          }
        },
      ),
      bottomNavigationBar: BottomBar(
        tab: _tab,
        onChange: (int value) => setState(() => _tab = value),
      ),
    );
  }

  void _openSettings() {
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
  }

  Future<void> _showNewFolderSheet() async {
    final FolderCreateResult? result =
        await showModalBottomSheet<FolderCreateResult>(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (_) => const NewFolderSheet(),
        );
    if (!mounted || result == null) return;
    final String folderName = result.name.trim();
    if (folderName.isEmpty) return;
    _addFolder(folderName, result.icon);
  }

  Future<void> _showAddListQuickPick() async {
    if (_folders.isEmpty) return;

    final Folder? folder = await showModalBottomSheet<Folder>(
      context: context,
      showDragHandle: true,
      builder: (_) => PickFolderSheet(folders: _folders),
    );
    if (!mounted || folder == null) return;

    final TodoListItem? item = await showModalBottomSheet<TodoListItem>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const NewListSheet(),
    );
    if (!mounted || item == null) return;

    _addListToFolder(folder, item);
  }

  Future<void> _showEditProfileDialog() async {
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
      builder: (_) => AlertDialog(
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
      ),
    );

    if (!mounted) {
      name.dispose();
      major.dispose();
      email.dispose();
      return;
    }

    if (saved == true) {
      setState(() {
        _profile.fullName = name.text.trim().isEmpty
            ? _profile.fullName
            : name.text.trim();
        _profile.major = major.text.trim().isEmpty
            ? _profile.major
            : major.text.trim();
        _profile.email = email.text.trim().isEmpty
            ? _profile.email
            : email.text.trim();
      });
    }

    name.dispose();
    major.dispose();
    email.dispose();
  }
}
