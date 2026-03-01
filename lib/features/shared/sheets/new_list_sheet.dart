import 'package:flutter/material.dart';

import '../../../models/list_priority.dart';
import '../../../models/todo_list_item.dart';
import '../../../widgets/chip_toggle.dart';

class NewListSheet extends StatefulWidget {
  const NewListSheet({super.key});

  @override
  State<NewListSheet> createState() => _NewListSheetState();
}

class _NewListSheetState extends State<NewListSheet> {
  final TextEditingController _title = TextEditingController();
  ListPriority _priority = ListPriority.normal;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            'New List',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'List title'),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: ChipToggle(
                  text: 'Normal',
                  selected: _priority == ListPriority.normal,
                  onTap: () => setState(() => _priority = ListPriority.normal),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChipToggle(
                  text: 'Priority',
                  selected: _priority == ListPriority.priority,
                  onTap: () =>
                      setState(() => _priority = ListPriority.priority),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                final String title = _title.text.trim();
                if (title.isEmpty) return;
                Navigator.pop(
                  context,
                  TodoListItem(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    title: title,
                    priority: _priority,
                  ),
                );
              },
              child: const Text(
                'Create List',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
