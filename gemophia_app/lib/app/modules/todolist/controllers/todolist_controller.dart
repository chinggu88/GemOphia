import 'dart:developer';

import 'package:gemophia_app/app/services/supabase_service.dart';
import 'package:get/get.dart';

class Todo {
  final String id;
  final String title;
  final RxBool isCompleted;

  Todo({required this.id, required this.title, bool isCompleted = false})
    : isCompleted = isCompleted.obs;
}

class TodolistController extends GetxController {
  final _minDate = DateTime(DateTime.now().year, 1, 1).obs;
  DateTime get minDate => _minDate.value;
  set minDate(DateTime value) => _minDate.value = value;

  final _maxDate = DateTime(DateTime.now().year, 12, 31).obs;
  DateTime get maxDate => _maxDate.value;
  set maxDate(DateTime value) => _maxDate.value = value;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    SupabaseService.to
        .readAll(table: 'todo')
        .then((data) {
          // Handle fetched data
          log('asdf todo data: $data');
        })
        .catchError((error) {
          // Handle error
        });
  }

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

  int get completedCount =>
      todos.where((todo) => todo.isCompleted.value).length;
  int get pendingCount => todos.where((todo) => !todo.isCompleted.value).length;
}
