import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/views/profile_view.dart';
import '../../calendar/controllers/calendar_controller.dart';
import '../../calendar/views/calendar_view.dart';
import '../../todolist/controllers/todolist_controller.dart';
import '../../todolist/views/todolist_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static final List<Widget> _pages = [
    const ProfileView(),
    const CalendarView(),
    const TodolistView(),
  ];

  @override
  Widget build(BuildContext context) {
    // Ensure all controllers are initialized
    Get.find<ProfileController>();
    Get.find<CalendarController>();
    Get.find<TodolistController>();

    return Scaffold(
      body: Obx(() => _pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist),
              label: 'Todo List',
            ),
          ],
        ),
      ),
    );
  }
}
