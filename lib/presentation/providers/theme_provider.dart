import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState {
  final ThemeMode mode;
  final Color seedColor;

  ThemeState({
    required this.mode,
    required this.seedColor,
  });

  ThemeState copyWith({
    ThemeMode? mode,
    Color? seedColor,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      seedColor: seedColor ?? this.seedColor,
    );
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState(mode: ThemeMode.system, seedColor: Colors.blue)) {
    _loadTheme();
  }

  static const _keyMode = 'theme_mode';
  static const _keyColor = 'theme_color'; // Stores int value

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Mode
    final themeString = prefs.getString(_keyMode);
    ThemeMode mode;
    if (themeString == 'light') {
      mode = ThemeMode.light;
    } else if (themeString == 'dark') {
      mode = ThemeMode.dark;
    } else {
      mode = ThemeMode.system;
    }

    // Load Color
    final colorInt = prefs.getInt(_keyColor);
    Color seedColor = Colors.blue;
    if (colorInt != null) {
      seedColor = Color(colorInt);
    }

    state = ThemeState(mode: mode, seedColor: seedColor);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    final prefs = await SharedPreferences.getInstance();
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
      default:
        value = 'system';
        break;
    }
    await prefs.setString(_keyMode, value);
  }

  Future<void> setSeedColor(Color color) async {
    state = state.copyWith(seedColor: color);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyColor, color.value);
  }
}
