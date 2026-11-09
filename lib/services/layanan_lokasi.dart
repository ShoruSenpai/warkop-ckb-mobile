import 'package:geolocator/geolocator.dart';

import '../models/lokasi_absensi.dart';

class LayananLokasi {
  Future<LokasiAbsensi> deteksiLokasi() async {
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
      throw const LayananLokasiException(
        'Izin lokasi belum diberikan.',
      );
    }
    if (izin == LocationPermission.deniedForever) {
      throw const LayananLokasiException(
        'Izin lokasi ditolak permanen. Ubah izin aplikasi di Pengaturan.',
      );
    }

    final posisi = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );

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