import 'dart:developer';

import 'package:contribution_heatmap/contribution_heatmap.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/todolist_controller.dart';

class TodolistView extends GetView<TodolistController> {
  const TodolistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            // _buildStats(context),
            // Expanded(child: _buildTodoList(context)),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _showAddTodoDialog(context),
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  Obx _buildHeader(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ContributionHeatmap(
        startWeekday: DateTime.monday,
        cellRadius: 5,
        minDate: controller.minDate, // Start date: March 1, 2025
        maxDate: controller.maxDate, // End date: Today
        cellSize: 19,
        splittedMonthView: false, // Visual separation between months
        showCellDate: false,
        entries: [
          ...controller.todos.map((todo) {
            log('asdf todo data: ${todo.toJson()}');
            return ContributionEntry(
              todo.createdAt!,
              todo.cnt!,
            );
          }),
        ],
        showMonthLabels: true,
      ),
    );
    },);
  }

  // Widget _buildStats(BuildContext context) {
  //   return Obx(
  //     () => Container(
  //       margin: const EdgeInsets.symmetric(horizontal: 16),
  //       padding: const EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         color: Theme.of(context).primaryColor.withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: [
  //           _buildStatItem(
  //             context,
  //             '전체',
  //             controller.todos.length.toString(),
  //             Icons.list,
  //           ),
  //           _buildStatItem(
  //             context,
  //             '완료',
  //             controller.completedCount.toString(),
  //             Icons.check_circle,
  //           ),
  //           _buildStatItem(
  //             context,
  //             '미완료',
  //             controller.pendingCount.toString(),
  //             Icons.pending,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  // Widget _buildTodoList(BuildContext context) {
  //   return Obx(() {
  //     if (controller.todos.isEmpty) {
  //       return Center(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
  //             const SizedBox(height: 16),
  //             Text(
  //               '할 일이 없습니다',
  //               style: TextStyle(fontSize: 16, color: Colors.grey[600]),
  //             ),
  //           ],
  //         ),
  //       );
  //     }

  //     return ListView.builder(
  //       padding: const EdgeInsets.all(16),
  //       itemCount: controller.todos.length,
  //       itemBuilder: (context, index) {
  //         final todo = controller.todos[index];
  //         return Obx(
  //           () => Card(
  //             margin: const EdgeInsets.only(bottom: 8),
  //             child: ListTile(
  //               leading: Checkbox(
  //                 value: todo.isCompleted,
  //                 onChanged: (_) => controller.toggleTodo(todo.id!),
  //               ),
  //               title: Text(
  //                 todo.title,
  //                 style: TextStyle(
  //                   decoration:
  //                       todo.isCompleted
  //                           ? TextDecoration.lineThrough
  //                           : null,
  //                   color: todo.isCompleted ? Colors.grey : null,
  //                 ),
  //               ),
  //               trailing: IconButton(
  //                 icon: const Icon(Icons.delete, color: Colors.red),
  //                 onPressed: () => _showDeleteConfirmation(context, todo.id),
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   });
  // }

  // void _showAddTodoDialog(BuildContext context) {
  //   final textController = TextEditingController();

  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: const Text('할 일 추가'),
  //           content: TextField(
  //             controller: textController,
  //             decoration: const InputDecoration(hintText: '할 일을 입력하세요'),
  //             autofocus: true,
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text('취소'),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 if (textController.text.isNotEmpty) {
  //                   controller.addTodo(textController.text);
  //                   Navigator.pop(context);
  //                 }
  //               },
  //               child: const Text('추가'),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  void _showDeleteConfirmation(BuildContext context, String todoId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('삭제 확인'),
            content: const Text('이 할 일을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  controller.deleteTodo(todoId);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('삭제'),
              ),
            ],
          ),
    );
  }
}
