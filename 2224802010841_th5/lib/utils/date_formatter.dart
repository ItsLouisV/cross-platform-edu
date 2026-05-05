import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DateFormatter {
  /// Format created date as relative time (e.g., "2 hours ago")
  static String formatCreatedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    // If within the last 7 days, show relative time
    if (difference.inDays < 7) {
      return timeago.format(date, locale: 'vi');
    }

    // Otherwise show formatted date
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format deadline as an absolute date with time
  static String formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return 'Quá hạn ${DateFormat('dd/MM').format(deadline)}';
    }

    if (difference.inDays == 0) {
      return 'Hôm nay ${DateFormat('HH:mm').format(deadline)}';
    }

    if (difference.inDays == 1) {
      return 'Ngày mai ${DateFormat('HH:mm').format(deadline)}';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} ngày nữa';
    }

    return DateFormat('dd/MM/yyyy HH:mm').format(deadline);
  }

  /// Format date for display in edit screens
  static String formatFullDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Check if a deadline is overdue
  static bool isOverdue(DateTime deadline) {
    return deadline.isBefore(DateTime.now());
  }
}
