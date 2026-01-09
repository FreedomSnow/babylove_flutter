import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/family_model.dart';
import '../models/care_receiver_model.dart';
import '../services/app_state_service.dart';
import '../services/family_service.dart';
import '../services/care_receiver_service.dart';
import '../providers/app_state_provider.dart';

/// 家庭和被照顾者选择器组件
/// 用于待办和家庭页面顶部，支持联动切换
class FamilySelector extends StatefulWidget {
  final VoidCallback? onChanged;

  const FamilySelector({super.key, this.onChanged});

  @override
  State<FamilySelector> createState() => _FamilySelectorState();
}

class _FamilySelectorState extends State<FamilySelector> {
  final AppStateService _appState = AppStateService();
  final FamilyService _familyService = FamilyService();
  final CareReceiverService _careReceiverService = CareReceiverService();
  Family? _currentFamily;
  CareReceiver? _currentCareReceiver;
  late final VoidCallback _appStateListener;

  @override
  void initState() {
    super.initState();
    _appStateListener = _onAppStateChanged;
    _appState.addListener(_appStateListener);
    // 先同步状态，延迟通知 Provider（避免在 build 期间触发 notifyListeners）
    _syncFromState(notifyProvider: false);
    // 在当前帧构建完成后再通知 Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _currentFamily != null) {
        final provider = context.read<AppStateProvider>();
        provider.updateFamilyAndCareReceiver(
          _currentFamily!.id,
          _currentCareReceiver?.id,
        );
      }
    });
  }

  void _onAppStateChanged() {
    _syncFromState(notifyProvider: true);
  }

  void _syncFromState({bool notifyProvider = false}) {
    final lastFamily = _appState.lastFamily;
    final lastCareReceiver = _appState.lastCareReceiver;
    
    setState(() {
      // 不使用回退到第一个家庭；如果 lastFamily 为空则保留为 null，显示“未选中家庭"
      _currentFamily = lastFamily;
      // 不回退到家庭的第一个被照顾者；仅使用 lastCareReceiver
      _currentCareReceiver = lastCareReceiver;
    });

    if (notifyProvider && _currentFamily != null) {
      final provider = context.read<AppStateProvider>();
      provider.updateFamilyAndCareReceiver(
        _currentFamily!.id,
        _currentCareReceiver?.id,
      );
    }
  }

  @override
  void dispose() {
    _appState.removeListener(_appStateListener);
    super.dispose();
  }

  void _showFamilyPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final families = _appState.myFamilies;
        return ListView.builder(
          shrinkWrap: true,
          itemCount: families.length,
          itemBuilder: (context, index) {
            final family = families[index];
            final isSelected = family.id == _currentFamily?.id;

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: family.avatar != null && family.avatar!.isNotEmpty
                    ? NetworkImage(family.avatar!)
                    : null,
                child: family.avatar == null
                    ? const Icon(Icons.family_restroom)
                    : null,
              ),
              title: Text(family.name),
              trailing: isSelected
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              selected: isSelected,
              onTap: () async {
                Navigator.pop(context);

                // 显示 loading 对话框
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => const Center(child: CircularProgressIndicator()),
                );

                try {
                  final resp = await _familyService.switchFamily(familyId: family.id);
                  if (mounted) Navigator.of(context).pop(); // 关闭 loading

                  if (resp.isSuccess && resp.data != null) {
                    final switchedFamily = resp.data!;

                    // 更新最近家庭
                    _appState.setLastFamily(switchedFamily);

                    // 如果后端返回的家庭中没有被照顾者，则尝试主动加载家庭数据
                    if (switchedFamily.careReceivers.isEmpty) {
                      try {
                        final loadResp = await _familyService.loadFamilyData(familyId: switchedFamily.id);
                        if (loadResp.isSuccess && loadResp.data != null) {
                          final data = loadResp.data!;
                          _appState.updateFamilyMembersAndCareReceivers(
                            familyId: switchedFamily.id,
                            careReceivers: data.careReceivers,
                            members: data.members,
                          );

                          if (data.careReceivers.isNotEmpty) {
                            _appState.setLastCareReceiver(data.careReceivers.first);
                          } else {
                            _appState.setLastCareReceiver(null);
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('加载家庭数据失败: ${loadResp.message ?? '未知错误'}')),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('加载家庭数据异常: $e')),
                          );
                        }
                      }
                    }

                      // 如果后端返回的 switchedFamily 包含一个占位的 lastCareReceiver（仅有 id，name 为空），
                      // 则尝试在 switchedFamily.careReceivers 中查找完整实例并设置到 AppState
                      if (switchedFamily.lastCareReceiver != null &&
                          switchedFamily.lastCareReceiver!.id.isNotEmpty &&
                          switchedFamily.lastCareReceiver!.name.isEmpty) {
                        final matches = switchedFamily.careReceivers
                            .where((cr) => cr.id == switchedFamily.lastCareReceiver!.id)
                            .toList();
                        if (matches.isNotEmpty) {
                          _appState.setLastCareReceiver(matches.first);
                        }
                      }



                    // 更新本地 UI 状态并通知 Provider
                    setState(() {
                      _currentFamily = _appState.lastFamily;
                      _currentCareReceiver = _appState.lastCareReceiver;
                    });

                    final provider = context.read<AppStateProvider>();
                    if (_currentFamily != null) {
                      provider.updateFamilyAndCareReceiver(
                        _currentFamily!.id,
                        _currentCareReceiver?.id,
                      );
                    }

                    widget.onChanged?.call();
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('切换家庭失败: ${resp.message ?? '未知错误'}')),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('切换家庭异常: $e')),
                    );
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  void _showCareReceiverPicker() {
    if (_currentFamily == null || _currentFamily!.careReceivers.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_currentFamily == null ? '没有选中家庭' : '当前家庭没有被照顾者')));
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: _currentFamily!.careReceivers.length,
          itemBuilder: (context, index) {
            final careReceiver = _currentFamily!.careReceivers[index];
            final isSelected = careReceiver.id == _currentCareReceiver?.id;

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: careReceiver.avatar != null && careReceiver.avatar!.isNotEmpty
                    ? NetworkImage(careReceiver.avatar!)
                    : null,
                child: careReceiver.avatar == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(careReceiver.name),
              subtitle: Text(
                careReceiver.birthDate != null
                    ? '出生日期: ${careReceiver.birthDate}'
                    : '出生日期未知',
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              selected: isSelected,
              onTap: () async {
                Navigator.pop(context);

                // 显示 loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => const Center(child: CircularProgressIndicator()),
                );

                try {
                  final familyId = (_appState.lastFamily?.id) ?? _currentFamily!.id;
                  final resp = await _careReceiverService.switchCareReceiver(
                    familyId: familyId,
                    careReceiverId: careReceiver.id,
                  );

                  if (mounted) Navigator.of(context).pop(); // 关闭 loading

                  if (resp.isSuccess && resp.data != null) {
                    final data = resp.data!;

                    // 更新 AppState：先更新家庭，再设置被照顾者
                    _appState.setLastFamily(data.family);
                    _appState.setLastCareReceiver(data.currentCareReceiver);

                    // 同步本地 UI
                    setState(() {
                      _currentFamily = _appState.lastFamily;
                      _currentCareReceiver = _appState.lastCareReceiver;
                    });

                    // 通知 Provider
                    final provider = context.read<AppStateProvider>();
                    provider.updateFamilyAndCareReceiver(
                      _currentFamily!.id,
                      _currentCareReceiver?.id,
                    );

                    widget.onChanged?.call();
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('切换被照顾者失败: ${resp.message ?? '未知错误'}')),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('切换被照顾者异常: $e')),
                    );
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.06),
      ),
      child: Row(
        children: [
          // 家庭选择
          Expanded(
            child: InkWell(
              onTap: _showFamilyPicker,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        theme.dividerTheme.color ??
                        theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.family_restroom, size: 20, color: primaryColor),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                          _currentFamily?.name ?? '未选中家庭',
                        style: TextStyle(fontSize: 14, color: primaryColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, size: 20, color: primaryColor),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 被照顾者选择
          Expanded(
            child: InkWell(
              onTap: _showCareReceiverPicker,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        theme.dividerTheme.color ??
                        theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, size: 20, color: primaryColor),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _currentCareReceiver?.name ?? '未选中被照顾者',
                        style: TextStyle(fontSize: 14, color: primaryColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, size: 20, color: primaryColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
