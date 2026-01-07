import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:babylove_flutter/services/storage_service.dart';
import 'package:babylove_flutter/services/todo_service.dart';
import 'package:babylove_flutter/providers/theme_provider.dart';
import 'package:babylove_flutter/providers/elder_mode_provider.dart';
import 'package:babylove_flutter/providers/app_state_provider.dart';
import 'package:babylove_flutter/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化本地存储服务
  await StorageService().init();
  
  // 初始化待办服务
  await TodoService().init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ElderModeProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: Consumer2<ThemeProvider, ElderModeProvider>(
        builder: (context, themeProvider, elderModeProvider, child) {
          return MaterialApp(
            title: '宝贝爱',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.getThemeData(elderModeProvider.isElderMode),
            home: const SplashPage(),
            locale: const Locale('zh', 'CN'),
          );
        },
      ),
    );
  }
}
