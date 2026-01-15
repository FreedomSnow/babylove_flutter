import 'package:flutter/foundation.dart';
import 'package:babylove_flutter/services/family_service.dart';
import 'package:babylove_flutter/services/app_state_service.dart';
import 'package:babylove_flutter/services/auth_service.dart';

class InitialLoadService {
  /// 通用方法：获取我的家庭并根据 lastFamily 加载家庭数据，更新 AppStateService
  /// 返回 true 表示全部成功，false 表示任一步骤失败
  static Future<bool> loadUserFamiliesAndData() async {
    try {
      final authService = AuthService();
      final familyService = FamilyService();
      final appState = AppStateService();

      // 0. 先获取我的用户信息（me），若失败则视为未登录或需重新登录
      final meResp = await authService.getMe();
      if (!meResp.isSuccess || meResp.data == null) {
        return false;
      }

      // 更新全局登录数据
      final loginData = meResp.data!;
      appState.updateLoginData(
        user: loginData.user,
        lastFamily: loginData.lastFamily,
        lastCareReceiver: loginData.lastCareReceiver,
      );


      // 1. 获取我的家庭列表
      final familiesResp = await familyService.getMyFamilies();
      if (!familiesResp.isSuccess) {
        return false;
      }

      final families = familiesResp.data ?? [];
      appState.setMyFamilies(families);

      // 2. 如果有最近使用的家庭，则加载该家庭的成员和被照顾者数据
      if (appState.lastFamily != null) {
        final lastFamily = appState.lastFamily!;
        final dataResp = await familyService.loadFamilyData(familyId: lastFamily.id);
        if (!dataResp.isSuccess) {
          return false;
        }

        final fd = dataResp.data!;
        appState.updateFamilyMembersAndCareReceivers(
          familyId: lastFamily.id,
          careReceivers: fd.careReceivers,
          members: fd.members,
        );
      }

      return true;
    } catch (e) {
      debugPrint('Error loading families/data: $e');
      return false;
    }
  }
}
