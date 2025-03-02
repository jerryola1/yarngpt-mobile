import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'is_dark_mode';
  final SharedPreferences _prefs;
  bool _isDarkMode;

  ThemeService._({required SharedPreferences prefs, required bool isDarkMode})
      : _prefs = prefs,
        _isDarkMode = isDarkMode;

  static Future<ThemeService> create() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_themeKey) ?? false;
    return ThemeService._(prefs: prefs, isDarkMode: isDarkMode);
  }

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.grey[100],
      primaryColor: const Color(0xFFD4F58E),
      colorScheme: ColorScheme.light(
        primary: const Color(0xFFD4F58E),
        secondary: Colors.amber,
        surface: Colors.white,
        background: Colors.grey[100]!,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: const Color(0xFF1F1F1F),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF1F1F1F),
        secondary: Colors.amber,
        surface: const Color(0xFF2C2C2C),
        background: const Color(0xFF121212),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF2C2C2C),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
} 