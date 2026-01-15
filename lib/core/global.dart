import 'package:flutter/widgets.dart';

/// 全局 NavigatorKey，供非 UI 层（例如网络层）触发导航和弹窗使用
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
