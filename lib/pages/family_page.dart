import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/family_model.dart';
import '../models/care_receiver_model.dart';
import '../services/family_service.dart';
import '../providers/app_state_provider.dart';
import '../widgets/family_selector.dart';
import 'family_detail_page.dart';

/// 家庭页面
class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  final FamilyService _familyService = FamilyService();
  List<FamilyModel> _families = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFamilies();
  }

  Future<void> _loadFamilies() async {
    setState(() => _isLoading = true);
    try {
      _families = await _familyService.getFamilies();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载家庭失败: $e')));
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('家庭')),
      body: Column(
        children: [
          // 家庭和被照顾者选择器
          Consumer<AppStateProvider>(
            builder: (context, appState, child) {
              return FamilySelector(
                onChanged: () {
                  setState(() {});
                },
              );
            },
          ),

          // 家庭列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _families.isEmpty
                ? Center(
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
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : Consumer<AppStateProvider>(
                    builder: (context, appState, child) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _families.length,
                        itemBuilder: (context, index) {
                          final family = _families[index];
                          final isCurrentFamily =
                              family.id == appState.currentFamilyId;
                          final currentCareReceiver = family.careReceivers
                              .firstWhere(
                                (cr) => cr.id == appState.currentCareReceiverId,
                                orElse: () => family.careReceivers.isNotEmpty
                                    ? family.careReceivers.first
                                    : CareReceiver(
                                        id: '',
                                        name: '无',
                                        gender: 'unknown',
                                        birthDate: null,
                                      ),
                              );

                          return _FamilyCard(
                            family: family,
                            currentCareReceiver: currentCareReceiver,
                            isCurrentFamily: isCurrentFamily,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FamilyDetailPage(family: family),
                                ),
                              ).then((_) => _loadFamilies());
                            },
                            getChineseZodiac: _getChineseZodiac,
                            getGenderText: _getGenderText,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// 家庭卡片组件
class _FamilyCard extends StatelessWidget {
  final FamilyModel family;
  final CareReceiver currentCareReceiver;
  final bool isCurrentFamily;
  final VoidCallback onTap;
  final String Function(DateTime) getChineseZodiac;
  final String Function(String) getGenderText;

  const _FamilyCard({
    required this.family,
    required this.currentCareReceiver,
    required this.isCurrentFamily,
    required this.onTap,
    required this.getChineseZodiac,
    required this.getGenderText,
  });

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
                    backgroundImage: family.avatarUrl != null
                        ? NetworkImage(family.avatarUrl!)
                        : null,
                    child: family.avatarUrl == null
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
                                  '当前',
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
                          '${family.careReceivers.length}位被照顾者 · ${family.members.length}位成员',
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

              if (family.careReceivers.isNotEmpty) ...[
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
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${currentCareReceiver.birthDate != null ? DateTime.fromMillisecondsSinceEpoch(currentCareReceiver.birthDate! * 1000).year : ''}年${currentCareReceiver.birthDate != null ? DateTime.fromMillisecondsSinceEpoch(currentCareReceiver.birthDate! * 1000).month : ''}月 · '
                            '${currentCareReceiver.birthDate != null ? getChineseZodiac(DateTime.fromMillisecondsSinceEpoch(currentCareReceiver.birthDate! * 1000)) : ''} · '
                            '${getGenderText(currentCareReceiver.gender ?? 'unknown')}',
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
