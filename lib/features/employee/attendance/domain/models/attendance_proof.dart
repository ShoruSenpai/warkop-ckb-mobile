import 'dart:typed_data';

import 'attendance_location.dart';

class AttendanceProof {
  const AttendanceProof({
    required this.location,
    required this.photo,
    required this.capturedAt,
    this.serverResponse = const {},
  });

  final AttendanceLocation location;
  final Uint8List photo;
  final DateTime capturedAt;
  final Map<String, dynamic> serverResponse;
}
