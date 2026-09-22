import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Theme state — holds the current theme mode.
/// WHY THIS EXISTS:
/// BLoC/Cubit requires a state class to represent the current state.
/// By making this Equatable, BLoC can efficiently compare states.
/// If the old state equals the new state, no rebuild happens.
class ThemeState extends Equatable {
  const ThemeState({this.themeMode = ThemeMode.system});

  /// The current theme mode.
  final ThemeMode themeMode;

  /// Whether dark mode is active.
  bool get isDarkMode => themeMode == ThemeMode.dark;

  /// Creates a copy with optional modifications.
  ///
  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }

  @override
  List<Object?> get props => [themeMode];
}
