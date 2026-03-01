import 'package:flutter/material.dart';

import 'todo_list_item.dart';

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
