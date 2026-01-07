import 'package:flutter/material.dart';
import '../models/family_model.dart';

/// 家庭详情页面
class FamilyDetailPage extends StatefulWidget {
  final FamilyModel family;

  const FamilyDetailPage({super.key, required this.family});

  @override
  State<FamilyDetailPage> createState() => _FamilyDetailPageState();
}

class _FamilyDetailPageState extends State<FamilyDetailPage> {
  String _getChineseZodiac(DateTime birthDate) {
    const zodiacAnimals = [
      '猴',
      '鸡',
      '狗',
      '猪',
      '鼠',
      '牛',
      '虎',
      '兔',
      '龙',
      '蛇',
      '马',
      '羊',
    ];
    return zodiacAnimals[birthDate.year % 12];
  }

  String _getGenderText(String gender) {
    switch (gender) {
      case 'male':
        return '男';
      case 'female':
        return '女';
      default:
        return '未知';
    }
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'owner':
        return '创建者';
      case 'admin':
        return '管理员';
      case 'member':
        return '成员';
      default:
        return '未知';
    }
  }

  void _addCareReceiver() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('添加被照顾者功能开发中')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.family.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 家庭信息卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: widget.family.avatarUrl != null
                        ? NetworkImage(widget.family.avatarUrl!)
                        : null,
                    child: widget.family.avatarUrl == null
                        ? const Icon(Icons.family_restroom, size: 40)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.family.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '创建于 ${widget.family.createdAt.year}年${widget.family.createdAt.month}月',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 被照顾者列表
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '被照顾者',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('添加'),
                onPressed: _addCareReceiver,
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (widget.family.careReceivers.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text('暂无被照顾者', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            )
          else
            ...widget.family.careReceivers.map((careReceiver) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: careReceiver.avatar != null
                        ? NetworkImage(careReceiver.avatar!)
                        : null,
                    child: careReceiver.avatar == null
                        ? const Icon(Icons.person, size: 28)
                        : null,
                  ),
                  title: Text(
                    careReceiver.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${careReceiver.birthDate != null ? DateTime.fromMillisecondsSinceEpoch(careReceiver.birthDate! * 1000).year : ''}年${careReceiver.birthDate != null ? DateTime.fromMillisecondsSinceEpoch(careReceiver.birthDate! * 1000).month : ''}月 · '
                      '${careReceiver.birthDate != null ? _getChineseZodiac(DateTime.fromMillisecondsSinceEpoch(careReceiver.birthDate! * 1000)) : ''} · '
                      '${_getGenderText(careReceiver.gender ?? 'unknown')}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('被照顾者详情功能开发中')),
                    );
                  },
                ),
              );
            }).toList(),

          const SizedBox(height: 24),

          // 家庭成员列表
          const Text(
            '家庭成员',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          if (widget.family.members.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text('暂无成员', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            )
          else
            ...widget.family.members.map((member) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: member.avatarUrl != null
                        ? NetworkImage(member.avatarUrl!)
                        : null,
                    child: member.avatarUrl == null
                        ? const Icon(Icons.person, size: 24)
                        : null,
                  ),
                  title: Text(
                    member.nickname,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _getRoleText(member.role),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
