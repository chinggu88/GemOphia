import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gemophia_app/app/data/models/task_model.dart';
import 'package:gemophia_app/app/data/models/todo_model.dart';
import 'package:gemophia_app/app/models/event_model.dart';
import 'package:gemophia_app/app/services/supabase_service.dart';
import 'package:get/get.dart';

class TodolistController extends GetxController {
  static TodolistController get to => Get.find();

  final _tasks = <Task>[].obs;
  set tasks(List<Task> value) => _tasks.value = value;
  List<Task> get tasks => _tasks.toList();

  // 필터 상태: 'all', 'open', 'closed', 'archived'
  final _selectedFilter = 'all'.obs;
  String get selectedFilter => _selectedFilter.value;
  set selectedFilter(String value) => _selectedFilter.value = value;

  // 필터링된 tasks 가져오기
  List<Task> get filteredTasks {
    switch (selectedFilter) {
      case 'open':
        // isCompleted가 false인 항목 (시작 전 + 진행 중)
        return tasks.where((task) => task.isCompleted == false).toList();
      case 'closed':
        // isCompleted가 true인 항목 (완료)
        return tasks.where((task) => task.isCompleted == true).toList();
      case 'archived':
        // 5일 이상 지난 완료된 항목
        final archiveDate = DateTime.now().subtract(const Duration(days: 5));
        return tasks
            .where(
              (task) =>
                  task.isCompleted == true &&
                  task.createdAt != null &&
                  task.createdAt!.isBefore(archiveDate),
            )
            .toList();
      case 'all':
      default:
        return tasks;
    }
  }

  // 각 필터별 카운트
  int get allCount => tasks.length;
  int get openCount => tasks.where((task) => task.isCompleted == false).length;
  int get closedCount => tasks.where((task) => task.isCompleted == true).length;
  int get archivedCount {
    final archiveDate = DateTime.now().subtract(const Duration(days: 5));
    return tasks
        .where(
          (task) =>
              task.isCompleted == true &&
              task.createdAt != null &&
              task.createdAt!.isBefore(archiveDate),
        )
        .length;
  }

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();

