import 'dart:developer';

import 'package:get/get.dart';
import '../../../models/event_model.dart';

class CalendarController extends GetxController {
  static CalendarController get to => Get.find();

  // 선택된 날짜
  final _selectedDate = DateTime.now().obs;
  DateTime get selectedDate => _selectedDate.value;
  set selectedDate(DateTime value) => _selectedDate.value = value;

  // 이벤트 목록
  final _events = <DateTime, List<EventModel>>{}.obs;
  Map<DateTime, List<EventModel>> get events => _events;
  set events(Map<DateTime, List<EventModel>> value) => _events.value = value;

  @override
  void onInit() {
    // 샘플 데이터 - 커플 데이트 일정
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    // 이번 달의 마지막 날 계산
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;

    // 매일 최소 1개의 데이트 일정 생성
    for (int day = 1; day <= lastDayOfMonth; day++) {
      final date = DateTime(year, month, day);

      // 날짜에 따라 다양한 데이트 일정 생성
      final List<EventModel> dayEvents = [];

      if (day % 7 == 1) {
        // 맛집 데이트
        dayEvents.add(
          EventModel(
            date: date,
            time: DateTime(year, month, day, 18, 30, 0),
            content: '이탈리안 레스토랑 저녁',
            location: '강남 트라토리아',
            category: EventCategory.restaurant,
          ),
        );
      } else if (day % 7 == 2) {
        // 실내 데이트
        dayEvents.add(
          EventModel(
            date: date,
            time: DateTime(year, month, day, 14, 0, 0),
            content: '영화 데이트',
            location: 'CGV 강남점',
            category: EventCategory.indoor,
          ),
        );
      } else if (day % 7 == 3) {
        // 실외 데이트
        dayEvents.add(
          EventModel(
            date: date,
            time: DateTime(year, month, day, 15, 0, 0),
            content: '한강 자전거 타기',
            location: '여의도 한강공원',
            category: EventCategory.outdoor,
          ),
        );
      } else if (day % 7 == 4) {
        // 대화 데이트
        dayEvents.add(
          EventModel(
            date: date,
            time: DateTime(year, month, day, 19, 0, 0),
            content: '감성 카페에서 대화',
            location: '홍대 루프탑 카페',
            category: EventCategory.conversation,
          ),
        );
      } else if (day % 7 == 5) {
        // 맛집 + 산책
        dayEvents.add(
          EventModel(
            date: date,
            time: DateTime(year, month, day, 12, 0, 0),
            content: '브런치 카페',
            location: '성수동 브런치 카페',
            category: EventCategory.restaurant,
          ),
        );
        dayEvents.add(
          EventModel(
            date: date,
            time: DateTime(year, month, day, 15, 0, 0),
            content: '성수동 데이트 거리 산책',
            location: '성수동',
            category: EventCategory.outdoor,
          ),
        );
      } else if (day % 7 == 6) {
        // 실내 문화 데이트
        dayEvents.add(
          EventModel(
            date: date,
            time: DateTime(year, month, day, 13, 0, 0),
            content: '미술관 관람',
            location: '국립현대미술관',
            category: EventCategory.indoor,
          ),
        );
      } else {
        // 저녁 식사 데이트
        dayEvents.add(
          EventModel(
            date: date,
            time: DateTime(year, month, day, 19, 30, 0),
            content: '한식 맛집 저녁',
            location: '북촌 한정식',
            category: EventCategory.restaurant,
          ),
        );
      }

      if (dayEvents.isNotEmpty) {
        events[date] = dayEvents;
      }
    }

    super.onInit();
  }

  void selectDate(DateTime date) {
    selectedDate = date;
  }

  List<EventModel> getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return events[normalizedDay] ?? [];
  }

  void addEvent({
    required DateTime date,
    DateTime? time,
    String? content,
    String? location,
    EventCategory? category,
  }) {
    final key = DateTime(date.year, date.month, date.day);

    final event = EventModel(
      date: key,
      time: time,
      content: content,
      location: location,
      category: category,
    );

    if (_events[key] == null) {
      _events[key] = [];
    }
    _events[key]!.add(event);
    _events.refresh();
  }

  void removeEvent(DateTime date, EventModel event) {
    final key = DateTime(date.year, date.month, date.day);
    _events[key]?.remove(event);
    _events.refresh();
  }
}
