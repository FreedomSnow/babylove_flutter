import 'package:babylove_flutter/models/user_model.dart';
import 'package:babylove_flutter/models/family_model.dart';
import 'package:babylove_flutter/models/care_receiver_model.dart';

/// 全局应用状态服务
/// 用于存储和访问应用运行期间的全局数据
class AppStateService {
  // 单例模式
  static final AppStateService _instance = AppStateService._internal();
  factory AppStateService() => _instance;
  AppStateService._internal();

  // 当前用户信息
  User? _currentUser;

  // 最近访问的家庭
  Family? _lastFamily;

  // 最近访问的护理对象
  CareReceiver? _lastCareReceiver;

  /// 获取当前用户
  User? get currentUser => _currentUser;

  /// 获取最近访问的家庭
  Family? get lastFamily => _lastFamily;

  /// 获取最近访问的护理对象
  CareReceiver? get lastCareReceiver => _lastCareReceiver;

  /// 设置当前用户
  void setCurrentUser(User? user) {
    _currentUser = user;
  }

  /// 设置最近访问的家庭
  void setLastFamily(Family? family) {
    _lastFamily = family;
  }

  /// 设置最近访问的护理对象
  void setLastCareReceiver(CareReceiver? careReceiver) {
    _lastCareReceiver = careReceiver;
  }

  /// 更新登录数据
  void updateLoginData({
    User? user,
    Family? lastFamily,
    CareReceiver? lastCareReceiver,
  }) {
    if (user != null) {
      _currentUser = user;
    }
    if (lastFamily != null) {
      _lastFamily = lastFamily;
    }
    if (lastCareReceiver != null) {
      _lastCareReceiver = lastCareReceiver;
    }
  }

  /// 清除所有数据
  void clear() {
    _currentUser = null;
    _lastFamily = null;
    _lastCareReceiver = null;
  }

  /// 检查是否有家庭和护理对象
  bool get hasCompletedSetup {
    return _lastFamily != null && _lastCareReceiver != null;
  }
}
