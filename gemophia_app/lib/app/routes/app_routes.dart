part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const AUTH = _Paths.AUTH;
  static const PROFILE = _Paths.PROFILE;
  static const CALENDAR = _Paths.CALENDAR;
  static const TODOLIST = _Paths.TODOLIST;
  static const CONVERSATION_ANALYSIS = _Paths.CONVERSATION_ANALYSIS;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const AUTH = '/auth';
  static const PROFILE = '/profile';
  static const CALENDAR = '/calendar';
  static const TODOLIST = '/todolist';
  static const CONVERSATION_ANALYSIS = '/conversation-analysis';
}
