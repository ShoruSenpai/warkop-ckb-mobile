import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ckb/services/layanan_waktu.dart';

void main() {
  test('uses the system local time and time zone', () {
    final waktuSistem = DateTime.now();
    final waktuLayanan = LayananWaktu.sekarang();

    expect(waktuLayanan.isUtc, isFalse);
    expect(waktuLayanan.timeZoneOffset, waktuSistem.timeZoneOffset);
    expect(
      LayananWaktu.formatJam(waktuLayanan),
      endsWith(LayananWaktu.zonaWaktu(waktuLayanan)),
    );
  });
}