class AutobookFilters {
  final String startTime;
  final String endTime;
  final List<String> days;
  final String room;

  const AutobookFilters({
    required this.startTime,
    required this.endTime,
    required this.days,
    required this.room,
  });

  factory AutobookFilters.fromMap(Map<String, dynamic> map) {
    return AutobookFilters(
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      days: (map['days'] as List).cast<String>(),
      room: map['room'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'start_time': startTime,
      'end_time': endTime,
      'days': days,
      'room': room,
    };
  }

  AutobookFilters copyWith({
    String? startTime,
    String? endTime,
    List<String>? days,
    String? room,
  }) {
    return AutobookFilters(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      days: days ?? this.days,
      room: room ?? this.room,
    );
  }

  factory AutobookFilters.empty() {
    return const AutobookFilters(
      startTime: "",
      endTime: "",
      days: [],
      room: "",
    );
  }
}
