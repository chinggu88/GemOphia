import 'package:get/get.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/calendar/bindings/calendar_binding.dart';
import '../modules/calendar/views/calendar_view.dart';
import '../modules/todolist/bindings/todolist_binding.dart';
import '../modules/todolist/views/todolist_view.dart';
import '../modules/conversation_analysis/bindings/conversation_analysis_binding.dart';
import '../modules/conversation_analysis/views/conversation_analysis_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      bindings: [
        ProfileBinding(),
        CalendarBinding(),
        TodolistBinding(),
        ConversationAnalysisBinding(),
      ],
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.CALENDAR,
      page: () => const CalendarView(),
      binding: CalendarBinding(),
    ),
    GetPage(
      name: _Paths.TODOLIST,
      page: () => const TodolistView(),
      binding: TodolistBinding(),
    ),
    GetPage(
      name: _Paths.CONVERSATION_ANALYSIS,
      page: () => const ConversationAnalysisView(),
      binding: ConversationAnalysisBinding(),
    ),
  ];
}
