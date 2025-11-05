import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/calendar_controller.dart';

class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildCalendarHeader(context),
            _buildCalendar(context),
            const Divider(),
            Expanded(
              child: _buildEventsList(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarHeader(BuildContext context) {
    return Obx(() {
      final date = controller.selectedDate.value;
      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${date.year}년 ${date.month}월',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    controller.selectDate(
                      DateTime(date.year, date.month - 1, date.day),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    controller.selectDate(
                      DateTime(date.year, date.month + 1, date.day),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCalendar(BuildContext context) {
    return Obx(() {
      final date = controller.selectedDate.value;
      final firstDayOfMonth = DateTime(date.year, date.month, 1);
      final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
      final daysInMonth = lastDayOfMonth.day;
      final startWeekday = firstDayOfMonth.weekday;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['일', '월', '화', '수', '목', '금', '토']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: day == '일'
                                  ? Colors.red
                                  : day == '토'
                                      ? Colors.blue
                                      : null,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: daysInMonth + startWeekday,
              itemBuilder: (context, index) {
                if (index < startWeekday) {
                  return const SizedBox();
                }

                final day = index - startWeekday + 1;
                final currentDate = DateTime(date.year, date.month, day);
                final isSelected = currentDate.day == date.day &&
                    currentDate.month == date.month &&
                    currentDate.year == date.year;
                final hasEvents =
                    controller.getEventsForDay(currentDate).isNotEmpty;

                return GestureDetector(
                  onTap: () => controller.selectDate(currentDate),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: hasEvents
                          ? Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: isSelected ? Colors.white : null,
                          fontWeight:
                              hasEvents ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEventsList(BuildContext context) {
    return Obx(() {
      final events = controller.getEventsForDay(controller.selectedDate.value);

      if (events.isEmpty) {
        return Center(
          child: Text(
            '일정이 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.event),
              title: Text(events[index]),
            ),
          );
        },
      );
    });
  }

  void _showAddEventDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 추가'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: '일정을 입력하세요',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                controller.addEvent(
                  controller.selectedDate.value,
                  textController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }
}
