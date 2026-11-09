import 'dart:typed_data';

import 'lokasi_absensi.dart';

class BuktiAbsensi {
  const BuktiAbsensi({
    required this.lokasi,
    required this.foto,
    required this.waktuDiambil,
  });

  final LokasiAbsensi lokasi;
  final Uint8List foto;
  final DateTime waktuDiambil;
}