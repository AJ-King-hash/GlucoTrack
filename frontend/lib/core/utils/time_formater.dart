import 'package:intl/intl.dart';

class TimeFormatter {
  static String format(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }
}
