import 'package:intl/intl.dart';

class AppDateUtils {
  const AppDateUtils._();

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }
    return _dateFormat.format(dateTime);
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }
    return _dateTimeFormat.format(dateTime);
  }
}
