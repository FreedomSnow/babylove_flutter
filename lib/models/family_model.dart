import 'family_member_model.dart';
import 'care_receiver_model.dart';

/// 家庭模型
class Family {
  final String id;
  final String name;
  final String? avatar;
  final String? role;
  final String? myNickname;
  final String status;
  final String? creatorId;
  final int? memberCount;
  final int? createdAt;
  final int? updatedAt;

  Family({
    required this.id,
    required this.name,
    this.avatar,
    this.role,
    this.myNickname,
    required this.status,
    this.creatorId,
    this.memberCount,
    this.createdAt,
    this.updatedAt,
  });

  /// 从 JSON 创建实例
  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      role: json['role'] as String?,
      myNickname: json['my_nickname'] as String?,
      status: json['status'] as String? ?? '',
      creatorId: json['creator_id']?.toString(),
      memberCount: json['member_count'] as int?,
      createdAt: json['created_at'] as int?,
      updatedAt: json['updated_at'] as int?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (avatar != null) 'avatar': avatar,
      if (role != null) 'role': role,
      if (myNickname != null) 'my_nickname': myNickname,
      'status': status,
      if (creatorId != null) 'creator_id': creatorId,
      if (memberCount != null) 'member_count': memberCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Family(id: $id, name: $name, avatar: $avatar, role: $role, myNickname: $myNickname, status: $status, creatorId: $creatorId, memberCount: $memberCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// 家庭展示模型（用于UI）
class FamilyModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final List<CareReceiver> careReceivers;
  final List<FamilyMember> members;
  final DateTime createdAt;

  FamilyModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.careReceivers,
    required this.members,
    required this.createdAt,
  });
}

