/// 家庭模型
class Family {
  final String id;
  final String name;

  Family({
    required this.id,
    required this.name,
  });

  /// 从 JSON 创建实例
  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'Family(id: $id, name: $name)';
  }
}
