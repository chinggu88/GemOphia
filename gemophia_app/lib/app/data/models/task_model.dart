import 'package:gemophia_app/app/models/event_model.dart';

class Task {
  int? _id;
  String? _title;
  String? _subtitle;
  String? _time;
  int? _avatarCount;
  bool? _isCompleted;
  DateTime? _createdAt;
  EventCategory? _category;

  Task({
    int? id,
    String? title,
    String? subtitle,
    String? time,
    int? avatarCount,
    bool? isCompleted,
    String? createdAt,
    EventCategory? category,
  }) {
    if (id != null) {
      this._id = id;
    }
    if (title != null) {
      this._title = title;
    }
    if (subtitle != null) {
      this._subtitle = subtitle;
    }
    if (time != null) {
      this._time = time;
    }
    if (avatarCount != null) {
      this._avatarCount = avatarCount;
    }
    if (isCompleted != null) {
      this._isCompleted = isCompleted;
    }
    if (createdAt != null) {
      this._createdAt = DateTime.parse(createdAt);
    }
    if (category != null) {
      this._category = category;
    }
  }

  int? get id => _id;
  set id(int? id) => _id = id;

  String? get title => _title;
  set title(String? title) => _title = title;

  String? get subtitle => _subtitle;
  set subtitle(String? subtitle) => _subtitle = subtitle;

  String? get time => _time;
  set time(String? time) => _time = time;

  int? get avatarCount => _avatarCount;
  set avatarCount(int? avatarCount) => _avatarCount = avatarCount;

  bool? get isCompleted => _isCompleted;
  set isCompleted(bool? isCompleted) => _isCompleted = isCompleted;

  DateTime? get createdAt => _createdAt;
  set createdAt(DateTime? createdAt) => _createdAt = createdAt;

  EventCategory? get category => _category;
  set category(EventCategory? category) => _category = category;

  Task.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _title = json['title'];
    _subtitle = json['subtitle'];
    _time = json['time'];
    _avatarCount = json['avatar_count'];
    _isCompleted = json['is_completed'];
    _createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'].toString())
        : null;
    _category = json['category'] != null
        ? EventCategory.values.firstWhere((e) => e.name == json['category'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this._id;
    data['title'] = this._title;
    data['subtitle'] = this._subtitle;
    data['time'] = this._time;
    data['avatar_count'] = this._avatarCount;
    data['is_completed'] = this._isCompleted;
    data['created_at'] = this._createdAt?.toIso8601String();
    data['category'] = this._category?.name;
    return data;
  }
}
