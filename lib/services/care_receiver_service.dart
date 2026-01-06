import 'package:babylove_flutter/core/network/network.dart';
import 'package:babylove_flutter/models/care_receiver_model.dart';
import 'package:babylove_flutter/models/switch_care_receiver_response_model.dart';
import 'package:babylove_flutter/models/create_family_care_receiver_response_model.dart';

/// 被照顾者 API 服务
class CareReceiverService {
  final HttpClient _httpClient = HttpClient();

  /// 创建被照顾者
  /// 
  /// 参数：
  /// - [familyId] 家庭 ID
  /// - [name] 被照顾者姓名
  /// - [gender] 性别（可选，例如："male", "female"）
  /// - [birthDate] 出生日期时间戳（可选）
  /// - [avatar] 头像 URL（可选）
  /// - [residence] 居住地（可选）
  /// - [phone] 电话号码（可选）
  /// - [emergencyContact] 紧急联系人信息（可选）
  /// - [medicalHistory] 病史（可选）
  /// - [allergies] 过敏信息（可选）
  /// - [remark] 备注（可选）
  /// - [customFields] 自定义字段列表（可选）
  /// 
  /// 返回：创建的被照顾者信息
  Future<ApiResponseWithStringCode<CareReceiver>> createCareReceiver({
    required String familyId,
    required String name,
    String? gender,
    int? birthDate,
    String? avatar,
    String? residence,
    String? phone,
    EmergencyContact? emergencyContact,
    String? medicalHistory,
    String? allergies,
    String? remark,
    List<CustomField>? customFields,
  }) async {
    try {
      final request = {
        'name': name,
        if (gender != null) 'gender': gender,
        if (birthDate != null) 'birth_date': birthDate,
        if (avatar != null) 'avatar': avatar,
        if (residence != null) 'residence': residence,
        if (phone != null) 'phone': phone,
        if (emergencyContact != null) 'emergency_contact': emergencyContact.toJson(),
        if (medicalHistory != null) 'medical_history': medicalHistory,
        if (allergies != null) 'allergies': allergies,
        if (remark != null) 'remark': remark,
        if (customFields != null)
          'custom_fields': customFields.map((field) => field.toJson()).toList(),
      };

      final response = await _httpClient.postWithStringCode<CareReceiver>(
        '/api/families/$familyId/care-receivers',
        data: request,
        fromJson: (json) => CareReceiver.fromJson(json as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 获取被照顾者列表
  /// 
  /// 参数：
  /// - [familyId] 家庭 ID
  /// - [keyword] 搜索关键词（可选）
  /// - [status] 状态筛选（可选，例如："active", "archived"）
  /// 
  /// 返回：被照顾者列表
  Future<ApiResponseWithStringCode<List<CareReceiver>>> getCareReceivers({
    required String familyId,
    String? keyword,
    String? status,
  }) async {
    try {
      // 构建查询参数
      final queryParams = <String, dynamic>{};
      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      // 构建 URL
      String url = '/api/families/$familyId/care-receivers';
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
            .join('&');
        url = '$url?$queryString';
      }

      final response = await _httpClient.getWithStringCode<List<CareReceiver>>(
        url,
        fromJson: (json) {
          if (json is List) {
            return json.map((item) => CareReceiver.fromJson(item as Map<String, dynamic>)).toList();
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

  /// 更新被照顾者信息
  /// 
  /// 参数：
  /// - [familyId] 家庭 ID
  /// - [careReceiverId] 被照顾者 ID
  /// - [careReceiver] 被照顾者信息对象
  /// 
  /// 返回：更新后的被照顾者信息
  Future<ApiResponseWithStringCode<CareReceiver>> updateCareReceiver({
    required String familyId,
    required String careReceiverId,
    required CareReceiver careReceiver,
  }) async {
    try {
      final response = await _httpClient.putWithStringCode<CareReceiver>(
        '/api/families/$familyId/care-receivers/$careReceiverId',
        data: careReceiver.toJson(),
        fromJson: (json) => CareReceiver.fromJson(json as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 切换被照顾者
  /// 
  /// 参数：
  /// - [familyId] 家庭 ID
  /// - [careReceiverId] 被照顾者 ID
  /// 
  /// 返回：包含家庭信息和当前被照顾者信息的响应
  Future<ApiResponseWithStringCode<SwitchCareReceiverResponse>> switchCareReceiver({
    required String familyId,
    required String careReceiverId,
  }) async {
    try {
      final request = {
        'careReceiverId': careReceiverId,
      };

      final response = await _httpClient.postWithStringCode<SwitchCareReceiverResponse>(
        '/api/families/$familyId/care-receivers/switch',
        data: request,
        fromJson: (json) => SwitchCareReceiverResponse.fromJson(json as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }

  /// 创建家庭和被照顾者
  /// 
  /// 参数：
  /// - [familyName] 家庭名称
  /// - [familyAvatar] 家庭头像 URL（可选）
  /// - [myNickname] 我在家庭中的昵称
  /// - [careReceiver] 被照顾者信息对象
  /// 
  /// 返回：包含创建的家庭和被照顾者信息的响应
  Future<ApiResponseWithStringCode<CreateFamilyCareReceiverResponse>> createFamilyWithCareReceiver({
    required String familyName,
    String? familyAvatar,
    required String myNickname,
    required CareReceiver careReceiver,
  }) async {
    try {
      // 构建请求数据，包含家庭信息和被照顾者信息
      final careReceiverJson = careReceiver.toJson();
      
      final request = {
        'family_name': familyName,
        if (familyAvatar != null) 'family_avatar': familyAvatar,
        'my_nickname': myNickname,
        // 添加被照顾者的所有字段
        ...careReceiverJson,
      };

      final response = await _httpClient.postWithStringCode<CreateFamilyCareReceiverResponse>(
        '/api/care-receivers',
        data: request,
        fromJson: (json) => CreateFamilyCareReceiverResponse.fromJson(json as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      // 重新抛出异常
      rethrow;
    }
  }
}
