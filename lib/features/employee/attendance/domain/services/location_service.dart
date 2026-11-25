import 'package:geolocator/geolocator.dart';

import '../models/attendance_location.dart';

class LocationService {
  Future<AttendanceLocation> detectLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationServiceException(
        'Aktifkan layanan lokasi/GPS pada perangkat.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationServiceException('Izin lokasi belum diberikan.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        'Izin lokasi ditolak permanen. Ubah izin aplikasi di Pengaturan.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
    if (position.isMocked) {
      throw const LocationServiceException(
        'Lokasi tiruan tidak dapat digunakan untuk presensi.',
      );
    }

    return AttendanceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
    );
  }
}

class LocationServiceException implements Exception {
  const LocationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
