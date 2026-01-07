/// 待办事项类型
enum TodoType {
  medication, // 用药
  appointment, // 就诊
  exercise, // 锻炼
  meal, // 饮食
  activity, // 活动
  reminder, // 提醒
  other, // 其他
}

extension TodoTypeExtension on TodoType {
  String get displayName {
    switch (this) {
      case TodoType.medication:
        return '用药';
      case TodoType.appointment:
        return '就诊';
      case TodoType.exercise:
        return '锻炼';
      case TodoType.meal:
        return '饮食';
      case TodoType.activity:
        return '活动';
      case TodoType.reminder:
        return '提醒';
      case TodoType.other:
        return '其他';
    }
  }

  String get iconData {
    switch (this) {
      case TodoType.medication:
        return '💊';
      case TodoType.appointment:
        return '🏥';
      case TodoType.exercise:
        return '🏃';
      case TodoType.meal:
        return '🍽️';
      case TodoType.activity:
        return '🎯';
      case TodoType.reminder:
        return '⏰';
      case TodoType.other:
        return '📝';
    }
  }
}

/// 待办事项模型
class TodoModel {
  final String id;
  final String title;
  final String? description;
  final DateTime dateTime;
  final TodoType type;
  final bool isCompleted;
  final String familyId;
  final String careReceiverId;
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoModel({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    required this.type,
    this.isCompleted = false,
    required this.familyId,
    required this.careReceiverId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    TodoType? type,
    bool? isCompleted,
    String? familyId,
    String? careReceiverId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      familyId: familyId ?? this.familyId,
      careReceiverId: careReceiverId ?? this.careReceiverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'type': type.name,
      'isCompleted': isCompleted,
      'familyId': familyId,
      'careReceiverId': careReceiverId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dateTime: DateTime.parse(json['dateTime'] as String),
      type: TodoType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TodoType.other,
      ),
      isCompleted: json['isCompleted'] as bool? ?? false,
      familyId: json['familyId'] as String,
      careReceiverId: json['careReceiverId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
