import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Application-wide logger utility.
class AppLogger {
  AppLogger._();

  static const String _defaultName = 'AI_Research';

  /// Log a debug message (only in debug builds).
  static void debug(String message, {String? name}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: name ?? _defaultName,
        level: 500, // FINE
      );
    }
  }

  /// Log an info message.
  static void info(String message, {String? name}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: name ?? _defaultName,
        level: 800, // INFO
      );
    }
  }

  /// Log a warning.
  static void warning(String message, {String? name}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: name ?? _defaultName,
        level: 900, // WARNING
      );
    }
  }

  /// Log an error with optional exception and stack trace.
  ///
  static void error(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      developer.log(
        message,
        name: name ?? _defaultName,
        level: 1000, // SEVERE
        error: error,
        stackTrace: stackTrace,
      );
    }
    // TODO(Phase 13): In production, send to crash reporting service
    // e.g., FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
