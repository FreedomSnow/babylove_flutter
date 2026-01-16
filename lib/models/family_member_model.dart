import 'family_model.dart';

/// 家庭成员模型
class FamilyMember {
  final String id;
  final String familyId;
  final String userId;
  final String role;
  final String nickname;
  final String status;
  final String? avatarUrl;

  FamilyMember({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.role,
    required this.nickname,
    required this.status,
    this.avatarUrl,
  });

  /// 从 JSON 创建实例
  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      familyId: json['family_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      role: json['role'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      status: json['status'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'user_id': userId,
      'role': role,
      'nickname': nickname,
      'status': status,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
  }

  @override
  String toString() {
    return 'FamilyMember(id: $id, familyId: $familyId, userId: $userId, role: $role, nickname: $nickname, status: $status, avatarUrl: $avatarUrl)';
  }
}

/// 加入家庭响应数据
class JoinFamilyResponse {
  final Family family;
  final FamilyMember member;

  JoinFamilyResponse({
    required this.family,
    required this.member,
  });

  /// 从 JSON 创建实例
  factory JoinFamilyResponse.fromJson(Map<String, dynamic> json) {
    return JoinFamilyResponse(
      family: Family.fromJson(json['family'] as Map<String, dynamic>),
      member: FamilyMember.fromJson(json['member'] as Map<String, dynamic>),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'family': family.toJson(),
      'member': member.toJson(),
    };
  }

  @override
  String toString() {
    return 'JoinFamilyResponse(family: $family, member: $member)';
  }
}
