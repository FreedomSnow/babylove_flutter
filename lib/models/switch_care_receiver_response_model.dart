import 'package:babylove_flutter/models/family_model.dart';
import 'package:babylove_flutter/models/care_receiver_model.dart';

/// 切换被照顾者响应模型
class SwitchCareReceiverResponse {
  final Family family;
  final CareReceiver currentCareReceiver;

  SwitchCareReceiverResponse({
    required this.family,
    required this.currentCareReceiver,
  });

  /// 从 JSON 创建实例
  factory SwitchCareReceiverResponse.fromJson(Map<String, dynamic> json) {
    return SwitchCareReceiverResponse(
      family: Family.fromJson(json['family'] as Map<String, dynamic>),
      currentCareReceiver: CareReceiver.fromJson(json['current_care_receiver'] as Map<String, dynamic>),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'family': family.toJson(),
      'current_care_receiver': currentCareReceiver.toJson(),
    };
  }

  @override
  String toString() {
    return 'SwitchCareReceiverResponse(family: $family, currentCareReceiver: $currentCareReceiver)';
  }
}