    // 샘플 Task 데이터 생성
    _generateSampleTasks();
  }

  void _generateSampleTasks() {
    final now = DateTime.now();
    final List<Task> sampleTasks = [];

    // 시작 전 (5개) - isCompleted: false
    sampleTasks.addAll([
      Task(
        id: 1,
        title: 'UI/UX Research',
        subtitle: 'Mobile App Design',
        time: '09:00 AM - 10:30 AM',
        avatarCount: 3,
        isCompleted: false,
        createdAt: now.toIso8601String(),
        category: EventCategory.indoor,
      ),
      Task(
        id: 2,
        title: 'Database Schema Design',
        subtitle: 'Backend Development',
        time: '10:45 AM - 12:00 PM',
        avatarCount: 2,
        isCompleted: false,
        createdAt: now.toIso8601String(),
        category: EventCategory.conversation,
      ),
      Task(
        id: 3,
        title: 'API Documentation',
        subtitle: 'Backend Development',
        time: '01:00 PM - 02:30 PM',
        avatarCount: 4,
        isCompleted: false,
        createdAt: now.toIso8601String(),
        category: EventCategory.restaurant,
      ),
      Task(
        id: 4,
        title: 'Marketing Campaign Planning',
        subtitle: 'Marketing Team',
        time: '02:45 PM - 04:00 PM',
        avatarCount: 5,
        isCompleted: false,
        createdAt: now.toIso8601String(),
        category: EventCategory.outdoor,
      ),
      Task(
        id: 5,
        title: 'Security Audit',
        subtitle: 'DevOps Team',
        time: '04:15 PM - 05:30 PM',
        avatarCount: 2,
        isCompleted: false,
        createdAt: now.toIso8601String(),
        category: EventCategory.indoor,
      ),
    ]);

    // 진행 중 (5개) - isCompleted: false (진행 중으로 표시하려면 별도 상태 필드 추가 필요)
    sampleTasks.addAll([
      Task(
        id: 6,
        title: 'Frontend Development',
        subtitle: 'Web Dashboard',
        time: '09:00 AM - 11:00 AM',
        avatarCount: 3,
        isCompleted: false,
        createdAt: now.toIso8601String(),
        category: EventCategory.conversation,
      ),
      Task(
        id: 7,
        title: 'User Testing Session',
        subtitle: 'Product Testing',
        time: '11:30 AM - 01:00 PM',
        avatarCount: 6,
        isCompleted: false,
        createdAt: now.toIso8601String(),
        category: EventCategory.restaurant,
      ),
      Task(
        id: 8,
        title: 'Code Review Meeting',
        subtitle: 'Development Team',
        time: '02:00 PM - 03:00 PM',
        avatarCount: 4,
        isCompleted: false,
        createdAt: now.toIso8601String(),
        category: EventCategory.outdoor,
      ),
      Task(
        id: 9,
        title: 'Sprint Planning',
        subtitle: 'Agile Team',
        time: '03:30 PM - 05:00 PM',
        avatarCount: 7,
        isCompleted: false,
        createdAt: now.toIso8601String(),
        category: EventCategory.indoor,
      ),
      Task(
        id: 10,
        title: 'Performance Optimization',
        subtitle: 'Backend Development',
        time: '05:15 PM - 06:30 PM',
        avatarCount: 2,
        isCompleted: false,
        createdAt: now.toIso8601String(),
        category: EventCategory.conversation,
      ),
    ]);

    // 완료 (10개) - isCompleted: true
    sampleTasks.addAll([
      Task(
        id: 11,
        title: 'Client Review & Feedback',
        subtitle: 'Crypto Wallet Redesign',
        time: '10:00 AM - 11:45 AM',
        avatarCount: 2,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 1)).toIso8601String(),
        category: EventCategory.restaurant,
      ),
      Task(
        id: 12,
        title: 'Create Wireframe',
        subtitle: 'Crypto Wallet Redesign',
        time: '09:15 AM - 10:00 AM',
        avatarCount: 4,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 1)).toIso8601String(),
        category: EventCategory.indoor,
      ),
      Task(
        id: 13,
        title: 'Design System Update',
        subtitle: 'UI Components',
        time: '02:00 PM - 04:00 PM',
        avatarCount: 3,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 2)).toIso8601String(),
        category: EventCategory.conversation,
      ),
      Task(
        id: 14,
        title: 'Bug Fixes',
        subtitle: 'Mobile App',
        time: '10:30 AM - 12:00 PM',
        avatarCount: 2,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 2)).toIso8601String(),
        category: EventCategory.outdoor,
      ),
      Task(
        id: 15,
        title: 'Team Standup Meeting',
        subtitle: 'Daily Sync',
        time: '09:00 AM - 09:30 AM',
        avatarCount: 8,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 3)).toIso8601String(),
        category: EventCategory.indoor,
      ),
      Task(
        id: 16,
        title: 'Deploy to Staging',
        subtitle: 'DevOps',
        time: '03:00 PM - 04:00 PM',
        avatarCount: 3,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 3)).toIso8601String(),
        category: EventCategory.restaurant,
      ),
      Task(
        id: 17,
        title: 'Write Unit Tests',
        subtitle: 'Backend Development',
        time: '01:00 PM - 03:00 PM',
        avatarCount: 2,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 4)).toIso8601String(),
        category: EventCategory.conversation,
      ),
      Task(
        id: 18,
        title: 'Client Presentation',
        subtitle: 'Product Demo',
        time: '11:00 AM - 12:00 PM',
        avatarCount: 5,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 4)).toIso8601String(),
        category: EventCategory.outdoor,
      ),
      Task(
        id: 19,
        title: 'Update Documentation',
        subtitle: 'Technical Writing',
        time: '02:00 PM - 03:30 PM',
        avatarCount: 1,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 5)).toIso8601String(),
        category: EventCategory.indoor,
      ),
      Task(
        id: 20,
        title: 'Retrospective Meeting',
        subtitle: 'Agile Team',
        time: '04:00 PM - 05:00 PM',
        avatarCount: 9,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 5)).toIso8601String(),
        category: EventCategory.restaurant,
      ),
    ]);

    tasks = sampleTasks;
  }
}
