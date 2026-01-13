import 'family_member_model.dart';
import 'care_receiver_model.dart';

/// 家庭模型
class Family {
  final String id;
  final String name;
  final String? avatar;
  /// 角色类型，可能值：
  /// - 'primary_caregiver' 管理员
  /// - 'assistant_caregiver' 监管者
  /// - 'caregiver' 执行者
  /// - 'visitor' 访客（默认）
  final String role;
  final String? myNickname;
  final String status;
  final String? creatorId;
  final int? memberCount;
  final List<String> careReceiverIds;
  // 以下属性不从 JSON 中获取，后期赋值
  CareReceiver? lastCareReceiver;
  List<CareReceiver> careReceivers;
  List<FamilyMember> members;

  Family({
    required this.id,
    required this.name,
    this.avatar,
    String? role,
    this.myNickname,
    required this.status,
    this.creatorId,
    this.memberCount,
    List<String>? careReceiverIds,
    CareReceiver? lastCareReceiverParam,
    List<CareReceiver>? careReceiversParam,
    List<FamilyMember>? membersParam,
  }) : role = role ?? 'visitor',
       careReceiverIds = careReceiverIds ?? [],
       lastCareReceiver = lastCareReceiverParam,
       careReceivers = careReceiversParam ?? [],
       members = membersParam ?? [];
       

  /// 从 JSON 创建实例
  factory Family.fromJson(Map<String, dynamic> json) {
    final String? avatarRaw = json['avatar'] as String?;
    final String avatarValue = (avatarRaw != null && avatarRaw.trim().isNotEmpty)
        ? avatarRaw
        : 'resource:///family/family0.png';

    return Family(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      avatar: avatarValue,
      role: json['role'] as String?,
      myNickname: json['my_nickname'] as String?,
      status: json['status'] as String? ?? '',
      creatorId: json['creator_id']?.toString(),
      memberCount: json['member_count'] as int?,
      careReceiverIds: (json['care_receiver_ids'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (avatar != null) 'avatar': avatar,
      'role': role,
      if (myNickname != null) 'my_nickname': myNickname,
      'status': status,
      if (creatorId != null) 'creator_id': creatorId,
      if (memberCount != null) 'member_count': memberCount,
      'care_receiver_ids': careReceiverIds,
    };
  }

  // 角色常量
  static const String ROLE_PRIMARY_CAREGIVER = 'primary_caregiver';
  static const String ROLE_ASSISTANT_CAREGIVER = 'assistant_caregiver';
  static const String ROLE_CAREGIVER = 'caregiver';
  static const String ROLE_VISITOR = 'visitor';

  bool get isPrimaryCaregiver => role == ROLE_PRIMARY_CAREGIVER;
  bool get isAssistantCaregiver => role == ROLE_ASSISTANT_CAREGIVER;
  bool get isCaregiver => role == ROLE_CAREGIVER;
  bool get isVisitor => role == ROLE_VISITOR;

  @override
  String toString() {
    return 'Family(id: $id, name: $name, avatar: $avatar, role: $role, myNickname: $myNickname, status: $status, creatorId: $creatorId, memberCount: $memberCount)';
  }
}
