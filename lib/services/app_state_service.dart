import 'package:babylove_flutter/models/user_model.dart';
import 'package:babylove_flutter/models/family_model.dart';
import 'package:babylove_flutter/models/care_receiver_model.dart';
import 'package:flutter/foundation.dart';

/// 全局应用状态服务
/// 用于存储和访问应用运行期间的全局数据
class AppStateService with ChangeNotifier {
  // 单例模式
  static final AppStateService _instance = AppStateService._internal();
  factory AppStateService() => _instance;
  AppStateService._internal();

  // 当前用户信息
  User? _currentUser;

  // 我的家庭列表（缓存）
  List<Family> _myFamilies = [];

  // 最近访问的家庭
  Family? _lastFamily;

  /// 获取当前用户
  User? get currentUser => _currentUser;

  /// 获取最近访问的家庭
  Family? get lastFamily => _lastFamily;

  /// 获取最近访问的护理对象
  CareReceiver? get lastCareReceiver => _lastFamily?.lastCareReceiver;

  /// 获取我的家庭列表
  List<Family> get myFamilies => _myFamilies;

  /// 设置当前用户
  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  /// 设置最近访问的家庭
  void setLastFamily(Family? family) {
    _lastFamily = family;
    notifyListeners();
  }

  /// 设置最近访问的护理对象（赋值到最近家庭）
  void setLastCareReceiver(CareReceiver? careReceiver) {
    if (_lastFamily != null) {
      _lastFamily!.lastCareReceiver = careReceiver;
      notifyListeners();
    }
  }

  /// 设置我的家庭列表，并尽量保持当前选择的家庭与被照顾者
  void setMyFamilies(List<Family> families) {
    _myFamilies = families;

    if (_myFamilies.isEmpty) {
      _lastFamily = null;
      notifyListeners();
      return;
    }

    // 若已有最近家庭，则尝试在新列表中找到它并复用引用
    if (_lastFamily != null) {
      final matched = _myFamilies.firstWhere(
        (f) => f.id == _lastFamily!.id,
        orElse: () => _myFamilies.first,
      );
      _lastFamily = matched;

      // 校正最近护理对象：若不存在于该家庭，则回退到首个（若有）
      final currentCr = _lastFamily!.lastCareReceiver;
      if (currentCr == null ||
          !_lastFamily!.careReceivers.any((cr) => cr.id == currentCr.id)) {
        _lastFamily!.lastCareReceiver = _lastFamily!.careReceivers.isNotEmpty
            ? _lastFamily!.careReceivers.first
            : null;
      }
    } else {
      // 没有最近家庭，则默认第一个，并设置其默认护理对象
      _lastFamily = _myFamilies.first;
      _lastFamily!.lastCareReceiver = _lastFamily!.careReceivers.isNotEmpty
          ? _lastFamily!.careReceivers.first
          : null;
    }

    notifyListeners();
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
      if (_lastFamily != null) {
        _lastFamily!.lastCareReceiver = lastCareReceiver;
      }
    }

    notifyListeners();
  }

  /// 清除所有数据
  void clear() {
    _currentUser = null;
    _myFamilies = [];
    _lastFamily = null;
    notifyListeners();
  }

  /// 检查是否有家庭和护理对象
  bool get hasCompletedSetup =>
      _lastFamily != null && _lastFamily!.lastCareReceiver != null;
}
