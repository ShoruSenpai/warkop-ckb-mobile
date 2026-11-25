import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/lokasi_absensi.dart';

class LayananLokasi {
  LayananLokasi({bool? untukWeb}) : _untukWeb = untukWeb ?? kIsWeb;
  final bool _untukWeb;
  Future<LokasiAbsensi> deteksiLokasi() async {
    try {
      return await _deteksi().timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw const LayananLokasiException(
        'Lokasi belum diterima dalam 12 detik. Izinkan lokasi pada browser dan aktifkan layanan lokasi Windows, lalu coba lagi. Kamu tetap bisa memilih karyawan dan mendaftarkan wajah.',
      );
    } on PermissionDeniedException {
      throw const LayananLokasiException(
        'Izin lokasi ditolak. Buka izin situs pada browser, izinkan Lokasi, lalu coba lagi.',
      );
    } on PositionUpdateException {
      throw const LayananLokasiException(
        'Browser belum bisa menentukan lokasi. Periksa layanan lokasi Windows dan coba lewat Chrome atau Edge.',
      );
    }
  }

  Future<LokasiAbsensi> _deteksi() async {
    // On web, getCurrentPosition itself requests permission with a deadline.
    // requestPermission in geolocator_web performs a separate, unbounded lookup.
    if (!_untukWeb) {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LayananLokasiException(
          'Aktifkan layanan lokasi/GPS pada perangkat.',
        );
      }

      var izin = await Geolocator.checkPermission();
      if (izin == LocationPermission.denied) {
        izin = await Geolocator.requestPermission();
      }

      if (izin == LocationPermission.denied) {
        throw const LayananLokasiException('Izin lokasi belum diberikan.');
      }
      if (izin == LocationPermission.deniedForever) {
        throw const LayananLokasiException(
          'Izin lokasi ditolak permanen. Ubah izin aplikasi di Pengaturan.',
        );
      }
    }

    final posisi = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: _untukWeb ? LocationAccuracy.medium : LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      ),
    );

    if (posisi.isMocked) {
      throw const LayananLokasiException(
        'Lokasi simulasi terdeteksi. Matikan aplikasi lokasi palsu.',
      );
    }
    if (posisi.accuracy <= 0 || posisi.accuracy > 50) {
      throw LayananLokasiException(
        'Akurasi lokasi ±${posisi.accuracy.toStringAsFixed(0)} meter; presensi membutuhkan maksimal 50 meter. Aktifkan lokasi presisi Windows/browser atau coba browser Edge/Chrome. Pilihan karyawan tetap bisa dipakai.',
      );
    }
    return LokasiAbsensi(
      latitude: posisi.latitude,
      longitude: posisi.longitude,
      akurasiMeter: posisi.accuracy,
    );
  }
}

class LayananLokasiException implements Exception {
  const LayananLokasiException(this.pesan);

  final String pesan;

  @override
  String toString() => pesan;
}
