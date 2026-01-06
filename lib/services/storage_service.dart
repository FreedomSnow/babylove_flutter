import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储服务
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _tokenKey = 'auth_token';
  SharedPreferences? _prefs;

  /// 初始化服务
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 保存 token
  Future<bool> saveToken(String token) async {
    if (_prefs == null) await init();
    return await _prefs!.setString(_tokenKey, token);
  }

  /// 获取 token
  Future<String?> getToken() async {
    if (_prefs == null) await init();
    return _prefs!.getString(_tokenKey);
  }

  /// 删除 token
  Future<bool> removeToken() async {
    if (_prefs == null) await init();
    return await _prefs!.remove(_tokenKey);
  }

  /// 清除所有数据
  Future<bool> clearAll() async {
    if (_prefs == null) await init();
    return await _prefs!.clear();
  }
}
