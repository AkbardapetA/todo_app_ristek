import 'list_priority.dart';

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
