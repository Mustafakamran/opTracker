import 'package:intl/intl.dart';
import '../constants/enums.dart';

class DateHelpers {
  DateHelpers._();

  static final _fullDate = DateFormat('MMM d, yyyy');
  static final _shortDate = DateFormat('MMM d');
  static final _time = DateFormat('h:mm a');
  static final _dayOfWeek = DateFormat('EEE');
  static final _monthYear = DateFormat('MMMM yyyy');

  static String full(DateTime date) => _fullDate.format(date);
  static String short(DateTime date) => _shortDate.format(date);
  static String time(DateTime date) => _time.format(date);
  static String dayOfWeek(DateTime date) => _dayOfWeek.format(date);
  static String monthYear(DateTime date) => _monthYear.format(date);

  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _shortDate.format(date);
  }

  static String groupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (now.difference(date).inDays < 7) return _dayOfWeek.format(date);
    return _fullDate.format(date);
  }

  static (DateTime start, DateTime end) rangeForPeriod(TimePeriod period) {
    final now = DateTime.now();
    switch (period) {
      case TimePeriod.daily:
        final start = DateTime(now.year, now.month, now.day);
        return (start, now);
      case TimePeriod.weekly:
        final start = now.subtract(Duration(days: now.weekday - 1));
        return (DateTime(start.year, start.month, start.day), now);
      case TimePeriod.monthly:
        return (DateTime(now.year, now.month, 1), now);
      case TimePeriod.yearly:
        return (DateTime(now.year, 1, 1), now);
      case TimePeriod.custom:
        return (DateTime(now.year, now.month, 1), now);
    }
  }
}
