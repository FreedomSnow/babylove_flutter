import 'package:babylove_flutter/core/network/network.dart';

/// API 服务基类
/// 所有 API 服务类都应该继承此类
abstract class BaseApiService {
  final HttpClient httpClient = HttpClient();
}

/// 用户 API 服务示例
class UserApiService extends BaseApiService {
  /// 用户登录
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String username,
    required String password,
  }) async {
    return await httpClient.post<Map<String, dynamic>>(
      '/api/user/login',
      data: {
        'username': username,
        'password': password,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// 用户注册
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String username,
    required String password,
    required String email,
  }) async {
    return await httpClient.post<Map<String, dynamic>>(
      '/api/user/register',
      data: {
        'username': username,
        'password': password,
        'email': email,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// 获取用户信息
  Future<ApiResponse<Map<String, dynamic>>> getUserInfo() async {
    return await httpClient.get<Map<String, dynamic>>(
      '/api/user/info',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// 更新用户信息
  Future<ApiResponse<Map<String, dynamic>>> updateUserInfo({
    required Map<String, dynamic> userData,
  }) async {
    return await httpClient.put<Map<String, dynamic>>(
      '/api/user/update',
      data: userData,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// 退出登录
  Future<ApiResponse<void>> logout() async {
    final response = await httpClient.post<void>('/api/user/logout');
    // 清除本地 token
    httpClient.clearToken();
    return response;
  }
}

/// 宝宝信息 API 服务示例
class BabyApiService extends BaseApiService {
  /// 获取宝宝列表
  Future<ApiResponse<List<Map<String, dynamic>>>> getBabyList() async {
    return await httpClient.get<List<Map<String, dynamic>>>(
      '/api/baby/list',
      fromJson: (json) => (json as List).cast<Map<String, dynamic>>(),
    );
  }

  /// 添加宝宝信息
  Future<ApiResponse<Map<String, dynamic>>> addBaby({
    required String name,
    required String birthday,
    required String gender,
  }) async {
    return await httpClient.post<Map<String, dynamic>>(
      '/api/baby/add',
      data: {
        'name': name,
        'birthday': birthday,
        'gender': gender,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// 更新宝宝信息
  Future<ApiResponse<Map<String, dynamic>>> updateBaby({
    required String babyId,
    required Map<String, dynamic> babyData,
  }) async {
    return await httpClient.put<Map<String, dynamic>>(
      '/api/baby/update/$babyId',
      data: babyData,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// 删除宝宝信息
  Future<ApiResponse<void>> deleteBaby(String babyId) async {
    return await httpClient.delete<void>('/api/baby/delete/$babyId');
  }
}

/// 记录 API 服务示例（成长记录、喂养记录等）
class RecordApiService extends BaseApiService {
  /// 获取记录列表（分页）
  Future<ApiResponse<Map<String, dynamic>>> getRecordList({
    required String babyId,
    required String recordType,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await httpClient.get<Map<String, dynamic>>(
      '/api/record/list',
      queryParameters: {
        'babyId': babyId,
        'recordType': recordType,
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// 添加记录
  Future<ApiResponse<Map<String, dynamic>>> addRecord({
    required String babyId,
    required String recordType,
    required Map<String, dynamic> recordData,
  }) async {
    return await httpClient.post<Map<String, dynamic>>(
      '/api/record/add',
      data: {
        'babyId': babyId,
        'recordType': recordType,
        ...recordData,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// 更新记录
  Future<ApiResponse<Map<String, dynamic>>> updateRecord({
    required String recordId,
    required Map<String, dynamic> recordData,
  }) async {
    return await httpClient.put<Map<String, dynamic>>(
      '/api/record/update/$recordId',
      data: recordData,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// 删除记录
  Future<ApiResponse<void>> deleteRecord(String recordId) async {
    return await httpClient.delete<void>('/api/record/delete/$recordId');
  }
}
