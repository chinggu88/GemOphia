import 'dart:developer';

import 'package:gemophia_app/app/data/models/todo_model.dart';
import 'package:gemophia_app/app/services/supabase_service.dart';
import 'package:get/get.dart';



class TodolistController extends GetxController {
  final _minDate = DateTime(DateTime.now().year, 1, 1).obs;
  DateTime get minDate => _minDate.value;
  set minDate(DateTime value) => _minDate.value = value;

  final _maxDate = DateTime(DateTime.now().year, 12, 31).obs;
  DateTime get maxDate => _maxDate.value;
  set maxDate(DateTime value) => _maxDate.value = value;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();

    final temptodo = await SupabaseService.to
        .readAll(table: 'todo');
    todos = temptodo.map((e) => Todo.fromJson(e)).toList();
    log('asdf todos length: ${todos.length}');
        
  }

  final _todos = <Todo>[].obs;
  set todos(List<Todo> value) => _todos.value = value;
  List<Todo> get todos => _todos.toList();




  void toggleTodo(String id) {
    final index = todos.indexWhere((todo) => todo.id == id);
    // if (index != -1) {
    //   todos[index].isCompleted = !todos[index].isCompleted;
      
    // }
  }

  void deleteTodo(String id) {
    todos.removeWhere((todo) => todo.id == id);
  }

}
