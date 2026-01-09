import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/family_model.dart';
import '../models/care_receiver_model.dart';
import '../services/app_state_service.dart';
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
  List<Family> _families = [];
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
    final families = _appState.myFamilies;
    final lastFamily = _appState.lastFamily;
    final lastCareReceiver = _appState.lastCareReceiver;

    setState(() {
      _families = families;
      _currentFamily =
          lastFamily ?? (families.isNotEmpty ? families.first : null);
      _currentCareReceiver =
          lastCareReceiver ??
          (_currentFamily != null && _currentFamily!.careReceivers.isNotEmpty
              ? _currentFamily!.careReceivers.first
              : null);
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
        return ListView.builder(
          shrinkWrap: true,
          itemCount: _families.length,
          itemBuilder: (context, index) {
            final family = _families[index];
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
              onTap: () {
                // 更新全局状态服务
                _appState.setLastFamily(family);
                if (family.careReceivers.isNotEmpty) {
                  _appState.setLastCareReceiver(family.careReceivers.first);
                } else {
                  _appState.setLastCareReceiver(null);
                }

                // 本地 UI 状态
                setState(() {
                  _currentFamily = _appState.lastFamily;
                  _currentCareReceiver = _appState.lastCareReceiver;
                });

                // 通知 Provider（供全局监听者使用）
                final provider = context.read<AppStateProvider>();
                provider.updateFamilyAndCareReceiver(
                  _currentFamily!.id,
                  _currentCareReceiver?.id,
                );

                Navigator.pop(context);
                widget.onChanged?.call();
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
      ).showSnackBar(const SnackBar(content: Text('当前家庭没有被照顾者')));
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
              onTap: () {
                // 更新全局状态服务
                _appState.setLastCareReceiver(careReceiver);

                // 本地 UI 状态
                setState(() {
                  _currentCareReceiver = _appState.lastCareReceiver;
                });

                // 通知 Provider（供全局监听者使用）
                final provider = context.read<AppStateProvider>();
                provider.updateFamilyAndCareReceiver(
                  (_appState.lastFamily?.id) ?? _currentFamily!.id,
                  _currentCareReceiver?.id,
                );

                Navigator.pop(context);
                widget.onChanged?.call();
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
                        _currentFamily?.name ?? '选择家庭',
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
                        _currentCareReceiver?.name ?? '选择被照顾者',
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
