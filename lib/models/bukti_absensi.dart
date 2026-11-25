import 'dart:typed_data';

import 'lokasi_absensi.dart';

class BuktiAbsensi {
  const BuktiAbsensi({
    required this.lokasi,
    required this.foto,
    required this.waktuDiambil,
    required this.id,
    required this.jenis,
    required this.namaKaryawan,
    required this.namaOutlet,
  });

  final LokasiAbsensi lokasi;
  final Uint8List foto;
  final DateTime waktuDiambil;
  final int id;
  final String jenis;
  final String namaKaryawan;
  final String namaOutlet;
}
