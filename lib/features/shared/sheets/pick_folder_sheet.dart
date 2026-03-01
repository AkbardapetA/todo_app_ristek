import 'package:flutter/material.dart';

import '../../../models/folder.dart';

class PickFolderSheet extends StatelessWidget {
  const PickFolderSheet({super.key, required this.folders});

  final List<Folder> folders;

  @override
  Widget build(BuildContext context) {
    if (folders.isEmpty) {
      return const Center(child: Text('No folders available.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: folders.length,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final Folder folder = folders[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              child: Icon(folder.icon, size: 18),
            ),
            title: Text(
              folder.name,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text('${folder.lists.length} tasks'),
            onTap: () => Navigator.pop(context, folder),
          ),
        );
      },
    );
  }
}
