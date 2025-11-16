enum EventCategory {
  restaurant('맛집'),
  indoor('실내'),
  outdoor('실외'),
  conversation('대화');

  const EventCategory(this.label);
  final String label;
}

class EventModel {
  final DateTime date; // yyyy-mm-dd (필수)
  final DateTime? time; // hh-mm-ss (nullable)
  final String? content; // 내용 (nullable)
  final String? location; // 위치 (nullable)
  final EventCategory? category; // 카테고리 (nullable)

  EventModel({
    required this.date,
    this.time,
    this.content,
    this.location,
    this.category,
  });

  // DateTime을 yyyy-MM-dd 형식으로 변환
  String get formattedDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // DateTime을 HH:mm:ss 형식으로 변환
  String? get formattedTime {
    if (time == null) return null;
    return '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}:${time!.second.toString().padLeft(2, '0')}';
  }

  // JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'time': time?.toIso8601String(),
      'content': content,
      'location': location,
      'category': category?.name,
    };
  }

  // JSON에서 생성
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      date: DateTime.parse(json['date']),
      time: json['time'] != null ? DateTime.parse(json['time']) : null,
      content: json['content'],
      location: json['location'],
      category: json['category'] != null
          ? EventCategory.values.firstWhere((e) => e.name == json['category'])
          : null,
    );
  }

  // 복사본 생성
  EventModel copyWith({
    DateTime? date,
    DateTime? time,
    String? content,
    String? location,
    EventCategory? category,
  }) {
    return EventModel(
      date: date ?? this.date,
      time: time ?? this.time,
      content: content ?? this.content,
      location: location ?? this.location,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'EventModel(date: $formattedDate, time: $formattedTime, content: $content, location: $location, category: ${category?.label})';
  }
}
