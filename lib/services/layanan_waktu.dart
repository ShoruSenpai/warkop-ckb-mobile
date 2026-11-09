import 'package:intl/intl.dart';

abstract final class LayananWaktu {
  static DateTime sekarang() => DateTime.now();

  static String zonaWaktu(DateTime waktu) {
    return switch (waktu.timeZoneOffset.inMinutes) {
      420 => 'WIB',
      480 => 'WITA',
      540 => 'WIT',
      _ => waktu.timeZoneName.isEmpty ? 'Waktu lokal' : waktu.timeZoneName,
    };
  }

  static String formatJam(DateTime waktu, {bool tampilDetik = false}) {
    final pola = tampilDetik ? 'HH:mm:ss' : 'HH:mm';
    return '${DateFormat(pola).format(waktu)} ${zonaWaktu(waktu)}';
  }

  static String formatTanggalIndonesia(DateTime waktu) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(waktu);
  }

  static String formatBulanIndonesia(DateTime waktu) {
    return DateFormat('MMMM yyyy', 'id_ID').format(waktu);
  }
}