import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:ui' show PathMetric;
import 'dart:async';
import 'dart:typed_data';
import '../../../models/bukti_absensi.dart';
import '../../../models/lokasi_absensi.dart';
import '../../../services/layanan_kamera.dart';
import '../../../services/layanan_waktu.dart';

class VerifikasiWajahScreen extends StatefulWidget {
  const VerifikasiWajahScreen({super.key, required this.lokasi});

  final LokasiAbsensi lokasi;

  @override
  State<VerifikasiWajahScreen> createState() => _VerifikasiWajahScreenState();
}

class _VerifikasiWajahScreenState extends State<VerifikasiWajahScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _spinController;

  late Timer _timer;
  String _currentTime = "";
  final LayananKamera _layananKamera = LayananKamera();
  Uint8List? _foto;
  DateTime? _waktuFoto;
  bool _isCapturing = false;
  bool _isFrontCamera = true;

  final Color primary = const Color(0xFF2563EB);
  final Color primaryContainer = const Color(0xFF1D4ED8);
  final Color primaryFixed = const Color(0xFFCCE5FF);
  final Color secondary = const Color(0xFF396477);
  final Color secondaryContainer = const Color(0xFFBAE6FD);
  final Color surface = const Color(0xFFF4F6FB);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color surfaceContainerLow = const Color(0xFFEFF6FF);
  final Color surfaceContainer = const Color(0xFFEFF6FF);
  final Color onSurface = const Color(0xFF0B1C30);
  final Color onSurfaceVariant = const Color(0xFF5A6672);
  final Color onPrimary = const Color(0xFFFFFFFF);
  final Color onSecondaryFixedVariant = const Color(0xFF1E4C5F);

  @override
  void initState() {
    super.initState();

    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) _updateTime();
    });

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  void _updateTime() {
    setState(() {
      _currentTime = LayananWaktu.formatJam(
        LayananWaktu.sekarang(),
        tampilDetik: true,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _handleShutter() async {
    if (_isCapturing) return;

    if (_foto != null) {
      Navigator.pushReplacementNamed(
        context,
        '/absen_sukses',
        arguments: BuktiAbsensi(
          lokasi: widget.lokasi,
          foto: _foto!,
          waktuDiambil: _waktuFoto ?? LayananWaktu.sekarang(),
        ),
      );
      return;
    }

    setState(() => _isCapturing = true);
    try {
      final hasilFoto = await _layananKamera.ambilFoto(
        kameraDepan: _isFrontCamera,
      );
      if (hasilFoto == null || !mounted) return;

      final bytes = await hasilFoto.readAsBytes();
      if (!mounted) return;
      setState(() {
        _foto = bytes;
        _waktuFoto = LayananWaktu.sekarang();
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kamera gagal dibuka. Periksa izin kamera.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _retakePhoto() {
    setState(() {
      _foto = null;
      _waktuFoto = null;
    });
  }

  void _switchCamera() {
    setState(() => _isFrontCamera = !_isFrontCamera);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 12, 16, 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacementNamed(context, '/verifikasi_lokasi');
                      }
                    },
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1.2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          'assets/images/logo_cak_kebo_transparent.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CAK KEBO',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            height: 1.1,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        Text(
                          'Absensi Staf',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4ADE80),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'KAMERA AKTIF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: SizedBox(
                        width: 440,
                        child: Column(
                          children: [

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: secondaryContainer.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        color: primary, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LANGKAH 2 DARI 2 • SELFIE MASUK',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: onSecondaryFixedVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verifikasi Wajah',
                style: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: onSurface),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: primary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  'Posisikan wajah Anda tegak lurus di dalam bingkai',
                  style: TextStyle(fontSize: 12, color: secondary),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 340),

              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceContainerLow,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.lightBlue.withOpacity(0.12),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [

                      Align(
                        alignment: Alignment.topCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: surfaceContainerLowest.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.videocam,
                                      color: primary, size: 16),
                                  const SizedBox(width: 6),
                                    Text(
                                      _foto == null
                                        ? (_isFrontCamera
                                          ? 'KAMERA DEPAN'
                                          : 'KAMERA BELAKANG')
                                        : 'FOTO TERSIMPAN',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: onSurface)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: surfaceContainerLowest.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                        color: primary, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(_foto == null ? 'Siap' : 'Tinjau Foto',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: primary)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      Align(
                        alignment: Alignment.center,
                        child: _foto == null
                            ? Stack(
                          alignment: Alignment.center,
                          children: [

                            Container(
                              width: 150,
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: primary.withOpacity(0.6), width: 3),
                                borderRadius:
                                    const BorderRadius.all(Radius.elliptical(75, 100)),
                              ),
                            ),

                            RotationTransition(
                              turns: _spinController,
                              child: CustomPaint(
                                size: const Size(160, 210),
                                painter: DashedOvalPainter(
                                    color: primary.withOpacity(0.6)),
                              ),
                            ),

                            Positioned(
                              top: 80,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 2,
                                    color: primary.withOpacity(0.4),
                                  ),
                                  const SizedBox(width: 50),
                                  Container(
                                    width: 16,
                                    height: 2,
                                    color: primary.withOpacity(0.4),
                                  )
                                ],
                              ),
                            ),

                            Positioned(
                              bottom: -25,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: surfaceContainerLowest.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.light_mode,
                                        color: secondary, size: 14),
                                    const SizedBox(width: 4),
                                    Text('Pencahayaan Baik',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: secondary)),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox.expand(
                                  child: Image.memory(
                                    _foto!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                      ),

                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: surfaceContainerLowest.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.verified_user,
                                      color: primary, size: 18),
                                  const SizedBox(width: 8),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Validasi Otomatis',
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: onSurface)),
                                      Text('Anti Fake-GPS & Masker',
                                          style: TextStyle(
                                              fontSize: 10, color: secondary)),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: primary, shape: BoxShape.circle),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 340),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.lightBlue.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule, color: primary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            _currentTime,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: onSurface),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Shift Pagi',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: secondary),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: primary, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Koordinat ${widget.lokasi.koordinat} • Akurasi ${widget.lokasi.akurasiMeter.toStringAsFixed(0)}m',
                          style: TextStyle(fontSize: 12, color: onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.check_circle, color: primary, size: 14),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 340),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: surfaceContainerLowest,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)
                      ]
                    ),
                    child: IconButton(
                      tooltip: 'Ambil ulang foto',
                      icon: Icon(Icons.refresh, color: secondary),
                      onPressed: _foto == null ? null : _retakePhoto,
                    ),
                  ),

                  GestureDetector(
                    onTap: _isCapturing ? null : _handleShutter,
                    child: Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: surfaceContainerLowest,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: primary.withOpacity(0.22),
                              blurRadius: 32,
                              offset: const Offset(0, 16))
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: primaryFixed, shape: BoxShape.circle),
                        child: Container(
                          decoration: BoxDecoration(
                              color: primary, shape: BoxShape.circle),
                          child: _isCapturing
                              ? const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  _foto == null ? Icons.photo_camera : Icons.check,
                                  color: onPrimary,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: surfaceContainerLowest,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)
                      ]
                    ),
                    child: IconButton(
                      tooltip: 'Ganti kamera',
                      icon: Icon(Icons.flip_camera_ios, color: secondary),
                      onPressed: _foto == null ? _switchCamera : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              _isCapturing
                  ? 'Membuka kamera...'
                  : _foto == null
                      ? 'Ketuk tombol kamera untuk mengambil foto'
                      : 'Periksa foto, lalu ketuk centang untuk konfirmasi',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: secondary),
            ),
            const SizedBox(height: 8),

            TextButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/verifikasi_lokasi');
                }
              },
              child: Text(
                'Kembali ke Validasi Lokasi',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: secondary),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
        ),
      ),
    ),
    ),
    ),
    ),
    ],
    ),
    ),
    );
  }
}

class DashedOvalPainter extends CustomPainter {
  final Color color;
  DashedOvalPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashWidth = 8, dashSpace = 8;
    double perimeter = 2 * 3.14159 * ((size.width / 2 + size.height / 2) / 2);
    int dashCount = (perimeter / (dashWidth + dashSpace)).floor();

    Path path = Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    Path dashPath = Path();

    for (PathMetric measurePath in path.computeMetrics()) {
      double distance = 0;
      while (distance < measurePath.length) {
        dashPath.addPath(
          measurePath.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

