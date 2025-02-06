import 'package:flutter/material.dart';
import 'package:room_calendar/schedule_view.dart';

class FreeRoomsForm extends StatefulWidget {
  const FreeRoomsForm({super.key});

  @override
  State<FreeRoomsForm> createState() => _FreeRoomsFormState();
}

class _FreeRoomsFormState extends State<FreeRoomsForm> {
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final isSelected = List.filled(5, false);
  final labels = ["L", "M", "W", "J", "V"];
  final roomController = TextEditingController();

  TimeOfDay? parse24HourTimeOfDay(String timeString) {
    final timeChunks = timeString.split(":");
    if (timeChunks.length != 2) return null;
    final hours = int.tryParse(timeChunks[0]);
    final minutes = int.tryParse(timeChunks[1]);
    if (hours == null || minutes == null) return null;
    return TimeOfDay(hour: hours, minute: minutes);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Find a Free Room"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: startTimeController,
              decoration: const InputDecoration(labelText: "Start Time"),
              readOnly: true,
              onTap: () => showTimePicker(
                context: context,
                useRootNavigator: false,
                initialTime: parse24HourTimeOfDay(startTimeController.text) ??
                    TimeOfDay.now(),
              ).then((time) => setState(() {
                    if (time != null) {
                      startTimeController.text =
                          formatTime(DateTime(0, 0, 0, time.hour, time.minute));
                    }
                  })),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: endTimeController,
              decoration: const InputDecoration(labelText: "End Time"),
              readOnly: true,
              onTap: () => showTimePicker(
                context: context,
                useRootNavigator: false,
                initialTime: parse24HourTimeOfDay(endTimeController.text) ??
                    TimeOfDay.now(),
              ).then((time) => setState(() {
                    if (time != null) {
                      endTimeController.text =
                          formatTime(DateTime(0, 0, 0, time.hour, time.minute));
                    }
                  })),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              onPressed: (int index) {
                setState(() {
                  isSelected[index] = !isSelected[index];
                });
              },
              isSelected: isSelected,
              children: labels
                  .map((label) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(label),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: roomController,
              decoration: const InputDecoration(
                labelText: "Nearby Room",
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel")),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop({
                "start_time": startTimeController.text,
                "end_time": endTimeController.text,
                "days":
                    labels.where((e) => isSelected[labels.indexOf(e)]).toList(),
                "room": roomController.text,
              });
            },
            child: const Text("Submit"))
      ],
    );
  }
}
