class HeatmapItem {
  int? _id;
  int? _cnt;
  DateTime? _createdAt;
  bool? _isCompleted;

  HeatmapItem({int? id, int? cnt, String? createdAt, bool? isCompleted}) {
    if (id != null) {
      this._id = id;
    }
    if (cnt != null) {
      this._cnt = cnt;
    }
    if (createdAt != null) {
      this._createdAt = DateTime.parse(createdAt);
    }
    if (isCompleted != null) {
      this._isCompleted = isCompleted;
    }
  }

  int? get id => _id;
  set id(int? id) => _id = id;
  int? get cnt => _cnt;
  set cnt(int? cnt) => _cnt = cnt;
  DateTime? get createdAt => _createdAt;
  set createdAt(DateTime? createdAt) => _createdAt = createdAt;
  bool? get isCompleted => _isCompleted;
  set isCompleted(bool? isCompleted) => _isCompleted = isCompleted;

  HeatmapItem.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _cnt = json['cnt'];
    _createdAt = DateTime.parse(json['created_at'].toString());
    _isCompleted = json['isCompleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['cnt'] = this._cnt;
    data['created_at'] = this._createdAt;
    data['isCompleted'] = this._isCompleted;
    return data;
  }
}
