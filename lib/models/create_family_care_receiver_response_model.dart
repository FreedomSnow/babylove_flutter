import 'package:babylove_flutter/models/family_model.dart';
import 'package:babylove_flutter/models/care_receiver_model.dart';

/// 创建家庭和被照顾者响应模型
class CreateFamilyCareReceiverResponse {
  final Family family;
  final CareReceiver careReceiver;

  CreateFamilyCareReceiverResponse({
    required this.family,
    required this.careReceiver,
  });

  /// 从 JSON 创建实例
  factory CreateFamilyCareReceiverResponse.fromJson(Map<String, dynamic> json) {
    return CreateFamilyCareReceiverResponse(
      family: Family.fromJson(json['family'] as Map<String, dynamic>),
      careReceiver: CareReceiver.fromJson(json['careReceiver'] as Map<String, dynamic>),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'family': family.toJson(),
      'careReceiver': careReceiver.toJson(),
    };
  }

  @override
  String toString() {
    return 'CreateFamilyCareReceiverResponse(family: $family, careReceiver: $careReceiver)';
  }
}
