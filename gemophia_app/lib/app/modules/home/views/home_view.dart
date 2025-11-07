import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../profile/views/profile_view.dart';
import '../../calendar/views/calendar_view.dart';
import '../../todolist/views/todolist_view.dart';
import '../../conversation_analysis/views/conversation_analysis_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static final List<Widget> _pages = [
    const ProfileView(),
    const CalendarView(),
    const TodolistView(),
    const ConversationAnalysisView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          // backgroundColor: Colors.amber,
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
              backgroundColor: Colors.amber,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist),
              label: 'Todo List',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Analysis',
            ),
          ],
        ),
      ),
    );
  }
}
