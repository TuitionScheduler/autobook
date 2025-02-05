import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';

class ScheduleView extends StatelessWidget {
  final List<Map<String, dynamic>> sections;

  const ScheduleView({super.key, required this.sections});

  EventController get controller {
    final controller = EventController();
    final dayMap = {"L": 1, "M": 2, "W": 3, "J": 4, "V": 5};
    for (var section in sections) {
      final startTime = (section["m_start_time"] as String).split(":");
      final endTime = (section["m_end_time"] as String).split(":");
      for (var day in (section["m_days"] as String).characters) {
        final dayNumber = dayMap[day]!;
        controller.add(CalendarEventData(
          title: "${section["c_code"]}-${section["s_code"]}",
          titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
          date: DateTime(2024, 1, dayNumber),
          startTime: DateTime(2024, 1, dayNumber, int.parse(startTime[0]),
              int.parse(startTime[1])),
          endTime: DateTime(
              2024, 1, dayNumber, int.parse(endTime[0]), int.parse(endTime[1])),
          color: Colors.deepPurple[400]!,
        ));
      }
    }
    return controller;
  }

  String formatTime(DateTime dateTime) =>
      "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
        controller: controller,
        child: WeekView(
          minDay: DateTime(2024, 1, 1),
          maxDay: DateTime(2024, 1, 5),
          headerStyle: const HeaderStyle(
            leftIconVisible: false,
            rightIconVisible: false,
            headerTextStyle: TextStyle(fontSize: 0),
          ),
          showWeekends: false,
          startHour: 6,
          timeLineWidth: 60,
          onEventTap: (events, date) {
            showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) {
                  final event = events.first;
                  return AlertDialog(
                    title: Text(event.title),
                    content: Text(
                        "${formatTime(event.startTime!)}-${formatTime(event.endTime!)}"),
                  );
                });
          },
        ));
  }
}
