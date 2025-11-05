import 'package:get/get.dart';

class CalendarController extends GetxController {
  final selectedDate = DateTime.now().obs;
  final events = <DateTime, List<String>>{}.obs;

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  List<String> getEventsForDay(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void addEvent(DateTime date, String event) {
    final key = DateTime(date.year, date.month, date.day);
    if (events[key] == null) {
      events[key] = [];
    }
    events[key]!.add(event);
    events.refresh();
  }
}
