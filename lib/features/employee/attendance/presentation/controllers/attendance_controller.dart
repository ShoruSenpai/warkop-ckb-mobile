import 'dart:typed_data';

import '../../data/repositories/attendance_repository.dart';

class AttendanceController {
  const AttendanceController(this._repository);
  final AttendanceRepository _repository;

  Future<Map<String, dynamic>> checkIn({
    required Uint8List photo,
    required String fileName,
    required double latitude,
    required double longitude,
  }) => _repository.checkIn(
    photo: photo,
    fileName: fileName,
    latitude: latitude,
    longitude: longitude,
  );
}
