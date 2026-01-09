import 'package:flutter/material.dart';
import 'todo_page.dart';
import 'family_page.dart';
import 'settings_page.dart';
import '../services/family_service.dart';
import '../services/app_state_service.dart';

/// 主页面，包含底部导航栏
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  bool _isInitializing = false;
  bool _hasInitError = false;
  String? _initErrorMessage;

  final FamilyService _familyService = FamilyService();
  final AppStateService _appState = AppStateService();

  final List<Widget> _pages = [
    const TodoPage(),
    const FamilyPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// 应用初始化：加载家庭数据、成员和被照顾者列表
  Future<void> _initializeApp() async {
    setState(() {
      _isInitializing = true;
      _hasInitError = false;
      _initErrorMessage = null;
    });

    try {
      // 1. 获取家庭列表
      final familiesResponse = await _familyService.getMyFamilies();
      
      if (!mounted) return;

      if (!familiesResponse.isSuccess) {
        _handleInitError(familiesResponse.message ?? '获取家庭列表失败');
        return;
      }

      final families = familiesResponse.data ?? [];
      if (families.isEmpty) {
        // 没有家庭，初始化完成
        setState(() {
          _isInitializing = false;
        });
        return;
      }

      // 2. 更新 AppStateService 的家庭列表
      _appState.setMyFamilies(families);

      // 3. 加载当前选中家庭的成员和被照顾者列表
      final lastFamily = _appState.lastFamily;
      if (lastFamily != null) {
        final dataResponse = await _familyService.loadFamilyData(
          familyId: lastFamily.id,
        );

        if (!mounted) return;

        if (!dataResponse.isSuccess) {
          _handleInitError(dataResponse.message ?? '加载家庭数据失败');
          return;
        }

        // 更新 lastFamily 中的成员和被照顾者信息
        lastFamily.members = dataResponse.data!.members;
        lastFamily.careReceivers = dataResponse.data!.careReceivers;

        // 同时更新 myFamilies 中对应的家庭
        final familyIndex = _appState.myFamilies.indexWhere((f) => f.id == lastFamily.id);
        if (familyIndex >= 0) {
          _appState.myFamilies[familyIndex].members = dataResponse.data!.members;
          _appState.myFamilies[familyIndex].careReceivers = dataResponse.data!.careReceivers;
        }

        // 通过更新家庭来触发 ChangeNotifier 的通知
        _appState.setLastFamily(lastFamily);
      }

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      _handleInitError('初始化失败: ${e.toString()}');
    }
  }

  /// 处理初始化错误
  void _handleInitError(String message) {
    setState(() {
      _isInitializing = false;
      _hasInitError = true;
      _initErrorMessage = message;
    });
  }

  /// 重试初始化
  void _retryInitialization() {
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    // 显示初始化加载状态
    if (_isInitializing) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 显示初始化错误状态
    if (_hasInitError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _initErrorMessage ?? '初始化失败',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
                onPressed: _retryInitialization,
              ),
            ],
          ),
        ),
      );
    }

    // 正常显示主页面内容
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            activeIcon: Icon(Icons.check_circle),
            label: '待办',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.family_restroom_outlined),
            activeIcon: Icon(Icons.family_restroom),
            label: '家庭',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
