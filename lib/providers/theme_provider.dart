import 'package:flutter/material.dart';
import '../services/storage_service.dart';

enum AppTheme {
  light,
  dark,
  blue,
  pink,
}

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.light;
  final StorageService _storageService = StorageService();

  AppTheme get currentTheme => _currentTheme;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeIndex = await _storageService.getTheme();
    if (themeIndex != null && themeIndex < AppTheme.values.length) {
      _currentTheme = AppTheme.values[themeIndex];
      notifyListeners();
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    await _storageService.saveTheme(theme.index);
    notifyListeners();
  }

  ThemeData getThemeData(bool isElderMode) {
    final fontSizeOffset = isElderMode ? 4.0 : 0.0;

    // 为每个主题定义一个种子色，所有控件使用同一 ColorScheme
    late final Color seed;
    late final Brightness brightness;
    late final Color scaffoldBackground;

    switch (_currentTheme) {
      case AppTheme.light:
        seed = Colors.blue;
        brightness = Brightness.light;
        scaffoldBackground = Colors.white;
        break;
      case AppTheme.dark:
        seed = Colors.blueGrey;
        brightness = Brightness.dark;
        scaffoldBackground = const Color(0xFF121212);
        break;
      case AppTheme.blue:
        seed = Colors.indigo;
        brightness = Brightness.light;
        scaffoldBackground = const Color(0xFFF5F7FA);
        break;
      case AppTheme.pink:
        seed = Colors.pink;
        brightness = Brightness.light;
        scaffoldBackground = const Color(0xFFFFF5F7);
        break;
    }

    final colorScheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,

      // AppBar 使用主色，文字与图标按 Scheme 对比色
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 18 + fontSizeOffset,
          fontWeight: FontWeight.w600,
        ),
      ),

      // 文字主题按明暗模式设置基础颜色
      textTheme: _getTextTheme(
        fontSizeOffset,
        brightness == Brightness.dark ? Colors.white : Colors.black87,
      ),

      // 卡片与圆角统一
      cardTheme: CardThemeData(
        color: brightness == Brightness.dark ? const Color(0xFF1E1E1E) : null,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // 常用控件主题，统一高亮/边框/交互态
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: TextStyle(fontSize: 16 + fontSizeOffset, fontWeight: FontWeight.w600),
          padding: EdgeInsets.symmetric(vertical: 12 + fontSizeOffset / 2),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.2),
          textStyle: TextStyle(fontSize: 16 + fontSizeOffset, fontWeight: FontWeight.w600),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: TextStyle(fontSize: 16 + fontSizeOffset, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colorScheme.primary),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: brightness == Brightness.dark ? const Color(0xFF2C2C2C) : colorScheme.surface,
        contentTextStyle: TextStyle(color: colorScheme.onSurface),
        actionTextColor: colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? colorScheme.primary.withOpacity(0.5) : null),
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? colorScheme.primary : null),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? colorScheme.primary : null),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStatePropertyAll(colorScheme.primary),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        thumbColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.primary.withOpacity(0.24),
      ),
      chipTheme: ChipThemeData(
        selectedColor: colorScheme.primary.withOpacity(0.12),
        secondarySelectedColor: colorScheme.primary.withOpacity(0.24),
        labelStyle: TextStyle(color: colorScheme.onSurface),
        secondaryLabelStyle: TextStyle(color: colorScheme.onPrimary),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        indicatorColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  TextTheme _getTextTheme(double fontSizeOffset, Color baseColor) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 32 + fontSizeOffset, color: baseColor),
      displayMedium: TextStyle(fontSize: 28 + fontSizeOffset, color: baseColor),
      displaySmall: TextStyle(fontSize: 24 + fontSizeOffset, color: baseColor),
      headlineLarge: TextStyle(fontSize: 22 + fontSizeOffset, color: baseColor, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 20 + fontSizeOffset, color: baseColor, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontSize: 18 + fontSizeOffset, color: baseColor, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 16 + fontSizeOffset, color: baseColor, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 14 + fontSizeOffset, color: baseColor, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontSize: 12 + fontSizeOffset, color: baseColor, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16 + fontSizeOffset, color: baseColor),
      bodyMedium: TextStyle(fontSize: 14 + fontSizeOffset, color: baseColor),
      bodySmall: TextStyle(fontSize: 12 + fontSizeOffset, color: baseColor),
      labelLarge: TextStyle(fontSize: 14 + fontSizeOffset, color: baseColor),
      labelMedium: TextStyle(fontSize: 12 + fontSizeOffset, color: baseColor),
      labelSmall: TextStyle(fontSize: 10 + fontSizeOffset, color: baseColor),
    );
  }
}
