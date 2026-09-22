import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme_state.dart';

/// Cubit for managing theme mode (light/dark/system).
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState());

  /// Sets the theme to a specific mode.
  void setThemeMode(ThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
  }

  /// Toggles between light and dark mode.
  /// If currently using system mode, switches to dark.
  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    emit(state.copyWith(themeMode: newMode));
  }
}
