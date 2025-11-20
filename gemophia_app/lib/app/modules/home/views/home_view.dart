import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gemophia_app/app/services/supabase_service.dart';
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
  static final List<IconData> _iconList = [
    Icons.person,
    Icons.calendar_today,
    Icons.checklist,
    Icons.analytics,
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _pages[controller.currentIndex]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
        onPressed: () async {
          await SupabaseService.to.pickAndUploadFile();
        },
        //params
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Obx(
        () => AnimatedBottomNavigationBar.builder(
          tabBuilder: (int index, bool isActive) {
            return Icon(
              _iconList[index],
              size: 24,
              color: isActive ? Colors.amber : Colors.black,
            );
          },
          backgroundColor: Colors.grey,
          itemCount: _iconList.length,
          activeIndex: controller.currentIndex,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.verySmoothEdge,
          leftCornerRadius: 32,
          rightCornerRadius: 32,
          onTap: (index) => controller.changeTab(index),
          //other params
        ),
        // () => BottomNavigationBar(
        //   // backgroundColor: Colors.amber,
        //   currentIndex: controller.currentIndex.value,
        //   onTap: controller.changeTab,
        //   items: const [
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.person),
        //       label: 'Profile',
        //       backgroundColor: Colors.amber,
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.calendar_today),
        //       label: 'Calendar',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.checklist),
        //       label: 'Todo List',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.analytics),
        //       label: 'Analysis',
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
