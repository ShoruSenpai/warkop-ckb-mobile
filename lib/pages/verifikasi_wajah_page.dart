import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../config/app_config.dart';
import '../services/session.dart';
import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'dart:ui' show PathMetric;
import 'dart:async';
import 'package:intl/intl.dart';

class VerifikasiWajahScreen extends StatefulWidget {
  const VerifikasiWajahScreen({super.key});

  @override
  State<VerifikasiWajahScreen> createState() => _VerifikasiWajahScreenState();
}

class _VerifikasiWajahScreenState extends State<VerifikasiWajahScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _spinController;

  CameraController? _cam;
  List<CameraDescription> _availableCameras = [];
  int _selectedCameraIndex = 0;
  bool _isFlashOn = false;
  bool _isScreenFlashActive = false;
  bool _camReady = false;
  bool _sending = false;
  String? _camError;

  // Google ML Kit Face Detector
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: false,
      enableLandmarks: false,
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.1,
    ),
  );

  bool _isFaceDetected = false;
  String _faceStatusText = 'Arahkan wajah ke dalam bingkai';
  Color _faceStatusColor = const Color(0xFFEF4444);
  bool _isStreaming = false;
  bool _isProcessingFrame = false;
  DateTime _lastFrameProcessed = DateTime.now();

  static final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  Uint8List _yuv420ToNv21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int ySize = width * height;
    final int uvSize = width * height ~/ 2;
    final Uint8List nv21 = Uint8List(ySize + uvSize);

    // 1. Copy Y plane
    final Plane yPlane = image.planes[0];
    final Uint8List yBytes = yPlane.bytes;
    if (yPlane.bytesPerRow == width) {
      nv21.setRange(0, ySize, yBytes);
    } else {
      int yOffset = 0;
      for (int row = 0; row < height; row++) {
        final int srcOffset = row * yPlane.bytesPerRow;
        nv21.setRange(yOffset, yOffset + width, yBytes.sublist(srcOffset, srcOffset + width));
        yOffset += width;
      }
    }

    // 2. Interleave V and U for NV21 format
    final Plane uPlane = image.planes[1];
    final Plane vPlane = image.planes[2];
    final Uint8List uBytes = uPlane.bytes;
    final Uint8List vBytes = vPlane.bytes;

    final int uPixelStride = uPlane.bytesPerPixel ?? 1;
    final int vPixelStride = vPlane.bytesPerPixel ?? 1;
    final int uRowStride = uPlane.bytesPerRow;
    final int vRowStride = vPlane.bytesPerRow;

    int uvOffset = ySize;
    final int halfHeight = height ~/ 2;
    final int halfWidth = width ~/ 2;

    for (int row = 0; row < halfHeight; row++) {
      final int uRowOffset = row * uRowStride;
      final int vRowOffset = row * vRowStride;
      for (int col = 0; col < halfWidth; col++) {
        final int vIndex = vRowOffset + col * vPixelStride;
        final int uIndex = uRowOffset + col * uPixelStride;
        if (vIndex < vBytes.length && uIndex < uBytes.length && uvOffset + 1 < nv21.length) {
          nv21[uvOffset++] = vBytes[vIndex];
          nv21[uvOffset++] = uBytes[uIndex];
        }
      }
    }

    return nv21;
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cam == null || _availableCameras.isEmpty) return null;
    final camera = _availableCameras[_selectedCameraIndex];
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isAndroid) {
      var rotationCompensation = _orientations[_cam!.value.deviceOrientation] ?? 0;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    } else {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }
    rotation ??= InputImageRotation.rotation0deg;

    final bytes = _yuv420ToNv21(image);

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessingFrame || !mounted || _sending) return;
    if (DateTime.now().difference(_lastFrameProcessed).inMilliseconds < 250) return;
    _isProcessingFrame = true;
    _lastFrameProcessed = DateTime.now();

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);
      if (!mounted || _sending) return;

      if (faces.isNotEmpty) {
        debugPrint('ML Kit Deteksi Wajah: BERHASIL! ${faces.length} wajah ditemukan');
        if (!_isFaceDetected) {
          setState(() {
            _isFaceDetected = true;
            _faceStatusText = 'Wajah Terdeteksi • Siap Presensi';
            _faceStatusColor = const Color(0xFF2563EB);
          });
        }
      } else {
        if (_isFaceDetected) {
          setState(() {
            _isFaceDetected = false;
            _faceStatusText = 'Arahkan wajah ke dalam bingkai';
            _faceStatusColor = const Color(0xFFEF4444);
          });
        }
      }
    } catch (e) {
      debugPrint('Error deteksi wajah ML Kit: $e');
    } finally {
      _isProcessingFrame = false;
    }
  }

  Future<void> _startImageStream() async {
    if (_cam == null || !_camReady || _isStreaming) return;
    _isStreaming = true;
    try {
      await _cam!.startImageStream((image) {
        if (_isStreaming) _processCameraImage(image);
      });
    } catch (e) {
      debugPrint('Error starting image stream: $e');
      _isStreaming = false;
    }
  }

  Future<void> _stopImageStream() async {
    if (_cam == null || !_isStreaming) return;
    _isStreaming = false;
    try {
      await _cam!.stopImageStream();
    } catch (e) {
      debugPrint('Error stopping image stream: $e');
    }
  }

  Future<void> _initCamera([int? cameraIndex]) async {
    try {
      if (_availableCameras.isEmpty) {
        _availableCameras = await availableCameras();
      }
      if (_availableCameras.isEmpty) throw 'Kamera tidak ditemukan';

      int index = cameraIndex ?? _selectedCameraIndex;
      if (cameraIndex == null) {
        final frontIdx = _availableCameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
        );
        index = frontIdx != -1 ? frontIdx : 0;
      }
      _selectedCameraIndex = index;

      final ctrl = CameraController(
        _availableCameras[index],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        _cam = ctrl;
        _camReady = true;
        _camError = null;
        _isFlashOn = false;
        _isFaceDetected = false;
      });
      _startImageStream();
    } catch (e) {
      if (!mounted) return;
      setState(() => _camError = 'Kamera tidak bisa dibuka (cek izin kamera)');
    }
  }

  Future<void> _switchCamera() async {
    if (_availableCameras.length < 2 || _cam == null) {
      _toast('Hanya satu kamera yang terdeteksi di perangkat');
      return;
    }
    await _stopImageStream();
    final nextIndex = (_selectedCameraIndex + 1) % _availableCameras.length;
    await _cam?.dispose();
    setState(() {
      _cam = null;
      _camReady = false;
      _isFlashOn = false;
      _isFaceDetected = false;
    });
    await _initCamera(nextIndex);
  }

  Future<void> _toggleFlash() async {
    if (_cam == null || !_camReady) return;
    final isFront = _availableCameras.isNotEmpty &&
        _availableCameras[_selectedCameraIndex].lensDirection ==
            CameraLensDirection.front;

    if (isFront) {
      final newFlash = !_isFlashOn;
      setState(() => _isFlashOn = newFlash);
      _toast(newFlash ? 'Screen Flash AKTIF (Layar Selfie Terang)' : 'Flash dimatikan');
    } else {
      try {
        final newFlash = !_isFlashOn;
        await _cam!.setFlashMode(newFlash ? FlashMode.torch : FlashMode.off);
        setState(() => _isFlashOn = newFlash);
        _toast(newFlash ? 'Lampu Flash LED Belakang AKTIF' : 'Flash dimatikan');
      } catch (e) {
        debugPrint('Gagal toggle flash belakang: $e');
        final newFlash = !_isFlashOn;
        setState(() => _isFlashOn = newFlash);
        _toast(newFlash ? 'Screen Flash AKTIF' : 'Flash dimatikan');
      }
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  late Timer _timer;
  String _currentTime = "";

  final Color primary = AppColors.primary;
  final Color primaryContainer = AppColors.primaryDark;
  final Color primaryFixed = const Color(0xFFCCE5FF);
  final Color secondary = const Color(0xFF396477);
  final Color secondaryContainer = const Color(0xFFBAE6FD);
  final Color surface = AppColors.surface;
  final Color surfaceContainerLowest = AppColors.surfaceContainerLowest;
  final Color surfaceContainerLow = AppColors.surfaceContainerLow;
  final Color surfaceContainer = const Color(0xFFEFF6FF);
  final Color onSurface = const Color(0xFF0B1C30);
  final Color onSurfaceVariant = const Color(0xFF5A6672);
  final Color onPrimary = const Color(0xFFFFFFFF);
  final Color onSecondaryFixedVariant = const Color(0xFF1E4C5F);

  @override
  void initState() {
    super.initState();
    _initCamera();

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
      _currentTime = "${DateFormat('HH:mm:ss').format(DateTime.now())} WIB";
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopImageStream();
    _cam?.dispose();
    _spinController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _handleShutter() async {
    if (_sending) return;
    if (!_camReady || _cam == null) {
      _toast(_camError ?? 'Kamera belum siap');
      return;
    }
    if (!_isFaceDetected) {
      _toast('Wajah tidak terdeteksi! Posisikan wajah Anda tepat di dalam bingkai.');
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Map || args['lat'] == null || args['lng'] == null) {
      _toast('Data lokasi tidak ada, ulangi verifikasi lokasi');
      return;
    }
    setState(() => _sending = true);
    await _stopImageStream();

    final isFront = _availableCameras.isNotEmpty &&
        _availableCameras[_selectedCameraIndex].lensDirection ==
            CameraLensDirection.front;

    if (_isFlashOn && isFront) {
      setState(() => _isScreenFlashActive = true);
      await Future.delayed(const Duration(milliseconds: 300));
    }

    try {
      final XFile foto = await _cam!.takePicture();
      if (_isScreenFlashActive && mounted) {
        setState(() => _isScreenFlashActive = false);
      }
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final lat = (args['lat'] as num).toDouble();
      final lng = (args['lng'] as num).toDouble();

      final dist = Geolocator.distanceBetween(
        lat,
        lng,
        AppConfig.outletLat,
        AppConfig.outletLng,
      );
      if (dist > AppConfig.maxRadiusMeter) {
        final distStr = dist >= 1000
            ? '${(dist / 1000).toStringAsFixed(1)} km'
            : '${dist.round()} meter';
        _toast('Presensi ditolak: Anda berada di luar radius outlet ($distStr)!');
        setState(() => _sending = false);
        return;
      }

      String? photoUrl;
      try {
        final client = Supabase.instance.client;
        final file = File(foto.path);
        final ext = foto.path.split('.').last;
        final fileName = 'selfie_${Session.employeeId}_${now.millisecondsSinceEpoch}.$ext';
        await client.storage.from('attendance-photos').upload(fileName, file);
        photoUrl = client.storage.from('attendance-photos').getPublicUrl(fileName);
      } catch (uploadErr) {
        debugPrint('Upload foto storage gagal: $uploadErr');
        photoUrl = 'local://${foto.path.split(Platform.pathSeparator).last}';
      }

      Map<String, dynamic>? record;
      bool isLate = false;
      int lateMinutes = 0;
      try {
        final client = Supabase.instance.client;
        Map<String, dynamic>? sched;
        try {
          sched = await client
              .from('employee_schedules')
              .select()
              .eq('employee_id', Session.employeeId)
              .eq('schedule_date', dateStr)
              .maybeSingle();
        } catch (_) {}

        final rawStart = (sched?['start_time'] ?? '').toString();
        DateTime shiftStart;
        DateTime shiftTolerance;

        if (sched != null && rawStart.isNotEmpty && !rawStart.startsWith('00:00')) {
          final parts = rawStart.split(':');
          final h = int.tryParse(parts[0]) ?? 8;
          final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
          shiftStart = DateTime(now.year, now.month, now.day, h, m);
          shiftTolerance = shiftStart.add(const Duration(minutes: 15));

          final earliest = shiftStart.subtract(const Duration(minutes: 60));
          if (now.isBefore(earliest)) {
            final earliestStr = DateFormat('HH:mm').format(earliest);
            _toast('Presensi ditolak: Belum waktunya absen masuk! Presensi baru dibuka pukul $earliestStr WIB.');
            setState(() => _sending = false);
            return;
          }

          final rawEnd = (sched['end_time'] ?? '').toString();
          if (rawEnd.isNotEmpty && !rawEnd.startsWith('00:00')) {
            final endParts = rawEnd.split(':');
            final eh = int.tryParse(endParts[0]) ?? 16;
            final em = endParts.length > 1 ? (int.tryParse(endParts[1]) ?? 0) : 0;
            final shiftEnd = DateTime(now.year, now.month, now.day, eh, em);
            if (now.isAfter(shiftEnd)) {
              final shiftEndStr = DateFormat('HH:mm').format(shiftEnd);
              _toast('Presensi ditolak: Shift telah berakhir pukul $shiftEndStr WIB (Alfa).');
              setState(() => _sending = false);
              return;
            }
          }
        } else {
          shiftStart = DateTime(now.year, now.month, now.day, 8, 0);
          shiftTolerance = DateTime(now.year, now.month, now.day, 8, 15);
        }

        isLate = now.isAfter(shiftTolerance);
        lateMinutes = isLate ? now.difference(shiftStart).inMinutes : 0;
        final attendanceStatus = isLate ? 'late' : 'present';
        final attendanceNotes = isLate ? 'Terlambat $lateMinutes menit' : 'Tepat Waktu';

        final res = await client.from('attendances').insert({
          'employee_id': Session.employeeId,
          'attendance_type': 'regular',
          'attendance_date': dateStr,
          'clock_in': now.toUtc().toIso8601String(),
          'latitude': lat,
          'longitude': lng,
          'selfie_image_url': photoUrl,
          'status': attendanceStatus,
          'notes': attendanceNotes,
        }).select().maybeSingle();
        record = res;
        Session.todayAttendance = record ?? {
          'employee_id': Session.employeeId,
          'attendance_date': dateStr,
          'clock_in': now.toUtc().toIso8601String(),
          'status': attendanceStatus,
          'notes': attendanceNotes,
        };
        Session.attendanceDate = dateStr;
      } catch (dbErr) {
        debugPrint('Simpan attendances gagal: $dbErr');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();

      Navigator.pushReplacementNamed(context, '/absen_sukses', arguments: {
        'checked_in_at': now.toIso8601String(),
        'status': 'success',
        'record': record,
        'is_late': isLate,
        'late_minutes': lateMinutes,
      });
    } catch (e) {
      _toast('Gagal mengambil foto atau absen: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFront = _availableCameras.isEmpty ||
        _availableCameras[_selectedCameraIndex].lensDirection ==
            CameraLensDirection.front;
    final isScreenFlash = _isFlashOn && isFront;

    return Scaffold(
      backgroundColor: isScreenFlash ? Colors.white : const Color(0xFF0B132B),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header atas
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: Row(
                    children: [
                      // Tombol kembali
                      InkWell(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacementNamed(context, '/verifikasi_lokasi');
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isScreenFlash
                                ? const Color(0xFFF1F5F9)
                                : Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isScreenFlash
                                  ? const Color(0xFFCBD5E1)
                                  : Colors.white24,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: isScreenFlash ? const Color(0xFF0F172A) : Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Judul halaman
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isScreenFlash
                              ? const Color(0xFFE0F2FE)
                              : Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isScreenFlash
                                ? const Color(0xFFBAE6FD)
                                : Colors.white24,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Image.asset(
                              'assets/images/logo_cak_kebo_transparent.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Verifikasi Wajah',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isScreenFlash ? const Color(0xFF0F172A) : Colors.white,
                              ),
                            ),
                            Text(
                              'Langkah 2/2 • Selfie Presensi',
                              style: TextStyle(
                                fontSize: 11,
                                color: isScreenFlash ? const Color(0xFF64748B) : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Indikator jam
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isScreenFlash
                              ? const Color(0xFFF1F5F9)
                              : Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isScreenFlash
                                ? const Color(0xFFCBD5E1)
                                : Colors.white24,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 13,
                              color: isScreenFlash ? const Color(0xFF2563EB) : const Color(0xFF60A5FA),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _currentTime.isNotEmpty ? _currentTime.split(' ')[0] : 'Presensi',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isScreenFlash ? const Color(0xFF0F172A) : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Preview kamera
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isScreenFlash
                                  ? Colors.white
                                  : (_isFaceDetected ? const Color(0xFF2563EB) : Colors.white30),
                              width: isScreenFlash ? 4 : 2,
                            ),
                            boxShadow: [
                              if (isScreenFlash) ...[
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.95),
                                  blurRadius: 40,
                                  spreadRadius: 14,
                                ),
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.3),
                                  blurRadius: 50,
                                  spreadRadius: 4,
                                ),
                              ] else ...[
                                BoxShadow(
                                  color: _isFaceDetected
                                      ? const Color(0xFF2563EB).withOpacity(0.28)
                                      : Colors.black.withOpacity(0.35),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Stream kamera
                                if (_camReady && _cam != null)
                                  FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: _cam!.value.previewSize!.height,
                                      height: _cam!.value.previewSize!.width,
                                      child: CameraPreview(_cam!),
                                    ),
                                  )
                                else
                                  Container(
                                    color: Colors.black87,
                                    child: const Center(
                                      child: CircularProgressIndicator(color: Colors.white),
                                    ),
                                  ),

                                // Status kamera dan deteksi
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  right: 12,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Indikator lensa
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.55),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.white24),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isFront ? Icons.camera_front : Icons.camera_rear,
                                              color: Colors.white,
                                              size: 13,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              isFront ? 'KAMERA DEPAN' : 'KAMERA BELAKANG',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Indikator deteksi wajah
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: _isFaceDetected
                                              ? const Color(0xFF2563EB).withOpacity(0.92)
                                              : Colors.black.withOpacity(0.65),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: _isFaceDetected ? const Color(0xFF93C5FD) : Colors.white24,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: BoxDecoration(
                                                color: _isFaceDetected ? Colors.white : _faceStatusColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              _isFaceDetected ? 'Wajah Siap' : 'Mencari Wajah...',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Panduan posisi wajah
                                Center(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Garis oval panduan
                                      Container(
                                        width: 175,
                                        height: 235,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _isFaceDetected
                                                ? const Color(0xFF2563EB)
                                                : Colors.white.withOpacity(0.65),
                                            width: 3.2,
                                          ),
                                          borderRadius:
                                              const BorderRadius.all(Radius.elliptical(87.5, 117.5)),
                                          boxShadow: _isFaceDetected
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFF2563EB).withOpacity(0.4),
                                                    blurRadius: 18,
                                                    spreadRadius: 2,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                      ),

                                      // Animasi rotasi oval
                                      RotationTransition(
                                        turns: _spinController,
                                        child: CustomPaint(
                                          size: const Size(187, 247),
                                          painter: DashedOvalPainter(
                                            color: _isFaceDetected
                                                ? const Color(0xFF3B82F6)
                                                : Colors.white38,
                                          ),
                                        ),
                                      ),

                                      // Garis panduan mata
                                      Positioned(
                                        top: 96,
                                        child: Row(
                                          children: [
                                            Container(width: 16, height: 2, color: Colors.white30),
                                            const SizedBox(width: 65),
                                            Container(width: 16, height: 2, color: Colors.white30),
                                          ],
                                        ),
                                      ),

                                      // Status panduan wajah
                                      Positioned(
                                        bottom: -22,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _isFaceDetected
                                                ? const Color(0xFF1D4ED8).withOpacity(0.9)
                                                : Colors.black.withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: _isFaceDetected ? const Color(0xFF60A5FA) : Colors.white24,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _isFaceDetected
                                                    ? Icons.face_retouching_natural
                                                    : Icons.face_rounded,
                                                color: Colors.white,
                                                size: 13,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _isFaceDetected
                                                    ? 'Wajah Pas & Terdeteksi'
                                                    : (_isFlashOn && isFront
                                                        ? 'Screen Flash Aktif'
                                                        : 'Posisikan Wajah'),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Status lokasi outlet
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.65),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_on, color: Color(0xFF60A5FA), size: 14),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Warkop Cak Kebo • ',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 14),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Kontrol kamera
                Container(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Tombol flash
                          InkWell(
                            onTap: _toggleFlash,
                            borderRadius: BorderRadius.circular(26),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: _isFlashOn
                                    ? const Color(0xFFFEF3C7)
                                    : (isScreenFlash
                                        ? const Color(0xFFF1F5F9)
                                        : Colors.white.withOpacity(0.12)),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isFlashOn
                                      ? Colors.amber
                                      : (isScreenFlash ? const Color(0xFFCBD5E1) : Colors.white24),
                                  width: _isFlashOn ? 2 : 1,
                                ),
                                boxShadow: [
                                  if (_isFlashOn)
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.4),
                                      blurRadius: 14,
                                      spreadRadius: 2,
                                    ),
                                ],
                              ),
                              child: Icon(
                                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                                color: _isFlashOn
                                    ? Colors.amber[800]
                                    : (isScreenFlash ? const Color(0xFF475569) : Colors.white70),
                                size: 24,
                              ),
                            ),
                          ),

                          // Tombol ambil foto
                          GestureDetector(
                            onTap: _handleShutter,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 80,
                              height: 80,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: isScreenFlash
                                    ? const Color(0xFFCBD5E1)
                                    : Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isFaceDetected
                                      ? const Color(0xFF2563EB)
                                      : (_isFlashOn
                                          ? Colors.amber
                                          : (isScreenFlash ? const Color(0xFFCBD5E1) : Colors.white30)),
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _isFaceDetected
                                        ? const Color(0xFF2563EB).withOpacity(0.45)
                                        : Colors.black.withOpacity(0.2),
                                    blurRadius: _isFaceDetected ? 24 : 12,
                                    spreadRadius: _isFaceDetected ? 2 : 0,
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: _isFaceDetected
                                      ? const LinearGradient(
                                          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : LinearGradient(
                                          colors: isScreenFlash
                                              ? [const Color(0xFF94A3B8), const Color(0xFF64748B)]
                                              : [const Color(0xFF475569), const Color(0xFF334155)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  shape: BoxShape.circle,
                                ),
                                child: _sending
                                    ? const Padding(
                                        padding: EdgeInsets.all(22),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.photo_camera,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                              ),
                            ),
                          ),

                          // Tombol ganti kamera
                          InkWell(
                            onTap: _switchCamera,
                            borderRadius: BorderRadius.circular(26),
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: isScreenFlash
                                    ? const Color(0xFFF1F5F9)
                                    : Colors.white.withOpacity(0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isScreenFlash ? const Color(0xFFCBD5E1) : Colors.white24,
                                ),
                              ),
                              child: Icon(
                                Icons.flip_camera_ios,
                                color: isScreenFlash ? const Color(0xFF475569) : Colors.white70,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Petunjuk pengambilan foto
                      Text(
                        _isFaceDetected
                            ? 'Wajah terdeteksi • Tekan kamera untuk presensi'
                            : (_isFlashOn && isFront
                                ? 'Screen Flash Aktif • Posisikan wajah di oval'
                                : _faceStatusText),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: _isFaceDetected ? FontWeight.bold : FontWeight.w500,
                          color: _isFaceDetected
                              ? (isScreenFlash ? const Color(0xFF1D4ED8) : const Color(0xFF60A5FA))
                              : (isScreenFlash ? const Color(0xFF64748B) : Colors.white60),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Efek flash layar saat ambil foto
          if (_isScreenFlashActive)
            Positioned.fill(
              child: Container(
                color: Colors.white,
              ),
            ),
        ],
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
  bool shouldRepaint(covariant DashedOvalPainter oldDelegate) => oldDelegate.color != color;
}

