import 'package:flutter/material.dart';
import 'package:babylove_flutter/services/initial_load_service.dart';
import 'main_page.dart';

/// 数据加载页面
/// 进入后尝试加载用户家庭与相关数据，成功后进入主页
class DataLoadingPage extends StatefulWidget {
  const DataLoadingPage({super.key});

  @override
  State<DataLoadingPage> createState() => _DataLoadingPageState();
}

class _DataLoadingPageState extends State<DataLoadingPage> {
  bool _isLoading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadFailed = false;
      });
    }

    final ok = await InitialLoadService.loadUserFamiliesAndData();
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else {
      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('获取数据失败')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '幼安管家',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 48),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_loadFailed)
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('重新加载数据'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 30,
                    top: 12,
                    bottom: 12,
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
