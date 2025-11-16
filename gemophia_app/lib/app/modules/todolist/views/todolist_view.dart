import 'dart:developer';

import 'package:contribution_heatmap/contribution_heatmap.dart';
import 'package:flutter/material.dart';
import 'package:gemophia_app/app/core/values/app_colors.dart';

import 'package:gemophia_app/app/data/models/task_model.dart';
import 'package:gemophia_app/app/models/event_model.dart';
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
            const SizedBox(height: 16),
            _buildFilterTabs(),
            const SizedBox(height: 16),
            Expanded(child: _buildTaskList()),
          ],
        ),
      ),
      // floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildFilterTabs() {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                'All',
                controller.allCount,
                filterKey: 'all',
                isSelected: controller.selectedFilter == 'all',
              ),
              SizedBox(width: 8),
              const Text('|', style: TextStyle(color: Colors.grey)),
              SizedBox(width: 8),
              _buildFilterChip(
                'Open',
                controller.openCount,
                filterKey: 'open',
                isSelected: controller.selectedFilter == 'open',
              ),
              SizedBox(width: 8),
              _buildFilterChip(
                'Archived',
                controller.archivedCount,
                filterKey: 'archived',
                isSelected: controller.selectedFilter == 'archived',
              ),
              SizedBox(width: 8),
              _buildFilterChip(
                'Closed',
                controller.closedCount,
                filterKey: 'closed',
                isSelected: controller.selectedFilter == 'closed',
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFilterChip(
    String label,
    int count, {
    required String filterKey,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () {
        controller.selectedFilter = filterKey;
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 6),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Obx _buildTaskList() {
    return Obx(() {
      log('asdf ${controller.filteredTasks.length}');
      final filteredTasks = controller.filteredTasks;
      if (filteredTasks.length == 0) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.task_alt, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                '할 일이 없습니다',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24),
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          return _buildTaskCard(context, filteredTasks[index]);
        },
      );
    });
  }

  Color _getCategoryColor(EventCategory? category) {
    switch (category) {
      case EventCategory.restaurant:
        return AppColors.categoryRestaurant;
      case EventCategory.indoor:
        return AppColors.categoryIndoor;
      case EventCategory.outdoor:
        return AppColors.categoryOutdoor;
      case EventCategory.conversation:
        return AppColors.categoryConversation;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration:
                            task.isCompleted!
                                ? TextDecoration.lineThrough
                                : null,
                        color: task.isCompleted! ? Colors.grey : Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      task.subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(task.category),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 26),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Today',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8),
              Text(
                task.time!,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, color: Colors.white, size: 24),
          SizedBox(width: 8),
          Text(
            'New Task',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Task',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Wednesday, 11 May',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildFloatingActionButton(context),
        ],
      ),
    );
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
                  // controller.deleteTodo(todoId);
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
