import 'package:flutter/material.dart';
import '../models/family_model.dart';
import '../services/family_service.dart';
import '../services/app_state_service.dart';

/// 家庭详情页面
class FamilyDetailPage extends StatefulWidget {
  final Family family;

  const FamilyDetailPage({super.key, required this.family});

  @override
  State<FamilyDetailPage> createState() => _FamilyDetailPageState();
}

class _FamilyDetailPageState extends State<FamilyDetailPage> {
  final FamilyService _familyService = FamilyService();
  final AppStateService _appState = AppStateService();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFamilyData();
  }

  /// 加载家庭成员和被照顾者列表
  Future<void> _loadFamilyData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // 调用通用的 loadFamilyData 方法
      final response = await _familyService.loadFamilyData(
        familyId: widget.family.id,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        // 更新 widget.family 对象
        widget.family.members = response.data!.members;
        widget.family.careReceivers = response.data!.careReceivers;

        // 更新 AppStateService 中的数据
        _updateAppState();

        setState(() {
          _isLoading = false;
        });
      } else {
        // 处理错误
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? '加载数据失败'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加载数据失败: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 更新 AppStateService 中的数据
  void _updateAppState() {
    _appState.updateFamilyMembersAndCareReceivers(
      familyId: widget.family.id,
      careReceivers: widget.family.careReceivers,
      members: widget.family.members,
    );
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
    // 显示加载状态
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.family.name)),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                    backgroundImage: widget.family.avatar != null && widget.family.avatar!.isNotEmpty
                        ? NetworkImage(widget.family.avatar!)
                        : null,
                    child: widget.family.avatar == null
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
                        // 创建时间由后端模型暂不提供，此处不展示
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
                    backgroundImage: careReceiver.avatar != null && careReceiver.avatar!.isNotEmpty
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
                      careReceiver.buildCareReceiverInfo(),
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
            }),

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
                    backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
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
            }),
        ],
      ),
    );
  }
}
