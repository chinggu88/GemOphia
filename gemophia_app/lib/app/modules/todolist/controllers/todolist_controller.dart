import 'package:get/get.dart';

class Todo {
  final String id;
  final String title;
  final RxBool isCompleted;

  Todo({
    required this.id,
    required this.title,
    bool isCompleted = false,
  }) : isCompleted = isCompleted.obs;
}

class TodolistController extends GetxController {
  final todos = <Todo>[].obs;

  void addTodo(String title) {
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
    todos.add(todo);
  }

  void toggleTodo(String id) {
    final index = todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      todos[index].isCompleted.value = !todos[index].isCompleted.value;
      todos.refresh();
    }
  }

  void deleteTodo(String id) {
    todos.removeWhere((todo) => todo.id == id);
  }

  int get completedCount => todos.where((todo) => todo.isCompleted.value).length;
  int get pendingCount => todos.where((todo) => !todo.isCompleted.value).length;
}
