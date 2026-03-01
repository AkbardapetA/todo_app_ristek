import 'package:flutter/material.dart';

import '../../models/folder.dart';
import '../../models/list_priority.dart';
import '../../models/todo_list_item.dart';
import '../shared/sheets/edit_folder_sheet.dart';
import '../shared/sheets/edit_list_sheet.dart';
import '../shared/sheets/folder_create_result.dart';
import '../shared/sheets/new_list_sheet.dart';
import 'widgets/check_dot.dart';

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
              final FolderCreateResult? result =
                  await showModalBottomSheet<FolderCreateResult>(
                    context: context,
                    showDragHandle: true,
                    isScrollControlled: true,
                    builder: (_) => EditFolderSheet(
                      initialName: widget.folder.name,
                      initialIcon: widget.folder.icon,
                    ),
                  );
              if (!mounted || result == null) return;
              final String newName = result.name.trim();
              if (newName.isEmpty) return;
              widget.onEditFolder(newName, result.icon);
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
                child: lists.isEmpty
                    ? Center(
                        child: Text(
                          _q.trim().isEmpty
                              ? 'No lists yet. Tap "New List" to start.'
                              : 'No lists match your search.',
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: lists.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 10),
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
                                child: CheckDot(
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
                                        color: widget.accent.withValues(
                                          alpha: 0.9,
                                        ),
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
                                        await showModalBottomSheet<
                                          TodoListItem
                                        >(
                                          context: context,
                                          showDragHandle: true,
                                          isScrollControlled: true,
                                          builder: (_) =>
                                              EditListSheet(existing: item),
                                        );
                                    if (!mounted || updated == null) return;
                                    widget.onEdit(updated);
                                    setState(() {});
                                  }
                                  if (value == 'delete') {
                                    widget.onDelete(item.id);
                                    setState(() {});
                                  }
                                },
                                itemBuilder: (_) =>
                                    const <PopupMenuEntry<String>>[
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
                    final TodoListItem? created =
                        await showModalBottomSheet<TodoListItem>(
                          context: context,
                          showDragHandle: true,
                          isScrollControlled: true,
                          builder: (_) => const NewListSheet(),
                        );
                    if (!mounted || created == null) return;
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
}
