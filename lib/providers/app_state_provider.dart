import 'package:flutter/material.dart';

/// 全局应用状态管理，用于管理当前家庭和被照顾者
class AppStateProvider extends ChangeNotifier {
  String? _currentFamilyId;
  String? _currentCareReceiverId;

  String? get currentFamilyId => _currentFamilyId;
  String? get currentCareReceiverId => _currentCareReceiverId;

  void setCurrentFamily(String? familyId) {
    if (_currentFamilyId != familyId) {
      _currentFamilyId = familyId;
      notifyListeners();
    }
  }

  void setCurrentCareReceiver(String? careReceiverId) {
    if (_currentCareReceiverId != careReceiverId) {
      _currentCareReceiverId = careReceiverId;
      notifyListeners();
    }
  }

  void updateFamilyAndCareReceiver(String? familyId, String? careReceiverId) {
    bool changed = false;
    if (_currentFamilyId != familyId) {
      _currentFamilyId = familyId;
      changed = true;
    }
    if (_currentCareReceiverId != careReceiverId) {
      _currentCareReceiverId = careReceiverId;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }
}
