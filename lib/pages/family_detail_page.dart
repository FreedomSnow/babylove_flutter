import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/image_utils.dart';
import '../core/utils.dart';
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
          final msg = response.message ?? '加载数据失败';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red,));
          _showErrorDialog(msg);
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
        final msg = '加载数据失败: ${e.toString()}';
        _showErrorDialog(msg);
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
        final msg = resp.message ?? '退出失败';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
        _showErrorDialog(msg);
      }
    } catch (e) {
      final msg = '退出失败: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      _showErrorDialog(msg);
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
        final msg = resp.message ?? '销毁失败';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
        _showErrorDialog(msg);
      }
    } catch (e) {
      final msg = '销毁失败: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      _showErrorDialog(msg);
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
        final msg = resp.message ?? '修改失败';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
        _showErrorDialog(msg);
      }
    } catch (e) {
      final msg = '修改失败: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      _showErrorDialog(msg);
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
        final msg = resp.message ?? '移除失败';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
        _showErrorDialog(msg);
      }
    } catch (e) {
      final msg = '移除失败: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      _showErrorDialog(msg);
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


  Future<void> _addCareReceiver() async {
    final nameController = TextEditingController();
    String? tempAvatar;
    String? selectedGender;
    DateTime? selectedBirthDate;

    await showModalBottomSheet<void>(
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
                      const Text('添加被照顾者', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              final resource = await showAssetImagePicker(
                                context,
                                subdir: 'dependent',
                                title: '选择头像',
                                initialSelectedResource: tempAvatar,
                              );
                              if (resource != null) setModalState(() => tempAvatar = resource);
                            },
                            child: CircleAvatar(
                              radius: 32,
                              backgroundImage: AppImageUtils.imageProviderFor(
                                tempAvatar,
                                defaultResource: 'resource:///dependent/default.png',
                              ),
                              child: AppImageUtils.imageProviderFor(
                                        tempAvatar,
                                        defaultResource: 'resource:///dependent/default.png',
                                      ) ==
                                      null
                                  ? const Icon(Icons.person, size: 32)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(labelText: '昵称'),
                              autofocus: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 性别选择
                      Row(
                        children: [
                          const Text('性别：', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String?>(
                                    title: const Text('男'),
                                    value: '男',
                                    groupValue: selectedGender,
                                    onChanged: (v) => setModalState(() => selectedGender = v),
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String?>(
                                    title: const Text('女'),
                                    value: '女',
                                    groupValue: selectedGender,
                                    onChanged: (v) => setModalState(() => selectedGender = v),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // 出生日期选择
                      Row(
                        children: [
                          const Text('出生：', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              var tempDate = selectedBirthDate ?? now;

                              await showModalBottomSheet<void>(
                                context: ctx,
                                builder: (bCtx) {
                                  return SafeArea(
                                    child: SizedBox(
                                      height: 300,
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: CupertinoDatePicker(
                                              mode: CupertinoDatePickerMode.date,
                                              initialDateTime: tempDate,
                                              maximumDate: now,
                                              onDateTimeChanged: (val) {
                                                tempDate = val;
                                              },
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              TextButton(
                                                onPressed: () => Navigator.of(bCtx).pop(),
                                                child: const Text('取消'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  setModalState(() => selectedBirthDate = tempDate);
                                                  Navigator.of(bCtx).pop();
                                                },
                                                child: const Text('确定'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Text(selectedBirthDate == null ? '未设置' : AppUtils.formatUtcOrIsoToYMD(selectedBirthDate!)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final newName = nameController.text.trim();
                            if (newName.isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('昵称不能为空'), backgroundColor: Colors.red));
                              return;
                            }

                            // 显示全屏半透明 overlay
                            showDialog(
                              context: ctx,
                              barrierDismissible: false,
                              barrierColor: Colors.black.withOpacity(0.4),
                              builder: (dCtx) => const Center(child: CircularProgressIndicator()),
                            );

                            final newCareReceiver = CareReceiver(
                              id: '', // 由后端生成
                              name: newName,
                              gender: selectedGender,
                              birthDate: selectedBirthDate == null ? null : AppUtils.formatUtcOrIsoToYMD(selectedBirthDate!),
                              avatar: tempAvatar,
                            );

                            final success = await _createCareReceiver(newCareReceiver);

                            // 关闭 overlay（对话框通常是挂载在根 Navigator 上）
                            if (Navigator.of(context, rootNavigator: true).canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }

                            if (success) {
                              // 保存成功后关闭编辑页（关闭 bottom sheet）
                              if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
                            }
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
  }

  /// 创建被照顾者，返回是否成功（不自动关闭编辑页）
  Future<bool> _createCareReceiver(CareReceiver careReceiver) async {
    try {
      final resp = await _careReceiverService.createCareReceiver(
        familyId: widget.family.id,
        careReceiver: careReceiver,
      );

      if (resp.isSuccess) {
        if (mounted) {
          setState(() {
            widget.family.careReceivers.add(resp.data!);
          });
        }
        _updateAppState();

        // 同步更新 AppStateService 中缓存的家庭数据（lastFamily 与 myFamilies）
        final appState = AppStateService();
        final createdCare = resp.data!;

        // 更新 lastFamily 中的被照顾者列表
        final lastFamily = appState.lastFamily;
        if (lastFamily != null && lastFamily.id == widget.family.id) {
          lastFamily.careReceivers = List.from(lastFamily.careReceivers)..add(createdCare);
          appState.setLastFamily(lastFamily);
        }

        // 更新 myFamilies 列表中的对应家庭
        final families = appState.myFamilies;
        final fIdx = families.indexWhere((f) => f.id == widget.family.id);
        if (fIdx >= 0) {
          final foundFamily = families[fIdx];
          final idx = foundFamily.careReceivers.indexWhere((f) => f.id == createdCare.id);
          if (idx < 0) {
            foundFamily.careReceivers = List.from(foundFamily.careReceivers)..add(createdCare);
            families[fIdx] = foundFamily;
            appState.setMyFamilies(families);
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('被照顾者已创建')));
        return true;
      } else {
        final msg = resp.message ?? '创建失败';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
        _showErrorDialog(msg);
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      final msg = '创建失败: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      _showErrorDialog(msg);
      return false;
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('确定')),
        ],
      ),
    );
  }

  Future<void> _handleFamilyInfoTap() async {
    if (!_isPrimary) {
      return;
    }

    final nameController = TextEditingController(text: _displayFamilyName);
    String? tempAvatar = _displayFamilyAvatar;
    
    await showModalBottomSheet<void>(
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
                          onPressed: () async {
                            final newName = nameController.text.trim();
                            final newAvatar = tempAvatar;
                            if (newName.isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('家庭名称不能为空'), backgroundColor: Colors.red));
                              return;
                            }

                            // 若名称与头像均未变化，则直接关闭编辑页
                            if (newName == _displayFamilyName && (newAvatar ?? '') == (_displayFamilyAvatar ?? '')) {
                              Navigator.of(ctx).pop();
                              return;
                            }

                            // 显示全屏半透明 overlay
                            showDialog(
                              context: ctx,
                              barrierDismissible: false,
                              barrierColor: Colors.black.withOpacity(0.4),
                              builder: (dCtx) => const Center(child: CircularProgressIndicator()),
                            );

                            final success = await _updateFamilyInfo(newName, newAvatar);

                            // 关闭 overlay（对话框通常是挂载在根 Navigator 上）
                            if (Navigator.of(context, rootNavigator: true).canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }

                            if (success) {
                              // 保存成功后关闭编辑页（关闭 bottom sheet）
                              if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
                            }
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
  }

  /// 更新家庭信息，返回是否成功（不自动关闭编辑页）
  Future<bool> _updateFamilyInfo(String newName, String? newAvatar) async {
    if (newName == _displayFamilyName && (newAvatar ?? '') == (_displayFamilyAvatar ?? '')) {
      return true;
    }

    try {
      final resp = await _familyService.updateFamily(
        familyId: widget.family.id,
        familyName: newName,
        familyAvatar: newAvatar,
      );

      if (resp.isSuccess) {
        if (!mounted) return true;
        setState(() {
          _displayFamilyName = resp.data?.name ?? newName;
          _displayFamilyAvatar = resp.data?.avatar ?? newAvatar;
        });

        // 更新 AppStateService 中对应的 family 信息（若存在于缓存中）
        final appState = AppStateService();
        final updatedFamily = resp.data;
        if (updatedFamily != null) {
          // 更新 lastFamily
          if (appState.lastFamily?.id == updatedFamily.id) {
            updatedFamily.lastCareReceiver = appState.lastFamily?.lastCareReceiver;
            updatedFamily.careReceivers = appState.lastFamily?.careReceivers ?? [];
            updatedFamily.members = appState.lastFamily?.members ?? [];
            appState.setLastFamily(updatedFamily);
          }

          // 更新 myFamilies 列表中的该家庭
          final families = appState.myFamilies;
          final idx = families.indexWhere((f) => f.id == updatedFamily.id);
          if (idx >= 0) {
            final foundFamily = families[idx];
            updatedFamily.lastCareReceiver = foundFamily.lastCareReceiver;
            updatedFamily.careReceivers = foundFamily.careReceivers;
            updatedFamily.members = foundFamily.members;
            families[idx] = updatedFamily;
            appState.setMyFamilies(families);
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('家庭信息已保存')));
        return true;
      } else {
        final msg = resp.message ?? '保存失败';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
        _showErrorDialog(msg);
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      final msg = '保存失败: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      _showErrorDialog(msg);
      return false;
    }
  }

  /// 更新当前用户昵称，返回是否成功（不自动关闭编辑页）
  Future<bool> _updateMyNickname(String newNickname) async {
    if (_myMember == null) return false;
    if (newNickname.trim().isEmpty) {
      _showErrorMessage('昵称不能为空');
      return false;
    }

    debugPrint('Updating my nickname to: $newNickname');

    try {
      final resp = await _familyService.updateMyNickname(
        familyId: widget.family.id,
        nickname: newNickname.trim(),
      );
      if (resp.isSuccess) {
        final updated = resp.data!;
        // 更新页面显示以及本地缓存
        if (mounted) {
          setState(() {
            final idx = widget.family.members.indexWhere((m) => m.id == updated.id);
            if (idx >= 0) {
              widget.family.members[idx] = updated;
            }
            _myMember = updated;
          });
        }

        // 如果当前登录用户与该 member 对应，则同步更新 AppStateService 中的 currentUser
        if (_appState.currentUser != null && _appState.currentUser!.id == updated.userId) {
          final newUser = _appState.currentUser!.copyWith(nickname: updated.nickname);
          _appState.setCurrentUser(newUser);
        }

        // 更新 app 全局里的家庭成员缓存
        _updateAppState();

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('我的昵称已保存')));
        return true;
      } else {
        final msg = resp.message ?? '保存失败';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
        _showErrorDialog(msg);
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      final msg = '保存失败: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      _showErrorDialog(msg);
      return false;
    }
  }

  Future<void> _handleCareReceiverTap(CareReceiver careReceiver) async {
    if (!_isPrimary) {
      _showErrorMessage('仅家庭管理员可编辑被照顾者');
      return;
    }

    final nameController = TextEditingController(text: careReceiver.name);
    String? tempAvatar = careReceiver.avatar;
    String? selectedGender = careReceiver.gender;
    DateTime? selectedBirthDate = AppUtils.dateTimeFromYMD(careReceiver.birthDate);

    await showModalBottomSheet<void>(
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
                      const Text('编辑被照顾者', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              final resource = await showAssetImagePicker(
                                context,
                                subdir: 'dependent',
                                title: '选择头像',
                                initialSelectedResource: tempAvatar,
                              );
                              if (resource != null) setModalState(() => tempAvatar = resource);
                            },
                            child: CircleAvatar(
                              radius: 32,
                              backgroundImage: AppImageUtils.imageProviderFor(
                                tempAvatar,
                                defaultResource: 'resource:///dependent/default.png',
                              ),
                              child: AppImageUtils.imageProviderFor(
                                        tempAvatar,
                                        defaultResource: 'resource:///dependent/default.png',
                                      ) ==
                                      null
                                  ? const Icon(Icons.person, size: 32)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(labelText: '昵称'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 性别选择
                      Row(
                        children: [
                          const Text('性别：', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String?>(
                                    title: const Text('男'),
                                    value: '男',
                                    groupValue: selectedGender,
                                    onChanged: (v) => setModalState(() => selectedGender = v),
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String?>(
                                    title: const Text('女'),
                                    value: '女',
                                    groupValue: selectedGender,
                                    onChanged: (v) => setModalState(() => selectedGender = v),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // 出生日期选择
                      Row(
                        children: [
                          const Text('出生：', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              var tempDate = selectedBirthDate ?? now;

                              await showModalBottomSheet<void>(
                                context: ctx,
                                builder: (bCtx) {
                                  return SafeArea(
                                    child: SizedBox(
                                      height: 300,
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: CupertinoDatePicker(
                                              mode: CupertinoDatePickerMode.date,
                                              initialDateTime: tempDate,
                                              maximumDate: now,
                                              onDateTimeChanged: (val) {
                                                tempDate = val;
                                              },
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              TextButton(
                                                onPressed: () => Navigator.of(bCtx).pop(),
                                                child: const Text('取消'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  setModalState(() => selectedBirthDate = tempDate);
                                                  Navigator.of(bCtx).pop();
                                                },
                                                child: const Text('确定'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Text(selectedBirthDate == null ? '未设置' : AppUtils.formatUtcOrIsoToYMD(selectedBirthDate!)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final newName = nameController.text.trim();
                            if (newName.isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('昵称不能为空'), backgroundColor: Colors.red));
                              return;
                            }

                            // 若全部字段未变化则关闭
                            final unchanged = newName == careReceiver.name &&
                                (tempAvatar ?? '') == (careReceiver.avatar ?? '') &&
                                (selectedGender ?? '') == (careReceiver.gender ?? '') &&
                                (selectedBirthDate == AppUtils.dateTimeFromYMD(careReceiver.birthDate));
                            if (unchanged) {
                              Navigator.of(ctx).pop();
                              return;
                            }

                            // 显示全屏半透明 overlay
                            showDialog(
                              context: ctx,
                              barrierDismissible: false,
                              barrierColor: Colors.black.withOpacity(0.4),
                              builder: (dCtx) => const Center(child: CircularProgressIndicator()),
                            );

                            final updated = CareReceiver(
                              id: careReceiver.id,
                              name: newName,
                              gender: selectedGender,
                              birthDate: selectedBirthDate == null ? null : AppUtils.formatUtcOrIsoToYMD(selectedBirthDate!),
                              avatar: tempAvatar,
                              residence: careReceiver.residence,
                              phone: careReceiver.phone,
                              emergencyContact: careReceiver.emergencyContact,
                              medicalHistory: careReceiver.medicalHistory,
                              allergies: careReceiver.allergies,
                              remark: careReceiver.remark,
                              customFields: careReceiver.customFields,
                            );

                            final success = await _updateCareReceiver(careReceiver, updated);

                            // 关闭 overlay（对话框通常是挂载在根 Navigator 上）
                            if (Navigator.of(context, rootNavigator: true).canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }

                            if (success) {
                              // 保存成功后关闭编辑页（关闭 bottom sheet）
                              if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
                            }
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
  }

  /// 更新被照顾者，返回是否成功（不自动关闭编辑页）
  Future<bool> _updateCareReceiver(CareReceiver original, CareReceiver updated) async {
    try {
      final resp = await _careReceiverService.updateCareReceiver(
        familyId: widget.family.id,
        careReceiverId: original.id,
        careReceiver: updated,
      );

      if (resp.isSuccess) {
        if (mounted) {
          setState(() {
            final idx = widget.family.careReceivers.indexWhere((c) => c.id == original.id);
            if (idx >= 0) {
              widget.family.careReceivers[idx] = resp.data!;
            }
          });
        }

        // 同步更新 AppStateService 中缓存的家庭数据（lastFamily 与 myFamilies）
        final appState = AppStateService();
        final updatedCare = resp.data!;

        // 更新 lastFamily 中的被照顾者列表
        final lastFamily = appState.lastFamily;
        if (lastFamily != null && lastFamily.id == widget.family.id) {
          if (lastFamily.lastCareReceiver?.id == updatedCare.id) {
            lastFamily.lastCareReceiver = updatedCare;
          }

          final cIdx = lastFamily.careReceivers.indexWhere((c) => c.id == updatedCare.id);
          if (cIdx >= 0) {
            lastFamily.careReceivers[cIdx] = updatedCare;
          }
        }

        // 更新 myFamilies 列表中的对应家庭
        final families = appState.myFamilies;
        final fIdx = families.indexWhere((f) => f.id == widget.family.id);
        if (fIdx >= 0) {
          final found = families[fIdx];
          final ccIdx = found.careReceivers.indexWhere((c) => c.id == updatedCare.id);
          if (ccIdx >= 0) {
            found.careReceivers[ccIdx] = updatedCare;
            families[fIdx] = found;
            appState.setMyFamilies(families);
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('被照顾者信息已保存')));
        return true;
      } else {
        final msg = resp.message ?? '保存失败';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
        _showErrorDialog(msg);
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      final msg = '保存失败: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      _showErrorDialog(msg);
      return false;
    }
  }

  Future<void> _handleMemberTap(FamilyMember member) async {
    final isMe = member.userId == _appState.currentUser?.id;
    if (isMe) {
      final controller = TextEditingController(text: member.nickname);
      await showModalBottomSheet<void>(
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
                        onPressed: () async {
                          final newNick = controller.text.trim();
                          if (newNick.isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('昵称不能为空'), backgroundColor: Colors.red));
                            return;
                          }

                          if (newNick == member.nickname) {
                            Navigator.of(ctx).pop();
                            return;
                          }

                          showDialog(
                            context: ctx,
                            barrierDismissible: false,
                            barrierColor: Colors.black.withOpacity(0.4),
                            builder: (dCtx) => const Center(child: CircularProgressIndicator()),
                          );

                          final success = await _updateMyNickname(newNick);

                          // 关闭 overlay（对话框通常是挂载在根 Navigator 上）
                          if (Navigator.of(context, rootNavigator: true).canPop()) {
                            Navigator.of(context, rootNavigator: true).pop();
                          }

                          if (success) {
                            // 保存成功后关闭编辑页（关闭 bottom sheet）
                            if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
                          }
                        },
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
            ...(() {
              final orderedCareReceivers = List<CareReceiver>.from(widget.family.careReceivers);
              final last = widget.family.lastCareReceiver;
              if (last != null) {
                final idx = orderedCareReceivers.indexWhere((c) => c.id == last.id);
                if (idx > 0) {
                  final item = orderedCareReceivers.removeAt(idx);
                  orderedCareReceivers.insert(0, item);
                }
              }

              return orderedCareReceivers.map((careReceiver) {
                final canEditCareReceiver = _isPrimary;
                final isSelected = widget.family.lastCareReceiver?.id == careReceiver.id;

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
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            careReceiver.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '选中',
                              style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
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
              });
            }()),

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
                      Family.getRoleDescription(member.role),
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
