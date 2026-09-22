/// Date and time formatting utility using `intl`.
library;

import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// Short calendar date, e.g. "Sep 9, 2026"
  static String formatDate(DateTime dateTime) {
    return DateFormat.yMMMd().format(dateTime);
  }

  /// Time of day, e.g. "2:30 PM"
  static String formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }

  /// Date and time combined, e.g. "Sep 9, 2026, 2:30 PM"
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)}, ${formatTime(dateTime)}';
  }

  /// Relative human-readable time, e.g. "Just now", "5m ago", "3h ago", "Yesterday", or "Sep 9".
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      return formatDate(dateTime);
    }

    if (difference.inSeconds < 45) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '${mins}m ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '${hours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDate(dateTime);
    }
  }
}
