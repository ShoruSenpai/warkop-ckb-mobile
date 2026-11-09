class LokasiAbsensi {
  const LokasiAbsensi({
    required this.latitude,
    required this.longitude,
    required this.akurasiMeter,
  });

  final double latitude;
  final double longitude;
  final double akurasiMeter;

  String get koordinat =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}