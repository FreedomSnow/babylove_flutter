import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储服务
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _themeKey = 'app_theme';
  static const String _elderModeKey = 'elder_mode';
  SharedPreferences? _prefs;

  /// 初始化服务
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 保存 access token
  Future<bool> saveAccessToken(String token) async {
    if (_prefs == null) await init();
    return await _prefs!.setString(_accessTokenKey, token);
  }

  /// 获取 access token
  Future<String?> getAccessToken() async {
    if (_prefs == null) await init();
    return _prefs!.getString(_accessTokenKey);
  }

  /// 删除 access token
  Future<bool> removeAccessToken() async {
    if (_prefs == null) await init();
    return await _prefs!.remove(_accessTokenKey);
  }

  /// 保存 refresh token
  Future<bool> saveRefreshToken(String token) async {
    if (_prefs == null) await init();
    return await _prefs!.setString(_refreshTokenKey, token);
  }

  /// 获取 refresh token
  Future<String?> getRefreshToken() async {
    if (_prefs == null) await init();
    return _prefs!.getString(_refreshTokenKey);
  }

  /// 删除 refresh token
  Future<bool> removeRefreshToken() async {
    if (_prefs == null) await init();
    return await _prefs!.remove(_refreshTokenKey);
  }

  /// 删除所有 token
  Future<void> clearTokens() async {
    if (_prefs == null) await init();
    await _prefs!.remove(_accessTokenKey);
    await _prefs!.remove(_refreshTokenKey);
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
