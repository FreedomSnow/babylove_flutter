# BabyLove Flutter

一个支持 iOS、Android 和 HarmonyOS 的 Flutter 项目。

## 平台支持

- ✅ iOS
- ✅ Android
- ✅ HarmonyOS (鸿蒙)

## 开始使用

### 运行 iOS/Android

```bash
# 运行在 iOS 设备/模拟器
flutter run -d ios

# 运行在 Android 设备/模拟器
flutter run -d android
```

### 运行 HarmonyOS

HarmonyOS 项目位于 `ohos/` 目录下。

1. 使用 DevEco Studio 打开 `ohos/` 目录
2. 配置签名证书
3. 连接 HarmonyOS 设备或启动模拟器
4. 点击运行按钮

## 项目结构

```
babylove-flutter/
├── lib/              # Flutter 应用代码
├── ios/              # iOS 原生项目
├── android/          # Android 原生项目
├── ohos/             # HarmonyOS 原生项目
└── test/             # 测试代码
```

## 文档资源

- [Flutter 官方文档](https://docs.flutter.dev/)
- [Flutter 中文文档](https://flutter.cn/)
- [HarmonyOS 开发文档](https://developer.harmonyos.com/)
