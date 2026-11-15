import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _indonesianFormat = DateFormat('dd MMMM yyyy', 'id_ID');
  static final DateFormat _shortFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _yearFormat = DateFormat('yyyy');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');

  static String formatShort(DateTime date) {
    try {
      return _shortFormat.format(date);
    } catch (_) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  static String formatFull(DateTime date) {
    try {
      return _indonesianFormat.format(date);
    } catch (_) {
      return _shortFormat.format(date);
    }
  }

  static String formatYear(DateTime date) {
    return _yearFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    try {
      return _monthYearFormat.format(date);
    } catch (_) {
      return '${date.month}/${date.year}';
    }
  }
}
