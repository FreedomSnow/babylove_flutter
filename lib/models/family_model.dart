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
  final List<String> careReceiverIds;
  // 以下属性不从 JSON 中获取，后期赋值
  CareReceiver? lastCareReceiver;
  List<CareReceiver> careReceivers;
  List<FamilyMember> members;

  Family({
    required this.id,
    required this.name,
    this.avatar,
    this.role,
    this.myNickname,
    required this.status,
    this.creatorId,
    this.memberCount,
    List<String>? careReceiverIds,
    CareReceiver? lastCareReceiverParam,
    List<CareReceiver>? careReceiversParam,
    List<FamilyMember>? membersParam,
  }) : careReceiverIds = careReceiverIds ?? [],
       lastCareReceiver = lastCareReceiverParam,
       careReceivers = careReceiversParam ?? [],
       members = membersParam ?? [];

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
      if (role != null) 'role': role,
      if (myNickname != null) 'my_nickname': myNickname,
      'status': status,
      if (creatorId != null) 'creator_id': creatorId,
      if (memberCount != null) 'member_count': memberCount,
      'care_receiver_ids': careReceiverIds,
    };
  }

  @override
  String toString() {
    return 'Family(id: $id, name: $name, avatar: $avatar, role: $role, myNickname: $myNickname, status: $status, creatorId: $creatorId, memberCount: $memberCount)';
  }
}
