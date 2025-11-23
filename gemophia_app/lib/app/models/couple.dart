class Couple {
  final String? id;
  final String? user1Id;
  final String? user2Id;
  final String? coupleName;
  final DateTime? anniversaryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? code;
  final bool? status;

  const Couple({
    this.id,
    this.user1Id,
    this.user2Id,
    this.coupleName,
    this.anniversaryDate,
    this.createdAt,
    this.updatedAt,
    this.code,
    this.status,
  });

  // JSON 변환
  factory Couple.fromJson(Map<String, dynamic> json) {
    return Couple(
      id: json['id'] as String,
      user1Id: json['user1_id'] as String,
      user2Id: json['user2_id'] as String?,
      coupleName: json['couple_name'] as String?,
      anniversaryDate:
          json['anniversary_date'] != null
              ? DateTime.parse(json['anniversary_date'] as String)
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      code: json['code'] as String?,
      status: json['status'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'couple_name': coupleName,
      'anniversary_date': anniversaryDate?.toIso8601String().split('T')[0],
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'code': code,
      'status': status,
    };
  }

  // copyWith 메서드
  Couple copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    String? coupleName,
    DateTime? anniversaryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? code,
    bool? status,
  }) {
    return Couple(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      coupleName: coupleName ?? this.coupleName,
      anniversaryDate: anniversaryDate ?? this.anniversaryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      code: code ?? this.code,
      status: status ?? this.status,
    );
  }

  // 파트너 ID 가져오기 (현재 사용자가 아닌 다른 사용자 ID)
  String? getPartnerId(String currentUserId) {
    if (user1Id == currentUserId) {
      return user2Id;
    } else if (user2Id == currentUserId) {
      return user1Id;
    }
    return null;
  }
}
