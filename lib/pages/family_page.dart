import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/family_model.dart';
import '../models/care_receiver_model.dart';
import '../services/family_service.dart';
import '../services/app_state_service.dart';
import '../providers/app_state_provider.dart';
import '../widgets/family_selector.dart';
import '../core/utils.dart';
import 'family_detail_page.dart';

/// 家庭页面
class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  final FamilyService _familyService = FamilyService();
  final AppStateService _appState = AppStateService();
  List<Family> _families = [];
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFamiliesFromState();
  }

  void _loadFamiliesFromState() {
    setState(() {
      _families = _appState.myFamilies;
    });
  }

  Future<void> _refreshFamilies() async {
    try {
      final resp = await _familyService.getMyFamilies();
      if (resp.isSuccess) {
        _appState.setMyFamilies(resp.data ?? []);
        setState(() {
          _families = _appState.myFamilies;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('刷新失败: ${resp.message ?? '未知错误'}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('刷新失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AppStateProvider>(
          builder: (context, appState, child) {
            return FamilySelector(
              onChanged: () {
                // 选择器变更后,直接从全局状态刷新本地列表
                _loadFamiliesFromState();
              },
            );
          },
        ),
        toolbarHeight: 68,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFamilies,
        child: _buildListContent(),
      ),
    );
  }

  Widget _buildListContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_families.isEmpty) {
      // 也使用可滚动容器以支持下拉刷新
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 280,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.family_restroom,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无家庭',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final lastFamily = _appState.lastFamily;
    final lastCareReceiver = _appState.lastCareReceiver;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _families.length,
      itemBuilder: (context, index) {
        final family = _families[index];
        final isCurrentFamily =
            lastFamily != null && family.id == lastFamily.id;

        // 当前被照顾者：当前家庭显示 AppState 的最近护理对象，否则展示该家庭的首个
        final CareReceiver currentCareReceiver = isCurrentFamily
            ? (lastCareReceiver ??
                  (family.careReceivers.isNotEmpty
                      ? family.careReceivers.first
                      : CareReceiver(
                          id: '',
                          name: '无',
                          gender: 'unknown',
                          birthDate: null,
                        )))
            : (family.careReceivers.isNotEmpty
                  ? family.careReceivers.first
                  : CareReceiver(
                      id: '',
                      name: '无',
                      gender: 'unknown',
                      birthDate: null,
                    ));

        return _FamilyCard(
          family: family,
          currentCareReceiver: currentCareReceiver,
          isCurrentFamily: isCurrentFamily,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FamilyDetailPage(family: family),
              ),
            ).then((_) => _loadFamiliesFromState());
          },
        );
      },
    );
  }
}

/// 家庭卡片组件
class _FamilyCard extends StatelessWidget {
  final Family family;
  final CareReceiver currentCareReceiver;
  final bool isCurrentFamily;
  final VoidCallback onTap;

  const _FamilyCard({
    required this.family,
    required this.currentCareReceiver,
    required this.isCurrentFamily,
    required this.onTap,
  });

  String _buildCareReceiverInfo(CareReceiver careReceiver) {
    return AppUtils.buildCareReceiverInfo(
      birthDate: careReceiver.birthDate != null
          ? DateTime.fromMillisecondsSinceEpoch(careReceiver.birthDate! * 1000)
          : null,
      gender: careReceiver.gender,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isCurrentFamily ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCurrentFamily
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 家庭信息
              Row(
                children: [
                  // 家庭头像
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: family.avatar != null
                        ? NetworkImage(family.avatar!)
                        : null,
                    child: family.avatar == null
                        ? const Icon(Icons.family_restroom, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),

                  // 家庭名称
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                family.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isCurrentFamily) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '选中',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${family.careReceiverIds.length}位被照顾者 · ${family.memberCount}位成员',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.chevron_right),
                ],
              ),

              if (family.lastCareReceiver != null) ...[
                const Divider(height: 24),

                // 当前被照顾者信息
                Row(
                  children: [
                    // 被照顾者头像
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: currentCareReceiver.avatar != null
                          ? NetworkImage(currentCareReceiver.avatar!)
                          : null,
                      child: currentCareReceiver.avatar == null
                          ? const Icon(Icons.person, size: 24)
                          : null,
                    ),
                    const SizedBox(width: 12),

                    // 被照顾者详情
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  currentCareReceiver.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isCurrentFamily) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '当前照顾者',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _buildCareReceiverInfo(currentCareReceiver),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
