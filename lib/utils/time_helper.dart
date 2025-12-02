import 'package:intl/intl.dart';

class TimeHelper {
  /// Format timestamp to "hh:mm a" e.g., 12:30 PM
  static String formatTime(DateTime timestamp) {
    return DateFormat('hh:mm a').format(timestamp);
  }

  /// Format date and time e.g., "Mon, 27 Nov 12:30 PM"
  static String formatDateTime(DateTime timestamp) {
    return DateFormat('EEE, dd MMM hh:mm a').format(timestamp);
  }

  /// Optional: show "Today", "Yesterday", or date
  static String formatChatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp).inDays;

    if (difference == 0) return DateFormat('hh:mm a').format(timestamp);
    if (difference == 1) return 'Yesterday ${DateFormat('hh:mm a').format(timestamp)}';
    return DateFormat('dd/MM/yyyy hh:mm a').format(timestamp);
  }
}
