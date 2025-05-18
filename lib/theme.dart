import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme
  double _fontSize = 16.0;

  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;

    ThemeProvider() {
    _loadSettings();
  }


 // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    notifyListeners();
  }


  // Toggle dark mode and save to SharedPreferences
  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify listeners immediately for UI update
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }





  // Change font size and save to SharedPreferences
  void setFontSize(double size) async {
    _fontSize = size;
    notifyListeners(); // Notify listeners immediately for UI update
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
  }




  // Get the actual TextStyle based on the current font size
  TextStyle get baseTextStyle => TextStyle(fontSize: _fontSize);
  TextStyle get bodyTextStyle => TextStyle(fontSize: _fontSize * 0.9);
  TextStyle get headingTextStyle => TextStyle(fontSize: _fontSize * 1.2);


}