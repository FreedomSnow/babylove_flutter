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
    final baseFontSize = isElderMode ? 4.0 : 0.0;

    switch (_currentTheme) {
      case AppTheme.light:
        return _getLightTheme(baseFontSize);
      case AppTheme.dark:
        return _getDarkTheme(baseFontSize);
      case AppTheme.blue:
        return _getBlueTheme(baseFontSize);
      case AppTheme.pink:
        return _getPinkTheme(baseFontSize);
    }
  }

  ThemeData _getLightTheme(double fontSizeOffset) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18 + fontSizeOffset,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: _getTextTheme(fontSizeOffset, Colors.black87),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: TextStyle(fontSize: 16 + fontSizeOffset),
          padding: EdgeInsets.symmetric(vertical: 12 + fontSizeOffset / 2),
        ),
      ),
    );
  }

  ThemeData _getDarkTheme(double fontSizeOffset) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.blueGrey,
      primaryColor: Colors.blueGrey,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18 + fontSizeOffset,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: _getTextTheme(fontSizeOffset, Colors.white),
      cardTheme: const CardThemeData(
        color: Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: TextStyle(fontSize: 16 + fontSizeOffset),
          padding: EdgeInsets.symmetric(vertical: 12 + fontSizeOffset / 2),
        ),
      ),
    );
  }

  ThemeData _getBlueTheme(double fontSizeOffset) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.indigo,
      primaryColor: Colors.indigo,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18 + fontSizeOffset,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: _getTextTheme(fontSizeOffset, Colors.black87),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          textStyle: TextStyle(fontSize: 16 + fontSizeOffset),
          padding: EdgeInsets.symmetric(vertical: 12 + fontSizeOffset / 2),
        ),
      ),
    );
  }

  ThemeData _getPinkTheme(double fontSizeOffset) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.pink,
      primaryColor: Colors.pink,
      scaffoldBackgroundColor: const Color(0xFFFFF5F7),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18 + fontSizeOffset,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: _getTextTheme(fontSizeOffset, Colors.black87),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink,
          textStyle: TextStyle(fontSize: 16 + fontSizeOffset),
          padding: EdgeInsets.symmetric(vertical: 12 + fontSizeOffset / 2),
        ),
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
