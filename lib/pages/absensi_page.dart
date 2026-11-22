import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import '../config/app_config.dart';
import '../services/notification_service.dart';
import '../services/session.dart';
import '../theme/app_theme.dart';
import 'main_tab_screen.dart';
import 'notifications_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _selectedIndex = 0;
  bool _isClockingIn = false;
  late Timer _timer;
  DateTime _now = DateTime.now();

  Map<String, dynamic>? _todayAttendance;
  Map<String, dynamic>? _todaySchedule;
  String? _avatarUrl = Session.avatarUrl.isNotEmpty ? Session.avatarUrl : null;
  String _employeeName = Session.name;
  int _unreadNotifCount = 0;
  DateTime? _getClockInDateTime() {
    if (_todayAttendance == null) return null;
    final raw = _todayAttendance!['clock_in']?.toString();
    if (raw == null || raw.isEmpty) return null;
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt != null) return dt;
    final parts = raw.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final s = parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0;
      return DateTime(_now.year, _now.month, _now.day, h, m, s);
    }
    return null;
  }

  Widget _buildLiveWorkStatusPill() {
    final hasClockedIn = _todayAttendance != null && _todayAttendance!['clock_in'] != null;
    final hasClockedOut = _todayAttendance != null && _todayAttendance!['clock_out'] != null;

    String pillLabel;
    IconData pillIcon;
    Color pillColor;

    if (hasClockedIn && !hasClockedOut) {
      final clockInDt = _getClockInDateTime();
      if (clockInDt != null) {
        final diff = _now.difference(clockInDt);
        final hours = diff.inHours;
        final minutes = diff.inMinutes.remainder(60);
        if (hours > 0) {
          pillLabel = 'Sedang Bekerja • ${hours}j ${minutes}m';
        } else {
          pillLabel = 'Sedang Bekerja • ${minutes} menit';
        }
      } else {
        pillLabel = 'Sedang Bertugas';
      }
      pillIcon = Icons.timer_outlined;
      pillColor = const Color(0xFF34D399); // Emerald
    } else if (hasClockedOut) {
      pillLabel = 'Shift Selesai • Sudah Pulang';
      pillIcon = Icons.check_circle_outline_rounded;
      pillColor = const Color(0xFF60A5FA); // Sky blue
    } else {
      pillLabel = 'Belum Mulai Shift';
      pillIcon = Icons.hourglass_empty_rounded;
      pillColor = const Color(0xFFFBBF24); // Warm amber
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5.5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: pillColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: pillColor.withOpacity(0.6),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            pillIcon,
            size: 13,
            color: Colors.white,
          ),
          const SizedBox(width: 5),
          Text(
            pillLabel,
            style: AppTextStyles.captionBold.copyWith(
              color: Colors.white,
              letterSpacing: 0.2,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  double? _outletDistance;
  bool _isGettingDistance = false;

  Future<void> _fetchOutletDistance({bool force = false}) async {
    if (_isGettingDistance && !force) return;
    if (mounted) {
      setState(() => _isGettingDistance = true);
    } else {
      _isGettingDistance = true;
    }
    try {
      final isLocEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 2), onTimeout: () => true);
      if (!isLocEnabled) {
        return;
      }
      var perm = await Geolocator.checkPermission()
          .timeout(const Duration(seconds: 2), onTimeout: () => LocationPermission.always);
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission()
            .timeout(const Duration(seconds: 4), onTimeout: () => LocationPermission.denied);
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        return;
      }

      // Cek posisi terakhir agar lebih cepat
      Position? lastPos;
      try {
        lastPos = await Geolocator.getLastKnownPosition()
            .timeout(const Duration(seconds: 2), onTimeout: () => null);
        if (lastPos != null && mounted) {
          final dLast = Geolocator.distanceBetween(
            lastPos.latitude,
            lastPos.longitude,
            AppConfig.outletLat,
            AppConfig.outletLng,
          );
          setState(() {
            _outletDistance = dLast;
          });
        }
      } catch (e) {
        debugPrint('getLastKnownPosition error: $e');
      }

      // Ambil posisi terbaru dengan timeout 4 detik
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
          ),
        ).timeout(const Duration(seconds: 4));
      } catch (e) {
        debugPrint('getCurrentPosition timeout/error, pakai last known jika ada: $e');
        pos = lastPos;
      }

      if (pos != null) {
        final d = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          AppConfig.outletLat,
          AppConfig.outletLng,
        );

        if (mounted) {
          setState(() {
            _outletDistance = d;
          });
        }
      }
    } catch (e) {
      debugPrint('Gagal fetch GPS distance di Home: $e');
    } finally {
      if (mounted) {
        setState(() => _isGettingDistance = false);
      } else {
        _isGettingDistance = false;
      }
    }
  }


  Future<void> _fetchTodayAttendance() async {
    try {
      final client = Supabase.instance.client;
      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);

      // Cek presensi aktif yang belum clock out
      // Mendukung shift malam lintas hari
      Map<String, dynamic>? attendanceToUse;
      try {
        final activeRes = await client
            .from('attendances')
            .select()
            .eq('employee_id', Session.employeeId)
            .isFilter('clock_out', null)
            .order('clock_in', ascending: false)
            .limit(1)
            .maybeSingle();

        if (activeRes != null && activeRes['clock_in'] != null) {
          final dtIn = DateTime.tryParse(activeRes['clock_in'].toString())?.toLocal();
          if (dtIn != null && now.difference(dtIn).inHours < 24) {
            attendanceToUse = activeRes;
          }
        }
      } catch (err) {
        debugPrint('Cek active attendance error: $err');
      }

      // Ambil presensi hari ini jika tidak ada shift aktif sebelumnya
      if (attendanceToUse == null) {
        final res = await client
            .from('attendances')
            .select()
            .eq('employee_id', Session.employeeId)
            .eq('attendance_date', todayStr)
            .order('clock_in', ascending: false)
            .limit(1)
            .maybeSingle();
        attendanceToUse = res;
      }

      Map<String, dynamic>? emp;
      try {
        emp = await client
            .from('employees')
            .select()
            .eq('id', Session.employeeId)
            .maybeSingle();
      } catch (e) {
        debugPrint('Gagal fetch profile employee: $e');
      }

      // Pakai tanggal presensi shift sebelumnya
      final targetDateStr = attendanceToUse?['attendance_date']?.toString() ?? todayStr;
      final sched = await client
          .from('employee_schedules')
          .select()
          .eq('employee_id', Session.employeeId)
          .eq('schedule_date', targetDateStr)
          .maybeSingle();

      if (attendanceToUse != null) {
        Session.todayAttendance = attendanceToUse;
        Session.attendanceDate = targetDateStr;
      }

      if (mounted) {
        setState(() {
          _todayAttendance = attendanceToUse;
          _todaySchedule = sched;
          if (emp != null) {
            if (emp['avatar_url'] != null && emp['avatar_url'].toString().isNotEmpty) {
              _avatarUrl = emp['avatar_url'];
            } else if (Session.avatarUrl.isNotEmpty) {
              _avatarUrl = Session.avatarUrl;
            }
            _employeeName = emp['full_name'] ?? _employeeName;
          }
        });
        _checkAndTriggerShiftWarningNotification(sched, attendanceToUse);
      }
    } catch (e) {
      debugPrint('Gagal fetch today attendance: $e');
    }
  }

  void _checkAndTriggerShiftWarningNotification(Map<String, dynamic>? sched, Map<String, dynamic>? attendance) async {
    if (sched == null) return;
    final hasClockedIn = attendance != null && attendance['clock_in'] != null;
    if (hasClockedIn) return;

    final rawShift = (sched['shift_name'] ?? '').toString();
    final isOff = rawShift.toLowerCase().contains('libur') || rawShift.toLowerCase().contains('off');
    if (isOff) return;

    final rawStart = (sched['start_time'] ?? '').toString();
    final rawEnd = (sched['end_time'] ?? '').toString();
    if (rawStart.isEmpty) return;

    final now = DateTime.now();
    final parts = rawStart.split(':');
    final sh = int.tryParse(parts[0]) ?? 8;
    final sm = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final shiftStart = DateTime(now.year, now.month, now.day, sh, sm);
    final shiftTolerance = shiftStart.add(const Duration(minutes: 15));

    final endParts = rawEnd.split(':');
    final eh = int.tryParse(endParts[0]) ?? 16;
    final em = endParts.length > 1 ? (int.tryParse(endParts[1]) ?? 0) : 0;
    final shiftEnd = DateTime(now.year, now.month, now.day, eh, em);

    final isExpired = now.isAfter(shiftEnd);
    final isLateNow = now.isAfter(shiftTolerance) && !isExpired;

    if (isExpired || isLateNow) {
      final lateMinutes = now.difference(shiftStart).inMinutes;
      final lateStr = lateMinutes >= 60 ? '${lateMinutes ~/ 60}j ${lateMinutes % 60}m' : '$lateMinutes mnt';
      await NotificationService.checkAndCreateShiftWarnings(
        userId: Session.userId,
        isShiftExpired: isExpired,
        isLateNow: isLateNow,
        shiftName: rawShift.isNotEmpty ? rawShift : 'Shift Harian',
        shiftStartStr: DateFormat('HH:mm').format(shiftStart),
        shiftEndStr: DateFormat('HH:mm').format(shiftEnd),
        lateStr: lateStr,
      );
      if (mounted) {
        _loadUnreadNotifCount();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(_now);
    // Pakai cache session jika sudah absen hari ini
    if (Session.attendanceDate == todayStr && Session.todayAttendance != null) {
      _todayAttendance = Session.todayAttendance;
    }
    _fetchTodayAttendance();
    _fetchOutletDistance();
    _loadUnreadNotifCount();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  final Color primary = AppColors.primary;
  final Color primaryContainer = AppColors.primaryDark;
  final Color surface = AppColors.surface;
  final Color surfaceContainerLowest = AppColors.surfaceContainerLowest;
  final Color surfaceContainerLow = AppColors.surfaceContainerLow;
  final Color surfaceContainer = AppColors.surfaceContainer;
  final Color secondaryContainer = const Color(0xFFBAE6FD);
  final Color secondary = const Color(0xFF396477);
  final Color onSurface = AppColors.onSurface;
  final Color onSurfaceVariant = AppColors.onSurfaceVariant;

  void _onItemTapped(int index) async {
    final tabScope = TabNavigationScope.of(context);
    if (tabScope != null) {
      tabScope.switchTo(index);
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) Navigator.pushNamed(context, '/jadwal');
    if (index == 2) Navigator.pushNamed(context, '/kasir');
    if (index == 3) {
      await Navigator.pushNamed(context, '/profil');
      if (mounted) _fetchTodayAttendance();
    }
  }

  void _handleClockIn({
    bool isTooEarly = false,
    bool isShiftExpired = false,
    DateTime? earliestClockIn,
    String? shiftName,
    String? shiftEndStr,
  }) async {
    if (isShiftExpired) {
      _showShiftExpiredDialog(shiftName ?? 'Shift', shiftEndStr ?? '');
      return;
    }
    if (isTooEarly && earliestClockIn != null) {
      final earliestStr = DateFormat('HH:mm').format(earliestClockIn);
      _showEarlyClockInDialog(earliestStr, shiftName ?? 'Shift');
      return;
    }
    setState(() => _isClockingIn = true);
    await Navigator.pushNamed(context, '/verifikasi_lokasi');
    if (mounted) {
      setState(() => _isClockingIn = false);
      _fetchTodayAttendance();
    }
  }

  void _showShiftExpiredDialog(String shiftName, String shiftEndStr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.block_rounded, color: Color(0xFFDC2626), size: 26),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Shift Telah Berakhir',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'Jadwal ' + shiftName + ' telah berakhir pada pukul ' + shiftEndStr + '.\n\nPresensi masuk telah ditutup dan sistem mencatat status Tidak Hadir (Alfa). Hubungi supervisor atau manajer jika terjadi kendala operasional.',
          style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF334155)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Mengerti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEarlyClockInDialog(String earliestStr, String shiftName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.schedule_rounded, color: Color(0xFFD97706), size: 26),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Presensi Belum Dibuka',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'Presensi masuk untuk $shiftName baru dibuka 60 menit sebelum shift, yaitu pukul $earliestStr WIB.\n\nSilakan kembali mendekati jadwal shift Anda.',
          style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF334155)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Mengerti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleClockOut() async {
    final now = DateTime.now();
    final nowStr = DateFormat('HH:mm').format(now);
    final rawClockIn = _todayAttendance?['clock_in'];
    final dtClockIn = rawClockIn != null ? DateTime.tryParse(rawClockIn.toString())?.toLocal() : null;
    final clockInStr = dtClockIn != null ? DateFormat('HH:mm').format(dtClockIn) : '-';
    final workDuration = dtClockIn != null ? now.difference(dtClockIn) : Duration.zero;
    final workHoursStr = '${workDuration.inHours} Jam ${workDuration.inMinutes % 60} Menit';

    final rawEnd = (_todaySchedule?['end_time'] ?? '').toString();
    DateTime shiftEnd;
    if (rawEnd.isNotEmpty && !rawEnd.startsWith('00:00')) {
      final parts = rawEnd.split(':');
      final h = int.tryParse(parts[0]) ?? 23;
      final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      final baseDate = dtClockIn ?? now;
      shiftEnd = DateTime(baseDate.year, baseDate.month, baseDate.day, h, m);
    } else {
      final baseDate = dtClockIn ?? now;
      shiftEnd = DateTime(baseDate.year, baseDate.month, baseDate.day, 23, 0);
    }
    final isEarlyLeave = now.isBefore(shiftEnd);

    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Presensi Pulang', style: AppTextStyles.h2),
                        Text('Konfirmasi akhir jam kerja hari ini', style: AppTextStyles.body),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                          Text('Jam Masuk', style: AppTextStyles.body),
                          Text('$clockInStr WIB', style: AppTextStyles.cardTitle),
                        ],
                      ),
                      const Divider(height: 16, thickness: 0.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Jam Pulang Sekarang', style: AppTextStyles.body),
                          Text('$nowStr WIB', style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary)),
                        ],
                      ),
                      const Divider(height: 16, thickness: 0.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Jam Kerja', style: AppTextStyles.body),
                          Text(workHoursStr, style: AppTextStyles.cardTitle.copyWith(color: AppColors.success)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isEarlyLeave) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Perhatian: Anda pulang sebelum shift selesai (${DateFormat('HH:mm').format(shiftEnd)} WIB).',
                            style: AppTextStyles.captionBold.copyWith(color: AppColors.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Batal', style: AppTextStyles.bodyBold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Ya, Absen Pulang', style: AppTextStyles.bodyBold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      setState(() => _isClockingIn = true);
      try {
        final client = Supabase.instance.client;
        final res = await client
            .from('attendances')
            .update({
              'clock_out': now.toUtc().toIso8601String(),
              'updated_at': now.toUtc().toIso8601String(),
            })
            .eq('id', _todayAttendance!['id'])
            .select()
            .maybeSingle();

        if (res != null) {
          Session.todayAttendance = res;
        }
        await _fetchTodayAttendance();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Text('Presensi Pulang Berhasil! Total kerja: $workHoursStr. Terima kasih!'),
            ),
          );
        }
      } catch (e) {
        debugPrint('Gagal clock out: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mencatat absen pulang: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isClockingIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final now = DateTime.now();
    final hasTodaySchedule = _todaySchedule != null;
    final rawShiftName = (_todaySchedule?['shift_name'] ?? '').toString();
    final rawStart = (_todaySchedule?['start_time'] ?? '').toString();

    final bool isOff;
    final String shiftName;
    final DateTime shiftStart;
    final DateTime shiftTolerance;
    final DateTime shiftEnd;

    final rawEnd = (_todaySchedule?['end_time'] ?? '').toString();

    if (hasTodaySchedule && rawShiftName.isNotEmpty) {
      isOff = rawShiftName.toLowerCase().contains('libur') ||
          rawShiftName.toLowerCase().contains('off') ||
          rawStart.isEmpty ||
          rawStart.startsWith('00:00');
      shiftName = rawShiftName;
      if (!isOff && rawStart.isNotEmpty && !rawStart.startsWith('00:00')) {
        final parts = rawStart.split(':');
        final h = int.tryParse(parts[0]) ?? 8;
        final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
        shiftStart = DateTime(now.year, now.month, now.day, h, m);
        shiftTolerance = shiftStart.add(const Duration(minutes: 15)); // Toleransi telat 15 menit
      } else {
        shiftStart = DateTime(now.year, now.month, now.day, 8, 0);
        shiftTolerance = DateTime(now.year, now.month, now.day, 8, 15);
      }

      if (!isOff && rawEnd.isNotEmpty && !rawEnd.startsWith('00:00')) {
        final endParts = rawEnd.split(':');
        final eh = int.tryParse(endParts[0]) ?? 16;
        final em = endParts.length > 1 ? (int.tryParse(endParts[1]) ?? 0) : 0;
        shiftEnd = DateTime(now.year, now.month, now.day, eh, em);
      } else {
        shiftEnd = DateTime(now.year, now.month, now.day, 16, 0);
      }
    } else {
      isOff = false;
      shiftName = 'Belum Ada Jadwal';
      shiftStart = DateTime(now.year, now.month, now.day, 8, 0);
      shiftTolerance = DateTime(now.year, now.month, now.day, 8, 15);
      shiftEnd = DateTime(now.year, now.month, now.day, 16, 0);
    }

    final hasClockedIn = _todayAttendance != null && _todayAttendance!['clock_in'] != null;
    final hasClockedOut = _todayAttendance != null && _todayAttendance!['clock_out'] != null;
    final rawClockIn = _todayAttendance?['clock_in'];
    final dtClockIn = rawClockIn != null ? DateTime.tryParse(rawClockIn.toString())?.toLocal() : null;
    final clockInStr = dtClockIn != null ? DateFormat('HH:mm').format(dtClockIn) : '-';

    final rawClockOut = _todayAttendance?['clock_out'];
    final dtClockOut = rawClockOut != null ? DateTime.tryParse(rawClockOut.toString())?.toLocal() : null;
    final clockOutStr = dtClockOut != null ? DateFormat('HH:mm').format(dtClockOut) : '-';

    String fmtTime(String raw) {
      if (raw.isEmpty) return '';
      final parts = raw.split(':');
      if (parts.length >= 2) return '${parts[0]}.${parts[1]}';
      return raw;
    }
    final shiftStartStr = fmtTime(rawStart).isNotEmpty ? '${fmtTime(rawStart)} WIB' : '08.00 WIB';
    final shiftEndStr = fmtTime(rawEnd).isNotEmpty ? '${fmtTime(rawEnd)} WIB' : '16.00 WIB';
    final firstName = Session.name.isNotEmpty ? Session.name.split(' ').first : 'Kawan';

    final earliestClockIn = shiftStart.subtract(const Duration(minutes: 60));
    final bool isShiftExpired = !isOff && !hasClockedIn && now.isAfter(shiftEnd);
    final bool isTooEarly = !isOff && !hasClockedIn && now.isBefore(earliestClockIn);
    final isLateNow = !isOff && !hasClockedIn && now.isAfter(shiftTolerance) && !isShiftExpired;
    final isRecordedLate = _todayAttendance?['status'] == 'late' || (dtClockIn != null && dtClockIn.isAfter(shiftTolerance));
    final lateMinutes = dtClockIn != null
        ? (dtClockIn.isAfter(shiftStart) ? dtClockIn.difference(shiftStart).inMinutes : 0)
        : (isLateNow ? now.difference(shiftStart).inMinutes : (isShiftExpired ? now.difference(shiftStart).inMinutes : 0));
    final lateStr = lateMinutes >= 60
        ? '${lateMinutes ~/ 60}j ${lateMinutes % 60}m'
        : '$lateMinutes mnt';

    // Status radius GPS dan lokasi
    final bool isLocationLoading = _isGettingDistance || _outletDistance == null;
    final bool isInsideRadius = _outletDistance != null && _outletDistance! <= AppConfig.maxRadiusMeter;
    final String distanceStr = _outletDistance == null
        ? ''
        : (_outletDistance! < 1000
            ? '${_outletDistance!.round()}m'
            : '${(_outletDistance! / 1000).toStringAsFixed(1)} km');

    final Color locBgColor;
    final Color locBorderColor;
    final Color locDotColor;
    final Color locBadgeColor;
    final String locTitle;
    final String locBadge;

    if (hasClockedIn) {
      locBgColor = const Color(0xFFF0FDF4);
      locBorderColor = const Color(0xFFBBF7D0);
      locDotColor = const Color(0xFF16A34A);
      locBadgeColor = const Color(0xFF16A34A);
      locTitle = 'Terverifikasi GPS & Wajah';
      locBadge = hasClockedOut ? 'TUNTAS' : 'TERCATAT';
    } else if (isLocationLoading) {
      locBgColor = const Color(0xFFF8FAFC);
      locBorderColor = const Color(0xFFE2E8F0);
      locDotColor = const Color(0xFF64748B);
      locBadgeColor = const Color(0xFF64748B);
      locTitle = 'Mendeteksi Lokasi GPS...';
      locBadge = 'MENGECEK';
    } else if (isInsideRadius) {
      locBgColor = const Color(0xFFF0FDF4);
      locBorderColor = const Color(0xFFBBF7D0);
      locDotColor = const Color(0xFF16A34A);
      locBadgeColor = const Color(0xFF16A34A);
      locTitle = 'Dalam Radius Outlet ($distanceStr)';
      locBadge = 'SIAP MASUK';
    } else {
      locBgColor = const Color(0xFFFEF2F2);
      locBorderColor = const Color(0xFFFECACA);
      locDotColor = const Color(0xFFEF4444);
      locBadgeColor = const Color(0xFFDC2626);
      locTitle = 'Di Luar Radius Outlet ($distanceStr)';
      locBadge = 'DI LUAR RADIUS';
    }

    return Scaffold(
      backgroundColor: surface,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _fetchTodayAttendance(),
            _fetchOutletDistance(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
          children: [

            Stack(
              clipBehavior: Clip.none,
              children: [

                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 44, 20, 64),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF2563EB),
                          Color(0xFF1E40AF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [

                        Positioned(
                          top: -70,
                          left: -55,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.07),
                            ),
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          GestureDetector(
                            onTap: () async {
                              await Navigator.pushNamed(context, '/profil');
                              if (mounted) _fetchTodayAttendance();
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.2),
                                image: DecorationImage(
                                  image: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                      ? NetworkImage(_avatarUrl!) as ImageProvider
                                      : const AssetImage('assets/images/logo_cak_kebo.png'),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, Selamat Datang!',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.88),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  _employeeName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.h1.copyWith(
                                    color: Colors.white,
                                    fontSize: 18.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${Session.role} • ${Session.outlet}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFBAE6FD).withValues(alpha: 0.92),
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                  onPressed: () => _openNotificationsSheet(),
                                ),
                              ),

                              if (_unreadNotifCount > 0)
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.primary, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                    child: Center(
                                      child: Text(
                                        _unreadNotifCount > 9 ? '9+' : '$_unreadNotifCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildLiveWorkStatusPill(),
                      const SizedBox(height: 14),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 156, left: 20, right: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withOpacity(0.12),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Stack(
                        children: [

                          Positioned(
                            right: -55,
                            bottom: -70,
                            child: Transform.rotate(
                              angle: -0.08,
                              child: Opacity(
                                opacity: 0.075,
                                child: Image.asset(
                                  'assets/images/logo_cak_kebo_transparent.png',
                                  width: 290,
                                  height: 290,
                                  color: const Color(0xFF1E3A8A),
                                  colorBlendMode: BlendMode.srcIn,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Builder(builder: (context) {
                                      final IconData statusIcon;
                                      final Color statusIconColor;
                                      final Color statusIconBg;
                                      final Color statusIconBorder;

                                      if (isOff) {
                                        statusIcon = Icons.beach_access_rounded;
                                        statusIconColor = const Color(0xFF64748B);
                                        statusIconBg = const Color(0xFFF1F5F9);
                                        statusIconBorder = const Color(0xFFE2E8F0);
                                      } else if (hasClockedIn && hasClockedOut) {
                                        statusIcon = Icons.task_alt_rounded;
                                        statusIconColor = const Color(0xFF059669);
                                        statusIconBg = const Color(0xFFD1FAE5);
                                        statusIconBorder = const Color(0xFFA7F3D0);
                                      } else if (hasClockedIn) {
                                        statusIcon = Icons.coffee_rounded;
                                        statusIconColor = const Color(0xFF16A34A);
                                        statusIconBg = const Color(0xFFDCFCE7);
                                        statusIconBorder = const Color(0xFFBBF7D0);
                                      } else if (isShiftExpired) {
                                        statusIcon = Icons.cancel_rounded;
                                        statusIconColor = const Color(0xFFDC2626);
                                        statusIconBg = const Color(0xFFFEF2F2);
                                        statusIconBorder = const Color(0xFFFECACA);
                                      } else if (isLateNow) {
                                        statusIcon = Icons.warning_amber_rounded;
                                        statusIconColor = const Color(0xFFEA580C);
                                        statusIconBg = const Color(0xFFFFF7ED);
                                        statusIconBorder = const Color(0xFFFDBA74);
                                      } else if (isTooEarly) {
                                        statusIcon = Icons.lock_clock_rounded;
                                        statusIconColor = const Color(0xFF2563EB);
                                        statusIconBg = const Color(0xFFEFF6FF);
                                        statusIconBorder = const Color(0xFFDBEAFE);
                                      } else {
                                        statusIcon = Icons.fingerprint_rounded;
                                        statusIconColor = const Color(0xFF2563EB);
                                        statusIconBg = const Color(0xFFEFF6FF);
                                        statusIconBorder = const Color(0xFFDBEAFE);
                                      }

                                      return Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: statusIconBg,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: statusIconBorder),
                                          boxShadow: [
                                            BoxShadow(
                                              color: statusIconColor.withValues(alpha: 0.12),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          statusIcon,
                                          color: statusIconColor,
                                          size: 26,
                                        ),
                                      );
                                    }),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'STATUS PRESENSI',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.secondary,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            isOff
                                                ? 'Hari Ini Libur (Day Off)'
                                                : (hasClockedIn
                                                    ? (hasClockedOut ? 'Presensi Selesai' : 'Sedang Bertugas')
                                                    : (isShiftExpired
                                                        ? 'Shift Telah Berakhir (Alfa)'
                                                        : (isLateNow ? 'Belum Absen (Terlambat)' : 'Belum Absen Masuk'))),
                                            style: AppTextStyles.h2.copyWith(
                                              color: isOff
                                                  ? const Color(0xFF64748B)
                                                  : (hasClockedIn
                                                      ? (hasClockedOut ? AppColors.success : AppColors.primary)
                                                      : (isShiftExpired || isLateNow ? AppColors.error : AppColors.onSurface)),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${Session.name} • ${Session.role}',
                                            style: AppTextStyles.body,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isShiftExpired
                                        ? const Color(0xFFFEF2F2)
                                        : (isLateNow ? const Color(0xFFFFF7ED) : const Color(0xFFF8FAFC)),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isShiftExpired
                                          ? const Color(0xFFFECACA)
                                          : (isLateNow ? const Color(0xFFFDBA74) : const Color(0xFFE2E8F0)),
                                      width: (isShiftExpired || isLateNow) ? 1.2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.schedule_rounded,
                                                  size: 16,
                                                  color: isLateNow ? const Color(0xFFEA580C) : AppColors.primary,
                                                ),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    shiftName,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: AppTextStyles.cardTitle,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isOff
                                                  ? const Color(0xFF94A3B8)
                                                  : (isLateNow ? const Color(0xFFDC2626) : AppColors.primary),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              isOff
                                                  ? 'Libur'
                                                  : (isLateNow ? 'Telat $lateStr' : 'Wajib'),
                                              style: const TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                hasClockedIn
                                                    ? Icons.check_circle_outline_rounded
                                                    : (isLateNow ? Icons.warning_amber_rounded : Icons.hourglass_empty_rounded),
                                                size: 14,
                                                color: hasClockedIn
                                                    ? const Color(0xFF16A34A)
                                                    : (isLateNow ? const Color(0xFFDC2626) : AppColors.primary),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                hasClockedIn
                                                    ? (hasClockedOut ? 'Masuk:  • Pulang: ' : 'Masuk:  WIB')
                                                    : (isOff
                                                        ? 'Libur • Jam Fleksibel'
                                                        : (isShiftExpired
                                                            ? 'Shift Berakhir (Alfa)'
                                                            : (isLateNow
                                                                ? 'Terlambat '
                                                                : (isTooEarly
                                                                    ? 'Dibuka  WIB'
                                                                    : (now.isAfter(shiftStart)
                                                                        ? 'Toleransi 15 Mnt: Sisa m'
                                                                        : ' Menit lagi'))))),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: hasClockedIn
                                                      ? AppColors.success
                                                      : (isShiftExpired || isLateNow ? const Color(0xFFDC2626) : AppColors.onSurface),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              hasClockedIn
                                                  ? (isRecordedLate ? 'Terlambat ($lateStr)' : 'Tepat Waktu')
                                                  : (isOff
                                                      ? 'Tidak Wajib Absen'
                                                      : (isShiftExpired
                                                          ? 'Batas: $shiftEndStr'
                                                          : (isTooEarly
                                                              ? 'Buka: ${DateFormat("HH:mm").format(earliestClockIn)}'
                                                              : (isLateNow
                                                                  ? 'Batas: ${DateFormat("HH:mm").format(shiftTolerance)} (Lewat)'
                                                                  : 'Toleransi: s/d ${DateFormat("HH:mm").format(shiftTolerance)}')))),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: hasClockedIn
                                                    ? (isRecordedLate ? const Color(0xFFDC2626) : AppColors.success)
                                                    : (isShiftExpired || isLateNow ? const Color(0xFFDC2626) : AppColors.secondary),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (isShiftExpired) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFFECACA)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.block_rounded, size: 16, color: Color(0xFFDC2626)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                shiftName + ' telah berakhir pada ' + shiftEndStr + '. Presensi masuk telah ditutup (Alfa). Hubungi supervisor jika perlu penyesuaian.',
                                                style: AppTextStyles.captionBold.copyWith(color: AppColors.error),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ] else if (isLateNow) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF7ED),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFFED7AA)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFEA580C)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Shift dimulai $shiftStartStr (lewat $lateStr). Presensi masuk akan otomatis dicatat Terlambat.',
                                                style: AppTextStyles.captionBold.copyWith(color: const Color(0xFFC2410C)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                const SizedBox(height: 12),

                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: locBgColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: locBorderColor),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: locDotColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                locTitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        locBadge,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: locBadgeColor,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                        if (hasClockedIn && hasClockedOut) ...[
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF16A34A).withOpacity(0.30),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text('Presensi Selesai ($clockInStr - $clockOutStr WIB)', style: AppTextStyles.button),
                              ],
                            ),
                          ),
                        ] else if (hasClockedIn && !hasClockedOut) ...[
                          Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFBBF7D0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 16),
                                    const SizedBox(width: 6),
                                    Text('Presensi Masuk Tercatat ($clockInStr WIB)', style: AppTextStyles.bodyBold.copyWith(color: AppColors.success)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFDC2626).withOpacity(0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isClockingIn ? null : _handleClockOut,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: _isClockingIn
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                                            const SizedBox(width: 8),
                                            Text('Absen Pulang Sekarang', style: AppTextStyles.button),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isShiftExpired
                                    ? const [Color(0xFF94A3B8), Color(0xFF64748B)]
                                    : (isTooEarly
                                        ? const [Color(0xFF94A3B8), Color(0xFF64748B)]
                                        : (isLateNow
                                            ? const [Color(0xFFEA580C), Color(0xFFC2410C)]
                                            : const [Color(0xFF2563EB), Color(0xFF1D4ED8)])),
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: (isShiftExpired || isTooEarly
                                          ? const Color(0xFF64748B)
                                          : (isLateNow ? const Color(0xFFEA580C) : AppColors.primary))
                                      .withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isClockingIn
                                  ? null
                                  : () => _handleClockIn(
                                        isTooEarly: isTooEarly,
                                        isShiftExpired: isShiftExpired,
                                        earliestClockIn: earliestClockIn,
                                        shiftName: shiftName,
                                        shiftEndStr: shiftEndStr,
                                      ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isClockingIn
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isShiftExpired
                                              ? Icons.lock_clock_rounded
                                              : (isTooEarly
                                                  ? Icons.lock_clock_rounded
                                                  : (isLateNow ? Icons.warning_amber_rounded : Icons.login_rounded)),
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isOff
                                              ? 'Absen Hari Libur (Opsional)'
                                              : (isShiftExpired
                                                  ? 'Shift Telah Berakhir (Ditutup)'
                                                  : (isTooEarly
                                                      ? 'Presensi Dibuka ${DateFormat("HH:mm").format(earliestClockIn)} WIB'
                                                      : (isLateNow ? 'Absen Masuk (Terlambat)' : 'Absen Masuk Sekarang'))),
                                          style: AppTextStyles.button,
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          (isShiftExpired || isTooEarly) ? Icons.info_outline_rounded : Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'MENU CEPAT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                const double leftPadding = 20.0;
                const double gap = 12.0;
                const double peekWidth = 32.0;

                double cardWidth = (availableWidth - leftPadding - (3 * gap) - peekWidth) / 3;
                if (availableWidth < 360) {
                  cardWidth = (availableWidth - leftPadding - (2 * gap) - peekWidth) / 2;
                }
                cardWidth = cardWidth.clamp(90.0, 136.0);

                return SizedBox(
                  height: 124,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    clipBehavior: Clip.none,
                    children: [
                      _buildHugeCard(
                        context: context,
                        width: cardWidth,
                        title: 'Jadwal',
                        subtitle: 'Shift kerja',
                        icon: Icons.calendar_month_rounded,
                        iconColor: AppColors.primary,
                        route: '/jadwal',
                      ),
                      const SizedBox(width: gap),
                      _buildHugeCard(
                        context: context,
                        width: cardWidth,
                        title: 'Ganti Shift',
                        subtitle: 'Tukar rekan',
                        icon: Icons.swap_horiz_rounded,
                        iconColor: AppColors.primary,
                        route: '/shift',
                      ),
                      const SizedBox(width: gap),
                      _buildHugeCard(
                        context: context,
                        width: cardWidth,
                        title: 'Kasir POS',
                        subtitle: 'Order & bayar',
                        icon: Icons.point_of_sale_rounded,
                        iconColor: AppColors.primary,
                        route: '/kasir',
                      ),
                      const SizedBox(width: gap),
                      _buildHugeCard(
                        context: context,
                        width: cardWidth,
                        title: 'Profil',
                        subtitle: 'Data staf',
                        icon: Icons.badge_outlined,
                        iconColor: AppColors.primary,
                        route: '/profil',
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LiveRadarPulseCard(
                    outletDistance: _outletDistance,
                    isGettingDistance: _isGettingDistance,
                    onRefreshGps: () async {
                      await _fetchOutletDistance(force: true);
                    },
                    onOpenMaps: () async {
                      final navUri = Uri.parse(
                        'google.navigation:q=${AppConfig.outletLat},${AppConfig.outletLng}&mode=d',
                      );
                      try {
                        if (await canLaunchUrl(navUri)) {
                          await launchUrl(navUri, mode: LaunchMode.externalApplication);
                          return;
                        }
                      } catch (e) {
                        debugPrint('Native navigation intent error: $e');
                      }

                      final dirUri = Uri.parse(AppConfig.outletMapsUrl);
                      try {
                        if (await canLaunchUrl(dirUri)) {
                          await launchUrl(dirUri, mode: LaunchMode.externalApplication);
                          return;
                        }
                      } catch (e) {
                        debugPrint('Directions URL error: $e');
                      }

                      try {
                        await launchUrl(dirUri, mode: LaunchMode.externalApplication);
                      } catch (e) {
                        debugPrint('Fallback launch error: $e');
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildSmartStatusCard(
                    isOff: isOff,
                    hasClockedIn: hasClockedIn,
                    hasClockedOut: hasClockedOut,
                    isLateNow: isLateNow,
                    hasTodaySchedule: hasTodaySchedule,
                    shiftName: shiftName,
                    shiftStartStr: shiftStartStr,
                    shiftEndStr: shiftEndStr,
                    clockInStr: clockInStr,
                    clockOutStr: clockOutStr,
                    firstName: firstName,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    ),

      bottomNavigationBar: TabNavigationScope.of(context) != null
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: primary,
              unselectedItemColor: AppColors.secondary,
              selectedLabelStyle: AppTextStyles.captionBold,
              unselectedLabelStyle: AppTextStyles.captionBold,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.timer),
                  label: 'Absensi',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Jadwal',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.point_of_sale),
                  label: 'POS',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.badge),
                  label: 'Profil',
                ),
              ],
            ),
    );
  }


Widget _buildHugeCard({
    required BuildContext context,
    required double width,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String route,
  }) {
    return Container(
      width: width,
      height: 124,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              final tabScope = TabNavigationScope.of(context);
              if (tabScope != null) {
                if (route == '/home') {
                  tabScope.switchTo(0);
                  return;
                }
                if (route == '/jadwal') {
                  tabScope.switchTo(1);
                  return;
                }
                if (route == '/kasir') {
                  tabScope.switchTo(2);
                  return;
                }
                if (route == '/profil') {
                  tabScope.switchTo(3);
                  return;
                }
              }
              Navigator.pushNamed(context, route);
            },
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  right: -12,
                  bottom: -12,
                  child: Opacity(
                    opacity: 0.12,
                    child: Icon(
                      icon,
                      size: 78,
                      color: iconColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(icon, color: iconColor, size: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.cardTitle,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _loadUnreadNotifCount() async {
    try {
      final count = await NotificationService.getUnreadCount(Session.userId);
      if (mounted) setState(() => _unreadNotifCount = count);
    } catch (_) {}
  }

  void _openNotificationsSheet() {
    NotificationsBottomSheet.show(
      context,
      onChanged: () {
        _loadUnreadNotifCount();
      },
    ).then((_) {
      _loadUnreadNotifCount();
    });
  }

  Widget _buildSmartStatusCard({
    required bool isOff,
    required bool hasClockedIn,
    required bool hasClockedOut,
    required bool isLateNow,
    required bool hasTodaySchedule,
    required String shiftName,
    required String shiftStartStr,
    required String shiftEndStr,
    required String clockInStr,
    required String clockOutStr,
    required String firstName,
  }) {
    final Color bgColor;
    final Color borderColor;
    final Color iconColor;
    final Color iconBgColor;
    final Color badgeBg;
    final Color badgeTextColor;
    final IconData iconData;
    final String badgeLabel;
    final String cardTitle;
    final String cardBody;

    if (isOff) {
      bgColor = const Color(0xFFFFFBEB);
      borderColor = const Color(0xFFFDE68A);
      iconColor = const Color(0xFFD97706);
      iconBgColor = const Color(0xFFFEF3C7);
      badgeBg = const Color(0xFFFEF3C7);
      badgeTextColor = const Color(0xFFB45309);
      iconData = Icons.spa_rounded;
      badgeLabel = 'Day Off';
      cardTitle = 'Waktunya Istirahat & Recharge';
      cardBody = 'Hari ini Anda tidak memiliki jadwal kerja. Selamat menikmati waktu luang bersama keluarga!';
    } else if (hasClockedIn && hasClockedOut) {
      bgColor = const Color(0xFFF0FDF4);
      borderColor = const Color(0xFFBBF7D0);
      iconColor = const Color(0xFF16A34A);
      iconBgColor = const Color(0xFFDCFCE7);
      badgeBg = const Color(0xFFDCFCE7);
      badgeTextColor = AppColors.success;
      iconData = Icons.task_alt_rounded;
      badgeLabel = 'Tuntas Hari Ini';
      cardTitle = 'Kerja Bagus Hari Ini, $firstName!';
      cardBody = 'Presensi kerja hari ini telah selesai ($clockInStr - $clockOutStr WIB). Terima kasih atas dedikasi dan kerja kerasnya, hati-hati di jalan pulang!';
    } else if (hasClockedIn && !hasClockedOut) {
      bgColor = const Color(0xFFEFF6FF);
      borderColor = const Color(0xFFBFDBFE);
      iconColor = AppColors.primary;
      iconBgColor = const Color(0xFFDBEAFE);
      badgeBg = const Color(0xFFDBEAFE);
      badgeTextColor = const Color(0xFF1D4ED8);
      iconData = Icons.work_history_rounded;
      badgeLabel = 'Shift Aktif';
      cardTitle = 'Shift Sedang Berjalan';
      cardBody = 'Masuk pukul $clockInStr WIB. Jam pulang dijadwalkan pukul $shiftEndStr. Jangan lupa lakukan presensi pulang saat shift Anda berakhir!';
    } else if (!hasTodaySchedule) {
      bgColor = const Color(0xFFF8FAFC);
      borderColor = const Color(0xFFE2E8F0);
      iconColor = AppColors.secondary;
      iconBgColor = const Color(0xFFF1F5F9);
      badgeBg = const Color(0xFFF1F5F9);
      badgeTextColor = AppColors.onSurfaceVariant;
      iconData = Icons.event_busy_rounded;
      badgeLabel = 'Belum Ada Jadwal';
      cardTitle = 'Menunggu Jadwal dari SPV';
      cardBody = 'Jadwal shift untuk hari ini belum ditentukan oleh supervisor / admin. Hubungi SPV outlet Cak Kebo bila Anda dijadwalkan masuk.';
    } else if (isLateNow) {
      bgColor = const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFFECACA);
      iconColor = const Color(0xFFDC2626);
      iconBgColor = const Color(0xFFFEE2E2);
      badgeBg = const Color(0xFFFEE2E2);
      badgeTextColor = const Color(0xFFB91C1C);
      iconData = Icons.warning_amber_rounded;
      badgeLabel = 'Terlambat Masuk';
      cardTitle = 'Pengingat: Waktu Shift Telah Lewat';
      cardBody = '$shiftName dijadwalkan pukul $shiftStartStr (batas toleransi 15 menit). Segera merapat ke outlet dan lakukan presensi masuk!';
    } else {
      bgColor = const Color(0xFFF8FAFC);
      borderColor = const Color(0xFFE2E8F0);
      iconColor = AppColors.primary;
      iconBgColor = const Color(0xFFEFF6FF);
      badgeBg = const Color(0xFFEFF6FF);
      badgeTextColor = const Color(0xFF1D4ED8);
      iconData = Icons.near_me_rounded;
      badgeLabel = 'Siap Shift';
      cardTitle = 'Pengingat Shift: $shiftName';
      cardBody = 'Shift Anda dijadwalkan mulai pukul $shiftStartStr. Pastikan GPS aktif dan tetap berada dalam radius 50m outlet Cak Kebo untuk verifikasi masuk.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(cardTitle, style: AppTextStyles.cardTitle),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(badgeLabel, style: AppTextStyles.badge.copyWith(color: badgeTextColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(cardBody, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _LiveRadarPulseCard extends StatefulWidget {
  final double? outletDistance;
  final bool isGettingDistance;
  final VoidCallback onRefreshGps;
  final VoidCallback onOpenMaps;

  const _LiveRadarPulseCard({
    required this.outletDistance,
    required this.isGettingDistance,
    required this.onRefreshGps,
    required this.onOpenMaps,
  });

  @override
  State<_LiveRadarPulseCard> createState() => _LiveRadarPulseCardState();
}

class _LiveRadarPulseCardState extends State<_LiveRadarPulseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isInsideRadius = widget.outletDistance != null &&
        widget.outletDistance! <= AppConfig.maxRadiusMeter;
    final Color radarColor =
        isInsideRadius ? AppColors.success : AppColors.warning;
    final IconData radarIcon =
        isInsideRadius ? Icons.check_circle_rounded : Icons.radar_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isInsideRadius
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tampilan radar lokasi
          Row(
            children: [
              // Lingkaran animasi radar
              SizedBox(
                width: 52,
                height: 52,
                child: AnimatedBuilder(
                  animation: _radarController,
                  builder: (context, child) {
                    final double scale = 1.0 + (_radarController.value * 0.35);
                    final double opacity =
                        (1.0 - _radarController.value).clamp(0.0, 1.0) * 0.45;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 50 * scale,
                          height: 50 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: radarColor.withValues(alpha: opacity),
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: radarColor.withValues(alpha: 0.15),
                          ),
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: radarColor,
                            boxShadow: [
                              BoxShadow(
                                color: radarColor.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(radarIcon, color: Colors.white, size: 18),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),

              // Keterangan status lokasi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppConfig.outletName, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 3),
                    Text(
                      widget.outletDistance == null
                          ? 'Mendeteksi sinyal GPS...'
                          : (isInsideRadius
                              ? '${widget.outletDistance!.round()}m dari titik absen'
                              : '${(widget.outletDistance! / 1000).toStringAsFixed(1)} km dari titik absen'),
                      style: AppTextStyles.bodyBold.copyWith(color: radarColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isInsideRadius
                          ? 'Lokasi terverifikasi • Siap Presensi'
                          : 'Maksimal radius presensi ${AppConfig.maxRadiusMeter.round()} meter',
                      style: isInsideRadius
                          ? AppTextStyles.captionBold.copyWith(color: AppColors.success)
                          : AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Garis pemisah
          Divider(height: 1, thickness: 1, color: AppColors.borderLight),
          const SizedBox(height: 12),

          // Tombol aksi
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: widget.isGettingDistance ? null : widget.onRefreshGps,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        widget.isGettingDistance
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : const Icon(
                                Icons.refresh_rounded,
                                size: 16,
                                color: AppColors.secondary,
                              ),
                        const SizedBox(width: 6),
                        Text(
                          widget.isGettingDistance ? 'Mencari...' : 'Refresh GPS',
                          style: AppTextStyles.subtitle.copyWith(color: AppColors.onSurface),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: widget.onOpenMaps,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.near_me_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Buka Rute',
                          style: AppTextStyles.button,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
