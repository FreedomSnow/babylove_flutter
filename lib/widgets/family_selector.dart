import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/family_model.dart';
import '../models/care_receiver_model.dart';
import '../services/family_service.dart';
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
  final FamilyService _familyService = FamilyService();
  List<FamilyModel> _families = [];
  FamilyModel? _currentFamily;
  CareReceiver? _currentCareReceiver;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _families = await _familyService.getFamilies();
      if (_families.isNotEmpty) {
        final appState = context.read<AppStateProvider>();

        // 获取当前家庭
        if (appState.currentFamilyId != null) {
          _currentFamily = _families.firstWhere(
            (f) => f.id == appState.currentFamilyId,
            orElse: () => _families.first,
          );
        } else {
          _currentFamily = _families.first;
          appState.setCurrentFamily(_currentFamily!.id);
        }

        // 获取当前被照顾者
        if (_currentFamily!.careReceivers.isNotEmpty) {
          if (appState.currentCareReceiverId != null) {
            _currentCareReceiver = _currentFamily!.careReceivers.firstWhere(
              (cr) => cr.id == appState.currentCareReceiverId,
              orElse: () => _currentFamily!.careReceivers.first,
            );
          } else {
            _currentCareReceiver = _currentFamily!.careReceivers.first;
            appState.setCurrentCareReceiver(_currentCareReceiver!.id);
          }
        }

        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载数据失败: $e')));
      }
    }
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
                backgroundImage: family.avatarUrl != null
                    ? NetworkImage(family.avatarUrl!)
                    : null,
                child: family.avatarUrl == null
                    ? const Icon(Icons.family_restroom)
                    : null,
              ),
              title: Text(family.name),
                trailing: isSelected
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              selected: isSelected,
              onTap: () {
                setState(() {
                  _currentFamily = family;
                  if (family.careReceivers.isNotEmpty) {
                    _currentCareReceiver = family.careReceivers.first;
                  } else {
                    _currentCareReceiver = null;
                  }
                });

                final appState = context.read<AppStateProvider>();
                appState.updateFamilyAndCareReceiver(
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
                backgroundImage: careReceiver.avatar != null
                    ? NetworkImage(careReceiver.avatar!)
                    : null,
                child: careReceiver.avatar == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(careReceiver.name),
              subtitle: Text(
                careReceiver.birthDate != null
                    ? '${DateTime.fromMillisecondsSinceEpoch(careReceiver.birthDate! * 1000).year}年${DateTime.fromMillisecondsSinceEpoch(careReceiver.birthDate! * 1000).month}月'
                    : '',
              ),
                trailing: isSelected
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              selected: isSelected,
              onTap: () {
                setState(() {
                  _currentCareReceiver = careReceiver;
                });

                final appState = context.read<AppStateProvider>();
                appState.setCurrentCareReceiver(_currentCareReceiver!.id);

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
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
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.family_restroom, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _currentFamily?.name ?? '选择家庭',
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 20),
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
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _currentCareReceiver?.name ?? '选择被照顾者',
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 20),
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
