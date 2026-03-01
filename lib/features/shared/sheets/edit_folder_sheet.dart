import 'package:flutter/material.dart';

import 'folder_create_result.dart';

class EditFolderSheet extends StatefulWidget {
  const EditFolderSheet({
    super.key,
    required this.initialName,
    required this.initialIcon,
  });

  final String initialName;
  final IconData initialIcon;

  @override
  State<EditFolderSheet> createState() => _EditFolderSheetState();
}

class _EditFolderSheetState extends State<EditFolderSheet> {
  late final TextEditingController _name;
  late IconData _icon;

  final List<IconData> _icons = const <IconData>[
    Icons.school_rounded,
    Icons.person_rounded,
    Icons.fitness_center_rounded,
    Icons.work_rounded,
    Icons.favorite_rounded,
    Icons.folder_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
    _icon = widget.initialIcon;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        6,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Edit Folder',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Folder name'),
          ),
          const SizedBox(height: 12),
          Text(
            'Icon',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.w900,
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: _icons.map((IconData icon) {
              final bool selected = icon == _icon;
              return InkWell(
                onTap: () => setState(() => _icon = icon),
                borderRadius: BorderRadius.circular(999),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: selected
                      ? cs.primary.withValues(alpha: 0.25)
                      : cs.onSurface.withValues(alpha: 0.08),
                  child: Icon(
                    icon,
                    size: 18,
                    color: selected
                        ? cs.primary
                        : cs.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                final String name = _name.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(context, FolderCreateResult(name, _icon));
              },
              child: const Text(
                'Save Changes',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
