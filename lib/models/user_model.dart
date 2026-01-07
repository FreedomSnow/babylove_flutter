/// 用户模型
class User {
  final String id;
  final String? username;
  final String phone;
  final String nickname;
  final String? avatar;
  final int gender; // 0: 未知, 1: 男, 2: 女

  User({
    required this.id,
    this.username,
    required this.phone,
    required this.nickname,
    this.avatar,
    required this.gender,
  });

  /// 从 JSON 创建实例
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] as String?,
      phone: json['phone'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      avatar: json['avatar'] as String?,
      gender: json['gender'] as int? ?? 0,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phone': phone,
      'nickname': nickname,
      'avatar': avatar,
      'gender': gender,
    };
  }

  /// 获取性别文本
  String get genderText {
    switch (gender) {
      case 1:
        return '男';
      case 2:
        return '女';
      default:
        return '未知';
    }
  }

  /// 复制并修改部分属性
  User copyWith({
    String? id,
    String? username,
    String? phone,
    String? nickname,
    String? avatar,
    int? gender,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      gender: gender ?? this.gender,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, nickname: $nickname, phone: $phone)';
  }
}
