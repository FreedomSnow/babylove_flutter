import 'package:flutter/rendering.dart';

import '../core/utils.dart';

/// 紧急联系人模型
class EmergencyContact {
  final String name;
  final String phone;
  final String relation;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.relation,
  });

  /// 从 JSON 创建实例
  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      relation: json['relation'] as String? ?? '',
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'phone': phone, 'relation': relation};
  }

  @override
  String toString() {
    return 'EmergencyContact(name: $name, phone: $phone, relation: $relation)';
  }
}

/// 自定义字段模型
class CustomField {
  final String fieldName;
  final String fieldValue;
  final String fieldType;

  CustomField({
    required this.fieldName,
    required this.fieldValue,
    required this.fieldType,
  });

  /// 从 JSON 创建实例
  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(
      fieldName: json['field_name'] as String? ?? '',
      fieldValue: json['field_value'] as String? ?? '',
      fieldType: json['field_type'] as String? ?? 'text',
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'field_name': fieldName,
      'field_value': fieldValue,
      'field_type': fieldType,
    };
  }

  @override
  String toString() {
    return 'CustomField(fieldName: $fieldName, fieldValue: $fieldValue, fieldType: $fieldType)';
  }
}

/// 照护对象模型
class CareReceiver {
  final String id;
  final String name;
  final String? gender;
  final String? birthDate; // 格式: YYYY-MM-DD
  final String? avatar;
  final String? residence;
  final String? phone;
  final EmergencyContact? emergencyContact;
  final String? medicalHistory;
  final String? allergies;
  final String? remark;
  final List<CustomField>? customFields;

  CareReceiver({
    required this.id,
    required this.name,
    this.gender,
    this.birthDate,
    this.avatar,
    this.residence,
    this.phone,
    this.emergencyContact,
    this.medicalHistory,
    this.allergies,
    this.remark,
    this.customFields,
  });

  /// 从 JSON 创建实例
  factory CareReceiver.fromJson(Map<String, dynamic> json) {
    // 解析 birth_date：支持 UTC 毫秒或 ISO8601/日期字符串
    final String? birthDateStr = AppUtils.formatUtcOrIsoToYMD(json['birth_date']);

    final String? avatarRaw = json['avatar'] as String?;
    final String avatarValue = (avatarRaw != null && avatarRaw.trim().isNotEmpty)
        ? avatarRaw
        : 'resource:///dependent/default.png';

    return CareReceiver(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      gender: AppUtils.getGenderTextFromInt(() {
        final g = json['gender'];
        if (g is int) return g;
        if (g is String) return int.tryParse(g);
        return null;
      }()),
      birthDate: birthDateStr,
      avatar: avatarValue,
      residence: json['residence'] as String?,
      phone: json['phone'] as String?,
      emergencyContact: json['emergency_contact'] != null
          ? EmergencyContact.fromJson(
              json['emergency_contact'] as Map<String, dynamic>,
            )
          : null,
      medicalHistory: json['medical_history'] as String?,
      allergies: json['allergies'] as String?,
      remark: json['remark'] as String?,
      customFields: json['custom_fields'] != null
          ? (json['custom_fields'] as List)
                .map(
                  (item) => CustomField.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': AppUtils.getGenderIntFromText(gender),
      'birth_date': AppUtils.ymdToUtcMillis(birthDate),
      if (avatar != null) 'avatar': avatar,
      if (residence != null) 'residence': residence,
      if (phone != null) 'phone': phone,
      if (emergencyContact != null)
        'emergency_contact': emergencyContact!.toJson(),
      if (medicalHistory != null) 'medical_history': medicalHistory,
      if (allergies != null) 'allergies': allergies,
      if (remark != null) 'remark': remark,
      if (customFields != null)
        'custom_fields': customFields!.map((field) => field.toJson()).toList(),
    };
  }

  /// 构建被照顾者完整信息字符串
  ///
  /// 返回：格式化的信息字符串，例如：1941年11月25日 · 蛇 · 84岁 · 女
  String buildCareReceiverInfo() {
    final birthDateTime = AppUtils.dateTimeFromYMD(birthDate);
    if (birthDateTime == null) {
      return gender != null ? "未知出生日期 · ${gender!}" : '未知出生日期';
    }

    final ageStr = AppUtils.calculateAge(birthDateTime);
    final zodiac = AppUtils.getChineseZodiac(birthDateTime);

    return '${AppUtils.formatDateChinese(birthDateTime)} · $zodiac · $ageStr · ${gender != null ? gender! : ""}';
  }

  @override
  String toString() {
    return 'CareReceiver(id: $id, name: $name, gender: $gender, birthDate: $birthDate, avatar: $avatar, residence: $residence, phone: $phone, emergencyContact: $emergencyContact, medicalHistory: $medicalHistory, allergies: $allergies, remark: $remark, customFields: $customFields)';
  }
}
