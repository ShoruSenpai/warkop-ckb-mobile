import 'package:flutter/material.dart';
import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../config/app_config.dart';
import '../theme/app_theme.dart';

class VerifikasiLokasiScreen extends StatefulWidget {
  const VerifikasiLokasiScreen({super.key});

  @override
  State<VerifikasiLokasiScreen> createState() => _VerifikasiLokasiScreenState();
}

class _VerifikasiLokasiScreenState extends State<VerifikasiLokasiScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final Color primary = AppColors.primary;
  final Color primaryContainer = AppColors.primaryDark;
  final Color primaryFixed = AppColors.primaryLight;
  final Color secondary = AppColors.secondary;
  final Color secondaryContainer = AppColors.primaryLight;
  final Color surface = AppColors.surface;
  final Color surfaceContainerLowest = AppColors.surfaceContainerLowest;
  final Color surfaceContainerLow = AppColors.surfaceContainerLow;
  final Color surfaceContainer = AppColors.surfaceContainer;
  final Color onSurface = AppColors.onSurface;
  final Color onSurfaceVariant = AppColors.onSurfaceVariant;
  final Color onPrimary = AppColors.surfaceContainerLowest;
  final Color onSecondaryFixedVariant = AppColors.secondaryDark;
  final Color successColor = AppColors.success;

  bool _isValidating = false;

  // Hasil cek lokasi
  double? _distance; // meter dari outlet
  double? _lat;
  double? _lng;
  double? _accuracy;
  bool _inRadius = false;
  String? _error;

  Color get _statusColor {
    if (_error != null) return const Color(0xFFDC2626);
    if (_distance == null) return secondary;
    return _inRadius ? successColor : const Color(0xFFDC2626);
  }

  String get _radiusLabel {
    if (_error != null) return 'Lokasi gagal dibaca';
    if (_distance == null) return 'Mencari lokasi...';
    final max = AppConfig.maxRadiusMeter.round();
    return _inRadius
        ? 'Dalam Radius (${_distance!.round()}m / ${max}m)'
        : 'Di Luar Radius (${_distance!.round()}m / ${max}m)';
  }

  String get _distanceLabel {
    if (_error != null) return _error!;
    if (_distance == null) return 'Mencari lokasi...';
    return _inRadius
        ? '${_distance!.round()} Meter (Aman • Diizinkan)'
        : '${_distance!.round()} Meter (Di luar radius)';
  }

  String get _coordsLabel => (_lat == null || _lng == null)
      ? '-'
      : '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}';

  String get _accuracyLabel =>
      _accuracy == null ? '-' : '± ${_accuracy!.round()} meter';

  Future<void> _checkLocation() async {
    if (!mounted) return;
    setState(() {
      _isValidating = true;
      _error = null;
    });
    try {
      final isLocEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 2), onTimeout: () => true);
      if (!isLocEnabled) {
        throw 'GPS belum aktif, nyalakan lokasi di HP';
      }
      var perm = await Geolocator.checkPermission()
          .timeout(const Duration(seconds: 2), onTimeout: () => LocationPermission.always);
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission()
            .timeout(const Duration(seconds: 4), onTimeout: () => LocationPermission.denied);
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak. Aktifkan di pengaturan aplikasi';
      }

      Position? pos;
      try {
        pos = await Geolocator.getLastKnownPosition()
            .timeout(const Duration(seconds: 2), onTimeout: () => null);
        if (pos != null && mounted) {
          final dInitial = Geolocator.distanceBetween(
            pos.latitude,
            pos.longitude,
            AppConfig.outletLat,
            AppConfig.outletLng,
          );
          setState(() {
            _lat = pos!.latitude;
            _lng = pos!.longitude;
            _accuracy = pos!.accuracy;
            _distance = dInitial;
            _inRadius = dInitial <= AppConfig.maxRadiusMeter;
          });
        }
      } catch (_) {}

      try {
        final currentPos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
          ),
        ).timeout(const Duration(seconds: 3));
        pos = currentPos;
      } catch (e) {
        debugPrint('getCurrentPosition error, gunakan lastKnownPosition: $e');
      }

      if (pos == null) {
        throw 'Gagal mendapatkan koordinat GPS. Pastikan GPS HP aktif.';
      }

      // Deteksi mock location (opsional):
      // if (pos.isMocked) throw 'Terdeteksi lokasi palsu (fake GPS)';

      final d = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        AppConfig.outletLat,
        AppConfig.outletLng,
      );
      if (!mounted) return;
      setState(() {
        _lat = pos!.latitude;
        _lng = pos!.longitude;
        _accuracy = pos!.accuracy;
        _distance = d;
        _inRadius = d <= AppConfig.maxRadiusMeter;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _inRadius = false;
        _error = e is TimeoutException ? 'Gagal membaca lokasi (timeout)' : e.toString();
      });
    } finally {
      if (mounted) setState(() => _isValidating = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLocation());
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _proceedToFaceVerification() async {
    await _checkLocation();
    if (!mounted) return;
    if (_inRadius && _lat != null && _lng != null) {
      Navigator.pushNamed(
        context,
        '/verifikasi_wajah',
        arguments: {'lat': _lat, 'lng': _lng},
      );
    } else {
      final distStr = (_distance != null)
          ? (_distance! >= 1000
              ? '${(_distance! / 1000).toStringAsFixed(1)} km'
              : '${_distance!.round()} meter')
          : 'tidak terdeteksi';

      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_off_rounded, color: Color(0xFFDC2626), size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Di Luar Radius Outlet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verifikasi presensi hanya dapat dilakukan jika perangkat Anda berada di dalam area Warkop Cak Kebo.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Jarak Terdeteksi:', style: AppTextStyles.captionBold),
                          Text(distStr, style: AppTextStyles.captionBold.copyWith(color: const Color(0xFFDC2626))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Radius Maksimal:', style: AppTextStyles.caption),
                          Text('${AppConfig.maxRadiusMeter.round()} meter', style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Mengerti', style: AppTextStyles.button.copyWith(color: Colors.white)),
                ),
              ),
            ],
          );
        },
      );
    }
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
                        Navigator.pushReplacementNamed(context, '/home');
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
                          style: AppTextStyles.overline.copyWith(
                            color: Colors.white.withOpacity(0.85),
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          'Absensi Staf',
                          style: AppTextStyles.h2.copyWith(color: Colors.white),
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
                          'GPS AKTIF',
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth > 500;
                      return Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                          child: SizedBox(
                            width: isDesktop ? 440 : double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [

                    Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
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
                    decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LANGKAH 1 DARI 2 • VALIDASI LOKASI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: onSecondaryFixedVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Verifikasi Lokasi Outlet',
              style: AppTextStyles.h1,
            ),
            const SizedBox(height: 4),
            Text(
              'Pastikan perangkat berada dalam radius operasional outlet Cak Kebo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: secondary,
              ),
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [

                  Stack(
                    alignment: Alignment.center,
                    children: [

                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primary.withOpacity(0.05),
                            border: Border.all(
                              color: primary.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: secondaryContainer.withOpacity(0.35),
                          border: Border.all(
                            color: primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),

                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary,
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),

                      Positioned(
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: _statusColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                  _inRadius
                                      ? Icons.check_circle
                                      : Icons.error_outline,
                                  color: Colors.white,
                                  size: 14),
                              const SizedBox(width: 5),
                              Text(
                                _radiusLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.store_mall_directory_outlined,
                          title: 'Outlet Terdeteksi',
                          value: 'Warkop Cak Kebo - Outlet Utama',
                        ),
                        const Divider(height: 18, thickness: 0.8),
                        _buildInfoRow(
                          icon: Icons.near_me_outlined,
                          title: 'Jarak ke Mesin Kasir',
                          value: _distanceLabel,
                          valueColor: _statusColor,
                        ),
                        const Divider(height: 18, thickness: 0.8),
                        _buildInfoRow(
                          icon: Icons.my_location_outlined,
                          title: 'Koordinat GPS',
                          value: _coordsLabel,
                        ),
                        const Divider(height: 18, thickness: 0.8),
                        _buildInfoRow(
                          icon: Icons.gps_fixed,
                          title: 'Akurasi GPS',
                          value: _accuracyLabel,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isValidating ? null : _proceedToFaceVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _inRadius ? primary : const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isValidating
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _inRadius
                                ? 'Lanjut ke Verifikasi Wajah'
                                : 'Di Luar Radius Outlet (Cek Ulang)',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _inRadius
                                ? Icons.face_retouching_natural
                                : Icons.location_off_rounded,
                            size: 20,
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
              child: Text(
                'Batal & Kembali ke Beranda',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: secondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
},
),
),
),
),
],
),
),
);
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

