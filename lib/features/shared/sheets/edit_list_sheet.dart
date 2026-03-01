import 'package:flutter/material.dart';

import '../../../models/list_priority.dart';
import '../../../models/todo_list_item.dart';
import '../../../widgets/chip_toggle.dart';

class EditListSheet extends StatefulWidget {
  const EditListSheet({super.key, required this.existing});

  final TodoListItem existing;

  @override
  State<EditListSheet> createState() => _EditListSheetState();
}

class _EditListSheetState extends State<EditListSheet> {
  late final TextEditingController _title;
  late ListPriority _priority;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing.title);
    _priority = widget.existing.priority;
  }

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
            'Edit List',
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
                    id: widget.existing.id,
                    title: title,
                    isDone: widget.existing.isDone,
                    priority: _priority,
                  ),
                );
              },
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
