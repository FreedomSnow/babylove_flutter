/// 照护对象模型
class CareReceiver {
  final String id;
  final String name;

  CareReceiver({
    required this.id,
    required this.name,
  });

  /// 从 JSON 创建实例
  factory CareReceiver.fromJson(Map<String, dynamic> json) {
    return CareReceiver(
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
    return 'CareReceiver(id: $id, name: $name)';
  }
}
