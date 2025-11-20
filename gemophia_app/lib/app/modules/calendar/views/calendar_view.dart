import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../models/event_model.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/calendar_controller.dart';

class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Obx(
              () => TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: controller.selectedDate,
                locale: 'ko_KR',
                selectedDayPredicate: (day) {
                  return isSameDay(controller.selectedDate, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  controller.selectDate(selectedDay);
                },
                eventLoader: (day) {
                  return controller.getEventsForDay(day);
                },
                rowHeight: 50,
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) return const SizedBox();
                    final eventList = events.cast<EventModel>();
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Wrap(
                        spacing: 3,
                        runSpacing: 3,
                        children: [
                          for (final event in eventList) ...[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(event.category!),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                calendarStyle: CalendarStyle(
                  markersMaxCount: 10,
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  todayDecoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  cellMargin: EdgeInsets.all(10),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.black, fontSize: 14),
                  weekendStyle: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                final events = controller.getEventsForDay(
                  controller.selectedDate,
                );
                if (events.isEmpty) {
                  return Center(
                    child: Text(
                      '일정이 없습니다',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: events.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Category icon with background
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:
                                  event.category != null
                                      ? _getCategoryColor(
                                        event.category!,
                                      ).withValues(alpha: 0.15)
                                      : Colors.grey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              event.category != null
                                  ? _getCategoryIcon(event.category!)
                                  : Icons.event,
                              color:
                                  event.category != null
                                      ? _getCategoryColor(event.category!)
                                      : Colors.grey,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          // Event details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category label
                                if (event.category != null)
                                  Text(
                                    event.category!.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                SizedBox(height: 2),
                                // Title
                                Text(
                                  event.content ?? '내용 없음',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E2831),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Location
                                if (event.location != null) ...[
                                  SizedBox(height: 2),
                                  Text(
                                    event.location!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          // Time and more button
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Time
                              if (event.time != null)
                                Text(
                                  '${event.time!.hour.toString().padLeft(2, '0')}:${event.time!.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E2831),
                                  ),
                                ),
                              SizedBox(height: 4),
                              // Date
                              Text(
                                '${event.date.day} ${_getMonthName(event.date.month)} ${event.date.year}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          // Delete icon button
                          IconButton(
                            icon: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                Icons.close,
                                color: AppColors.error,
                                size: 16,
                              ),
                            ),
                            onPressed: () {
                              _showEventOptions(context, event);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final contentController = TextEditingController();
    final locationController = TextEditingController();
    TimeOfDay? selectedTime;
    EventCategory? selectedCategory;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('일정 추가'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: contentController,
                          decoration: const InputDecoration(
                            labelText: '내용 *',
                            hintText: '일정 내용을 입력하세요',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<EventCategory>(
                          value: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: '카테고리 (선택)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                          items:
                              EventCategory.values.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getCategoryIcon(category),
                                        color: _getCategoryColor(category),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(category.label),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: locationController,
                          decoration: const InputDecoration(
                            labelText: '위치 (선택)',
                            hintText: '장소를 입력하세요',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                selectedTime = time;
                              });
                            }
                          },
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            selectedTime != null
                                ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                : '시간 선택 (선택)',
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (contentController.text.isNotEmpty) {
                          final selectedDate = controller.selectedDate;
                          DateTime? eventTime;

                          if (selectedTime != null) {
                            eventTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime!.hour,
                              selectedTime!.minute,
                              0,
                            );
                          }

                          controller.addEvent(
                            date: selectedDate,
                            time: eventTime,
                            content: contentController.text,
                            location:
                                locationController.text.isNotEmpty
                                    ? locationController.text
                                    : null,
                            category: selectedCategory,
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('추가'),
                    ),
                  ],
                ),
          ),
    );
  }

  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.restaurant:
        return AppColors.categoryRestaurant;
      case EventCategory.indoor:
        return AppColors.categoryIndoor;
      case EventCategory.outdoor:
        return AppColors.categoryOutdoor;
      case EventCategory.conversation:
        return AppColors.categoryConversation;
    }
  }

  IconData _getCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.restaurant:
        return Icons.restaurant;
      case EventCategory.indoor:
        return Icons.home;
      case EventCategory.outdoor:
        return Icons.park;
      case EventCategory.conversation:
        return Icons.chat_bubble;
    }
  }

  void _showEventOptions(BuildContext context, EventModel event) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: AppColors.primary),
                  title: const Text('수정'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement edit functionality
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: AppColors.error),
                  title: const Text('삭제'),
                  onTap: () {
                    Navigator.pop(context);
                    controller.removeEvent(
                      controller.selectedDate,
                      event,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.close, color: Colors.grey),
                  title: const Text('취소'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthNames[month];
  }
}
