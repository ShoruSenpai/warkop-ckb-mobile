import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/session.dart';
import '../theme/app_theme.dart';

class AbsenSuksesScreen extends StatelessWidget {
  const AbsenSuksesScreen({super.key});

  static const Color primary = AppColors.primary;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color secondary = AppColors.onSurfaceVariant;
  static const Color secondaryContainer = AppColors.surfaceContainerLow;
  static const Color surface = AppColors.surface;
  static const Color surfaceContainerLowest = AppColors.surfaceContainerLowest;
  static const Color surfaceContainerLow = AppColors.surfaceContainerLow;
  static const Color onSurface = AppColors.onSurface;
  static const Color onSurfaceVariant = AppColors.onSurfaceVariant;
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    // Jam absensi dari parameter, fallback jam sekarang
    final args = (ModalRoute.of(context)?.settings.arguments as Map?)
            ?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final rawChecked = args['checked_in_at'];
    DateTime now;
    if (rawChecked != null) {
      final dt = DateTime.tryParse(rawChecked.toString());
      now = dt != null ? (dt.isUtc ? dt.toLocal() : dt) : DateTime.now();
    } else {
      now = DateTime.now();
    }

    final timeString = DateFormat('HH:mm').format(now);
    final dateString = DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(now);
    final record = args['record'] as Map?;
    final bool isLate = args['is_late'] == true || (record != null && record['status'] == 'late');
    final int lateMinutes = (args['late_minutes'] as num?)?.toInt() ?? 0;
    final attendanceId = record != null && record['id'] != null
        ? record['id'].toString().padLeft(4, '0')
        : '0001';
    final refCode = 'CK-ABS-${DateFormat('yyyyMMdd').format(now)}-$attendanceId';

    return Scaffold(
      backgroundColor: primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 12, 16, 18),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/home'));
                    },
                  ),
                  Container(
                    width: 44,
                    height: 44,
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
                          'Presensi Sukses',
                          style: AppTextStyles.h2.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          'Tercatat',
                          style: AppTextStyles.captionBold.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Konten sukses presensi
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Center(
                      child: SizedBox(
                        width: 440,
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: primaryLight.withOpacity(0.5),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: primary.withOpacity(0.12),
                                    blurRadius: 25,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 32),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Absen Berhasil Dicatat',
                              style: AppTextStyles.h1,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Data presensi Anda telah terverifikasi GPS & Wajah dan tersimpan di sistem.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body,
                            ),
                            const SizedBox(height: 24),

                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'WAKTU ABSEN',
                                              style: AppTextStyles.overline,
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.baseline,
                                              textBaseline: TextBaseline.alphabetic,
                                              children: [
                                                Text(
                                                  timeString,
                                                  style: AppTextStyles.h1.copyWith(color: primary),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'WIB',
                                                  style: AppTextStyles.captionBold,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isLate
                                                ? const Color(0xFFFEF3C7)
                                                : const Color(0xFF10B981).withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(20),
                                            border: isLate
                                                ? Border.all(color: const Color(0xFFFDE68A), width: 1)
                                                : null,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                isLate ? Icons.warning_amber_rounded : Icons.check_circle,
                                                size: 15,
                                                color: isLate ? const Color(0xFFB45309) : const Color(0xFF059669),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                isLate
                                                    ? 'Terlambat ${lateMinutes > 0 ? '($lateMinutes mnt)' : ''}'
                                                    : 'Tepat Waktu',
                                                style: AppTextStyles.badge.copyWith(color: isLate ? const Color(0xFFB45309) : const Color(0xFF059669)),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                size: 18, color: secondary),
                                            const SizedBox(width: 8),
                                            Text('Tanggal',
                                                style: AppTextStyles.body),
                                          ],
                                        ),
                                        Text(
                                          dateString,
                                          style: AppTextStyles.bodyBold,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.badge_outlined,
                                                size: 18, color: secondary),
                                            const SizedBox(width: 8),
                                            Text('Karyawan',
                                                style: AppTextStyles.body),
                                          ],
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                Session.name.isNotEmpty ? Session.name : 'Karyawan',
                                                style: AppTextStyles.bodyBold,
                                                textAlign: TextAlign.end,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${Session.role.isNotEmpty ? Session.role : 'Staff'} • ${Session.shift.isNotEmpty ? Session.shift : 'Pagi'}',
                                                style: AppTextStyles.caption,
                                                textAlign: TextAlign.end,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.store_outlined,
                                                size: 18, color: secondary),
                                            const SizedBox(width: 8),
                                            Text('Lokasi Outlet',
                                                style: AppTextStyles.body),
                                          ],
                                        ),
                                        Text(
                                          'Warkop Cak Kebo',
                                          style: AppTextStyles.bodyBold,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'METODE VALIDASI',
                                          style: AppTextStyles.overline,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.pin_drop,
                                                    size: 16, color: primary),
                                                const SizedBox(width: 8),
                                                Text('GPS Geofence',
                                                    style: AppTextStyles.body),
                                              ],
                                            ),
                                            Text(
                                              'Akurat (< 100m)',
                                              style: AppTextStyles.bodyBold.copyWith(color: primary),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.face,
                                                    size: 16, color: primary),
                                                const SizedBox(width: 8),
                                                Text('Biometrik Wajah',
                                                    style: AppTextStyles.body),
                                              ],
                                            ),
                                            Text(
                                              'Terverifikasi Kamera',
                                              style: AppTextStyles.bodyBold.copyWith(color: primary),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            ElevatedButton(
                              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                                  context, '/home', (route) => false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: onPrimary,
                                elevation: 0,
                                minimumSize: const Size(double.infinity, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Kembali ke Beranda',
                                    style: AppTextStyles.button,
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.verified_user_outlined,
                                    size: 14, color: secondary),
                                const SizedBox(width: 6),
                                RichText(
                                  text: TextSpan(
                                    text: 'ID Presensi: ',
                                    style: AppTextStyles.caption,
                                    children: [
                                      TextSpan(
                                        text: refCode,
                                        style: AppTextStyles.captionBold.copyWith(color: onSurface),
                                      ),
                                      const TextSpan(text: ' • Tersinkron'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
