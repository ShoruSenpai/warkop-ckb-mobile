class AttendanceLocation {
  const AttendanceLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;

  String get coordinates =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}
