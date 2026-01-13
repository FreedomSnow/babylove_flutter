import 'package:flutter/material.dart';
import '../core/image_utils.dart';
import '../widgets/asset_image_picker.dart';
import '../models/care_receiver_model.dart';
import '../models/family_model.dart';
import '../models/family_member_model.dart';
import '../services/family_service.dart';
import '../services/app_state_service.dart';
import '../services/care_receiver_service.dart';

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
  final CareReceiverService _careReceiverService = CareReceiverService();
  
  bool _isLoading = false;

  // 可编辑的展示数据（避免直接修改 widget.family，因为 model 字段是 final）
  late String _displayFamilyName;
  String? _displayFamilyAvatar;

  // 当前用户在该家庭中的成员对象（若存在）
  FamilyMember? _myMember;
  String? _editedMyNickname;

  @override
  void initState() {
    super.initState();
    _loadFamilyData();
    _displayFamilyName = widget.family.name;
    _displayFamilyAvatar = widget.family.avatar;

    // 尝试查找当前用户在该家庭中的 member（若 appState 已有 currentUser）
    final currentUserId = _appState.currentUser?.id;
    if (currentUserId != null) {
      try {
        _myMember = widget.family.members.firstWhere((m) => m.userId == currentUserId);
        _editedMyNickname = _myMember?.nickname;
      } catch (_) {
        _myMember = null;
      }
    }
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

  bool get _canEdit {
    return !widget.family.isVisitor;
  }

  bool get _isPrimary => widget.family.isPrimaryCaregiver;

  bool get _isAssistant => widget.family.isAssistantCaregiver;

  bool get _isCaregiver => widget.family.isCaregiver;

  Future<void> _onLeaveFamily() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出家庭'),
        content: const Text('确定要退出该家庭吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('退出')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final resp = await _familyService.leaveFamily(familyId: widget.family.id);
      if (resp.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已退出家庭')));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp.message ?? '退出失败'), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('退出失败: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onDestroyFamily() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('销毁家庭'),
        content: const Text('销毁家庭将删除所有数据，且无法恢复，确认继续吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('销毁', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final resp = await _familyService.deleteFamily(familyId: widget.family.id);
      if (resp.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('家庭已销毁')));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp.message ?? '销毁失败'), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('销毁失败: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changeMemberRole(FamilyMember member) async {
    // 仅 primary 可用
    final newRole = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String selected = member.role;
        return AlertDialog(
          title: const Text('修改成员角色'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(value: 'primary_caregiver', groupValue: selected, title: const Text('主负责人'), onChanged: (v) { selected = v!; Navigator.of(ctx).pop(selected); }),
              RadioListTile<String>(value: 'assistant_caregiver', groupValue: selected, title: const Text('助理'), onChanged: (v) { selected = v!; Navigator.of(ctx).pop(selected); }),
              RadioListTile<String>(value: 'caregiver', groupValue: selected, title: const Text('照护者'), onChanged: (v) { selected = v!; Navigator.of(ctx).pop(selected); }),
            ],
          ),
        );
      },
    );

    if (newRole == null || newRole == member.role) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final resp = await _familyService.updateMemberRole(familyId: widget.family.id, memberId: member.id, role: newRole);
      if (resp.isSuccess) {
        // 本地替换
        final idx = widget.family.members.indexWhere((m) => m.id == member.id);
        if (idx >= 0) {
          widget.family.members[idx] = FamilyMember(
            id: member.id,
            familyId: member.familyId,
            userId: member.userId,
            role: newRole,
            nickname: member.nickname,
            status: member.status,
            avatarUrl: member.avatarUrl,
          );
        }
        _updateAppState();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('成员角色已修改')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp.message ?? '修改失败'), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('修改失败: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeMember(FamilyMember member) async {
    if (member.userId == _appState.currentUser?.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('不能删除自己')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('移除成员'),
        content: Text('确定要移除 ${member.nickname} 吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('移除', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final resp = await _familyService.removeFamilyMember(familyId: widget.family.id, memberId: member.id);
      if (resp.isSuccess) {
        widget.family.members.removeWhere((m) => m.id == member.id);
        _updateAppState();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('成员已移除')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp.message ?? '移除失败'), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('移除失败: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSelfTag() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '我',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue),
      ),
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

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  Future<void> _handleFamilyInfoTap() async {
    if (!_isPrimary) {
      return;
    }

    final nameController = TextEditingController(text: _displayFamilyName);
    String? tempAvatar = _displayFamilyAvatar;

    final result = await showModalBottomSheet<Map<String, String?>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('编辑家庭信息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              final resource = await showAssetImagePicker(
                                context,
                                subdir: 'family',
                                title: '选择家庭头像',
                                initialSelectedResource: tempAvatar,
                              );
                              if (resource != null) {
                                setModalState(() => tempAvatar = resource);
                              }
                            },
                            child: CircleAvatar(
                              radius: 32,
                              backgroundImage: AppImageUtils.imageProviderFor(
                                tempAvatar,
                                defaultResource: 'resource:///family/family0.png',
                              ),
                              child: AppImageUtils.imageProviderFor(
                                        tempAvatar,
                                        defaultResource: 'resource:///family/family0.png',
                                      ) ==
                                      null
                                  ? const Icon(Icons.family_restroom, size: 32)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(labelText: '家庭名称'),
                              autofocus: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop({
                              'name': nameController.text.trim(),
                              'avatar': tempAvatar,
                            });
                          },
                          child: const Text('保存'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (result == null) return;

    final newName = result['name']?.trim() ?? '';
    final newAvatar = result['avatar'];
    if (newName.isEmpty) {
      _showErrorMessage('家庭名称不能为空');
      return;
    }

    // 若名称与头像均未变化，则不调用更新，仅关闭编辑页
    if (newName == _displayFamilyName && (newAvatar ?? '') == (_displayFamilyAvatar ?? '')) {
      return;
    }

    await _updateFamilyInfo(newName, newAvatar);
  }

  Future<void> _updateFamilyInfo(String newName, String? newAvatar) async {
    // 若内容未变，直接返回（调用方的编辑页已关闭）
    if (newName == _displayFamilyName && (newAvatar ?? '') == (_displayFamilyAvatar ?? '')) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final resp = await _familyService.updateFamily(
        familyId: widget.family.id,
        familyName: newName,
        familyAvatar: newAvatar,
      );

      if (resp.isSuccess) {
        setState(() {
          _displayFamilyName = resp.data?.name ?? newName;
          _displayFamilyAvatar = resp.data?.avatar ?? newAvatar;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('家庭信息已保存')));
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp.message ?? '保存失败'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateMyNickname(String newNickname) async {
    if (_myMember == null) return;
    if (newNickname.trim().isEmpty) {
      _showErrorMessage('昵称不能为空');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final resp = await _familyService.updateMyNickname(
        familyId: widget.family.id,
        nickname: newNickname.trim(),
      );
      if (resp.isSuccess) {
        final updated = resp.data!;
        final idx = widget.family.members.indexWhere((m) => m.id == updated.id);
        if (idx >= 0) {
          widget.family.members[idx] = updated;
        }
        _myMember = updated;
        _editedMyNickname = updated.nickname;
        _updateAppState();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('我的昵称已保存')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp.message ?? '保存失败'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCareReceiverTap(CareReceiver careReceiver) async {
    if (!_isPrimary) {
      _showErrorMessage('仅家庭主负责人可编辑被照顾者');
      return;
    }

    final controller = TextEditingController(text: careReceiver.name);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('编辑被照顾者', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(labelText: '昵称'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
                      child: const Text('保存'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (result == null || result.isEmpty) return;
    await _updateCareReceiver(careReceiver, result);
  }

  Future<void> _updateCareReceiver(CareReceiver careReceiver, String newName) async {
    setState(() => _isLoading = true);
    try {
      final updated = CareReceiver(
        id: careReceiver.id,
        name: newName,
        gender: careReceiver.gender,
        birthDate: careReceiver.birthDate,
        avatar: careReceiver.avatar,
        residence: careReceiver.residence,
        phone: careReceiver.phone,
        emergencyContact: careReceiver.emergencyContact,
        medicalHistory: careReceiver.medicalHistory,
        allergies: careReceiver.allergies,
        remark: careReceiver.remark,
        customFields: careReceiver.customFields,
      );

      final resp = await _careReceiverService.updateCareReceiver(
        familyId: widget.family.id,
        careReceiverId: careReceiver.id,
        careReceiver: updated,
      );

      if (resp.isSuccess) {
        final idx = widget.family.careReceivers.indexWhere((c) => c.id == careReceiver.id);
        if (idx >= 0) {
          widget.family.careReceivers[idx] = resp.data!;
        }
        _updateAppState();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('被照顾者信息已保存')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp.message ?? '保存失败'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleMemberTap(FamilyMember member) async {
    final isMe = member.userId == _appState.currentUser?.id;
    if (isMe) {
      final controller = TextEditingController(text: member.nickname);
      final result = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('编辑我的昵称', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(labelText: '昵称'),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
                        child: const Text('保存'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      if (result != null && result.isNotEmpty) {
        await _updateMyNickname(result);
      }
      return;
    }

    if (!_isPrimary) {
      _showErrorMessage('仅家庭主负责人可管理其他成员');
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('管理 ${member.nickname}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('修改角色'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _changeMemberRole(member);
                  },
                ),
                if (!isMe)
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text('删除成员'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _removeMember(member);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 显示加载状态
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(_displayFamilyName)),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_displayFamilyName),
        actions: [
          // 角色相关更多菜单
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'leave') _onLeaveFamily();
              if (v == 'destroy') _onDestroyFamily();
              if (v == 'invite') ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('邀请成员功能开发中')));
            },
            itemBuilder: (ctx) {
              final items = <PopupMenuEntry<String>>[];
              if (_isPrimary) {
                items.add(const PopupMenuItem(value: 'invite', child: Text('邀请成员')));
                items.add(const PopupMenuItem(value: 'destroy', child: Text('销毁家庭')));
              } else if (_isAssistant || _isCaregiver) {
                items.add(const PopupMenuItem(value: 'leave', child: Text('退出家庭')));
              }
              return items;
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 家庭信息卡片
          Card(
            child: InkWell(
              onTap: _handleFamilyInfoTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AppImageUtils.imageProviderFor(
                        _displayFamilyAvatar,
                        defaultResource: 'resource:///family/family0.png',
                      ),
                      child: AppImageUtils.imageProviderFor(
                                _displayFamilyAvatar,
                                defaultResource: 'resource:///family/family0.png',
                              ) ==
                              null
                          ? const Icon(Icons.family_restroom, size: 40)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayFamilyName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // 创建时间由后端模型暂不提供，此处不展示
                        ],
                      ),
                    ),
                    if (_isPrimary)
                      const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
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
                onPressed: _isPrimary ? _addCareReceiver : () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('仅家庭主负责人可添加被照顾者')));
                },
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
              final canEditCareReceiver = _isPrimary;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: AppImageUtils.imageProviderFor(
                      careReceiver.avatar,
                      defaultResource: 'resource:///dependent/default.png',
                    ),
                    child: AppImageUtils.imageProviderFor(
                              careReceiver.avatar,
                              defaultResource: 'resource:///dependent/default.png',
                            ) ==
                            null
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
                  trailing: canEditCareReceiver ? const Icon(Icons.chevron_right) : null,
                  onTap: canEditCareReceiver
                      ? () => _handleCareReceiverTap(careReceiver)
                      : null,
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
            ...(() {
              final currentUserId = _appState.currentUser?.id;
              final orderedMembers = <FamilyMember>[];

              if (currentUserId != null) {
                final meIndex = widget.family.members.indexWhere((m) => m.userId == currentUserId);
                if (meIndex >= 0) {
                  orderedMembers.add(widget.family.members[meIndex]);
                }
              }

              for (final member in widget.family.members) {
                if (member.userId != currentUserId) {
                  orderedMembers.add(member);
                }
              }

              return orderedMembers;
            }()).map((member) {
              final isMe = member.userId == _appState.currentUser?.id;
              final canEditMember = isMe ? _canEdit : _isPrimary;
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
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          member.nickname,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isMe) _buildSelfTag(),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _getRoleText(member.role),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ),
                  trailing: canEditMember ? const Icon(Icons.chevron_right) : null,
                  onTap: canEditMember ? () => _handleMemberTap(member) : null,
                ),
              );
            }),
        ],
      ),
    );
  }
}
