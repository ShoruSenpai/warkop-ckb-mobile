import 'package:intl/intl.dart';

abstract final class TimeService {
  static DateTime now() => DateTime.now();

  static String timeZoneLabel(DateTime dateTime) {
    return switch (dateTime.timeZoneOffset.inMinutes) {
      420 => 'WIB',
      480 => 'WITA',
      540 => 'WIT',
      _ =>
        dateTime.timeZoneName.isEmpty ? 'Waktu lokal' : dateTime.timeZoneName,
    };
  }

  static String formatTime(DateTime dateTime, {bool showSeconds = false}) {
    final pattern = showSeconds ? 'HH:mm:ss' : 'HH:mm';
    return '${DateFormat(pattern).format(dateTime)} ${timeZoneLabel(dateTime)}';
  }

  static String formatIndonesianDate(DateTime dateTime) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dateTime);
  }

  static String formatIndonesianMonth(DateTime dateTime) {
    return DateFormat('MMMM yyyy', 'id_ID').format(dateTime);
  }
}
