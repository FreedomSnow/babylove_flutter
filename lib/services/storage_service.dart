import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储服务
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _themeKey = 'app_theme';
  static const String _elderModeKey = 'elder_mode';
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

  /// 保存主题
  Future<bool> saveTheme(int themeIndex) async {
    if (_prefs == null) await init();
    return await _prefs!.setInt(_themeKey, themeIndex);
  }

  /// 获取主题
  Future<int?> getTheme() async {
    if (_prefs == null) await init();
    return _prefs!.getInt(_themeKey);
  }

  /// 保存老年模式
  Future<bool> saveElderMode(bool enabled) async {
    if (_prefs == null) await init();
    return await _prefs!.setBool(_elderModeKey, enabled);
  }

  /// 获取老年模式
  Future<bool> getElderMode() async {
    if (_prefs == null) await init();
    return _prefs!.getBool(_elderModeKey) ?? false;
  }
}
