import 'package:flutter/material.dart';

import 'light_theme.dart';
import 'dark_theme.dart';

/// Theme orchestrator — provides light and dark ThemeData.
class AppTheme {
  AppTheme._();

  /// Light theme for the application.
  static ThemeData get lightTheme => buildLightTheme();

  /// Dark theme for the application.
  static ThemeData get darkTheme => buildDarkTheme();
}
