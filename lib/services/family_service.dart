import 'package:babylove_flutter/core/network/network.dart';
import 'package:babylove_flutter/models/family_model.dart';
import 'package:babylove_flutter/models/family_member_model.dart';

/// 家庭 API 服务
class FamilyService {
  final HttpClient _httpClient = HttpClient();

  /// 获取我的家庭列表
  /// 
  /// 返回：用户所属的所有家庭列表
  Future<ApiResponseWithStringCode<List<Family>>> getMyFamilies() async {
    try {
      final response = await _httpClient.getWithStringCode<List<Family>>(
        '/api/families/my',
        fromJson: (json) {
          if (json is List) {
            return json.map((item) => Family.fromJson(item as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 创建家庭
  /// 
  /// 参数：
  /// - [familyName] 家庭名称
  /// - [familyAvatar] 家庭头像 URL（可选）
  /// - [myNickname] 我在家庭中的昵称
  /// 
  /// 返回：创建的家庭信息
  Future<ApiResponseWithStringCode<Family>> createFamily({
    required String familyName,
    String? familyAvatar,
    required String myNickname,
  }) async {
    try {
      final request = {
        'familyName': familyName,
        if (familyAvatar != null) 'familyAvatar': familyAvatar,
        'my_nickname': myNickname,
      };

      final response = await _httpClient.postWithStringCode<Family>(
        '/api/families',
        data: request,
        fromJson: (json) => Family.fromJson(json as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 加入家庭
  /// 
  /// 参数：
  /// - [inviteCode] 邀请码
  /// - [nickname] 在家庭中的昵称
  /// 
  /// 返回：加入的家庭和成员信息
  Future<ApiResponseWithStringCode<JoinFamilyResponse>> joinFamily({
    required String inviteCode,
    required String nickname,
  }) async {
    try {
      final request = {
        'invite_code': inviteCode,
        'nickname': nickname,
      };

      final response = await _httpClient.postWithStringCode<JoinFamilyResponse>(
        '/api/families/join',
        data: request,
        fromJson: (json) => JoinFamilyResponse.fromJson(json as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 解散家庭
  /// 
  /// 参数：
  /// - [familyId] 家庭 ID
  /// 
  /// 返回：删除结果
  Future<ApiResponseWithStringCode<void>> deleteFamily({
    required String familyId,
  }) async {
    try {
      final response = await _httpClient.deleteWithStringCode<void>(
        '/api/families/$familyId',
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 退出家庭
  /// 
  /// 参数：
  /// - [familyId] 家庭 ID
  /// 
  /// 返回：退出结果
  Future<ApiResponseWithStringCode<void>> leaveFamily({
    required String familyId,
  }) async {
    try {
      final response = await _httpClient.postWithStringCode<void>(
        '/api/families/$familyId/leave',
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 切换家庭
  /// 
  /// 参数：
  /// - [familyId] 要切换到的家庭 ID
  /// 
  /// 返回：切换后的家庭信息
  Future<ApiResponseWithStringCode<Family>> switchFamily({
    required String familyId,
  }) async {
    try {
      final request = {
        'familyId': familyId,
      };

      final response = await _httpClient.postWithStringCode<Family>(
        '/api/families/switch',
        data: request,
        fromJson: (json) {
          if (json is Map<String, dynamic> && json['family'] != null) {
            return Family.fromJson(json['family'] as Map<String, dynamic>);
          }
          return Family.fromJson(json as Map<String, dynamic>);
        },
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 生成家庭邀请码
  /// 
  /// 参数：
  /// - [familyId] 家庭 ID
  /// 
  /// 返回：生成的邀请码
  Future<ApiResponseWithStringCode<String>> generateInviteCode({
    required String familyId,
  }) async {
    try {
      final response = await _httpClient.postWithStringCode<String>(
        '/api/families/$familyId/invite-code',
        fromJson: (json) {
          if (json is Map<String, dynamic> && json['invite_code'] != null) {
            return json['invite_code'] as String;
          }
          return '';
        },
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 获取家庭详情
  /// 
  /// 参数：
  /// - [familyId] 家庭 ID
  /// 
  /// 返回：家庭详细信息
  Future<ApiResponseWithStringCode<Family>> getFamilyDetail({
    required String familyId,
  }) async {
    try {
      final response = await _httpClient.getWithStringCode<Family>(
        '/api/families/$familyId',
        fromJson: (json) => Family.fromJson(json as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 更新家庭信息
  /// 
  /// 参数：
  /// - [familyId] 家庭 ID
  /// - [familyName] 家庭名称（可选）
  /// - [familyAvatar] 家庭头像 URL（可选）
  /// 
  /// 返回：更新后的家庭信息
  Future<ApiResponseWithStringCode<Family>> updateFamily({
    required String familyId,
    String? familyName,
    String? familyAvatar,
  }) async {
    try {
      final request = <String, dynamic>{};
      if (familyName != null) request['familyName'] = familyName;
      if (familyAvatar != null) request['familyAvatar'] = familyAvatar;

      final response = await _httpClient.putWithStringCode<Family>(
        '/api/families/$familyId',
        data: request,
        fromJson: (json) => Family.fromJson(json as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 获取家庭成员列表
  /// 
  /// 参数：
  /// - [familyId] 家庭 ID
  /// 
  /// 返回：家庭成员列表
  Future<ApiResponseWithStringCode<List<FamilyMember>>> getFamilyMembers({
    required String familyId,
  }) async {
    try {
      final response = await _httpClient.getWithStringCode<List<FamilyMember>>(
        '/api/families/$familyId/members',
        fromJson: (json) {
          if (json is List) {
            return json.map((item) => FamilyMember.fromJson(item as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 更新我在家庭中的昵称
  /// 
  /// 参数：
  /// - [familyId] 家庭 ID
  /// - [nickname] 新昵称
  /// 
  /// 返回：更新后的成员信息
  Future<ApiResponseWithStringCode<FamilyMember>> updateMyNickname({
    required String familyId,
    required String nickname,
  }) async {
    try {
      final request = {
        'nickname': nickname,
      };

      final response = await _httpClient.putWithStringCode<FamilyMember>(
        '/api/families/$familyId/my-nickname',
        data: request,
        fromJson: (json) => FamilyMember.fromJson(json as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 更新成员在家庭中的角色
  /// 
  /// 参数：
  /// - [familyId] 家庭 ID
  /// - [memberId] 成员 ID
  /// - [role] 新角色
  /// 
  /// 返回：更新结果
  Future<ApiResponseWithStringCode<void>> updateMemberRole({
    required String familyId,
    required String memberId,
    required String role,
  }) async {
    try {
      final request = {
        'role': role,
      };

      final response = await _httpClient.putWithStringCode<void>(
        '/api/families/$familyId/members/$memberId/role',
        data: request,
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 移除家庭成员
  /// 
  /// 参数：
  /// - [familyId] 家庭 ID
  /// - [memberId] 成员 ID
  /// 
  /// 返回：删除结果
  Future<ApiResponseWithStringCode<void>> removeFamilyMember({
    required String familyId,
    required String memberId,
  }) async {
    try {
      final response = await _httpClient.deleteWithStringCode<void>(
        '/api/families/$familyId/members/$memberId',
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 获取待审核成员列表
  /// 
  /// 参数：
  /// - [familyId] 家庭 ID
  /// 
  /// 返回：待审核的家庭成员列表
  Future<ApiResponseWithStringCode<List<FamilyMember>>> getPendingMembers({
    required String familyId,
  }) async {
    try {
      final response = await _httpClient.getWithStringCode<List<FamilyMember>>(
        '/api/families/$familyId/members/pending',
        fromJson: (json) {
          if (json is List) {
            return json.map((item) => FamilyMember.fromJson(item as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 审核成员申请
  /// 
  /// 参数：
  /// - [familyId] 家庭 ID
  /// - [memberId] 成员 ID
  /// - [action] 审核操作（approve: 同意, reject: 拒绝）
  /// 
  /// 返回：审核结果
  Future<ApiResponseWithStringCode<void>> auditMember({
    required String familyId,
    required String memberId,
    required String action,
  }) async {
    try {
      final request = {
        'action': action,
      };

      final response = await _httpClient.putWithStringCode<void>(
        '/api/families/$familyId/members/$memberId/audit',
        data: request,
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }
}
