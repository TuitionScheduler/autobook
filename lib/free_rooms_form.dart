import 'package:flutter/material.dart';
import 'package:room_calendar/model/autobook_filters.dart';
import 'package:room_calendar/schedule_view.dart';

class FreeRoomsForm extends StatefulWidget {
  final AutobookFilters? initialFilters;

  const FreeRoomsForm({
    super.key,
    this.initialFilters,
  });

  @override
  State<FreeRoomsForm> createState() => _FreeRoomsFormState();
}

class _FreeRoomsFormState extends State<FreeRoomsForm> {
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final roomController = TextEditingController();
  late final List<bool> isSelected;
  final labels = ["L", "M", "W", "J", "V"];

  @override
  void initState() {
    super.initState();
    // Initialize with provided filters or defaults
    if (widget.initialFilters != null) {
      startTimeController.text = widget.initialFilters!.startTime;
      endTimeController.text = widget.initialFilters!.endTime;
      roomController.text = widget.initialFilters!.room;
      isSelected = List.generate(labels.length,
          (index) => widget.initialFilters!.days.contains(labels[index]));
    } else {
      isSelected = List.filled(labels.length, false);
    }
  }

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
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
            child: const Text("Cancel")),
        TextButton(
            onPressed: () => Navigator.of(context).pop(AutobookFilters.empty()),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[400],
            ),
            child: const Text("Clear")),
        TextButton(
            onPressed: () {
              final filters = AutobookFilters(
                startTime: startTimeController.text,
                endTime: endTimeController.text,
                days:
                    labels.where((e) => isSelected[labels.indexOf(e)]).toList(),
                room: roomController.text,
              );
              Navigator.of(context).pop(filters);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.green[600],
            ),
            child: const Text("Submit"))
      ],
    );
  }

  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    roomController.dispose();
    super.dispose();
  }
}
