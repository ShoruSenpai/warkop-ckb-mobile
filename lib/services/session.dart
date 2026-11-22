import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static String token = '';
  static Map<String, dynamic> user = {};

  static bool get isLoggedIn => token.isNotEmpty;

  static String get name => (user['name'] ?? 'Karyawan').toString();
  static String get employeeCode =>
      (user['employee_code'] ?? user['code'] ?? '-').toString();
  static int get employeeId =>
      int.tryParse(user['employee_id']?.toString() ?? '') ??
      int.tryParse(user['id']?.toString() ?? '') ??
      1;
  static int get userId =>
      int.tryParse(user['id']?.toString() ?? '') ?? employeeId;
  static String get role => (user['role'] ?? 'Staf').toString();
  static String get outlet => (user['outlet'] ?? 'Cak Kebo').toString();
  static String get shift => (user['shift'] ?? '-').toString();
  static String get avatarUrl => (user['avatar_url'] ?? '').toString();
  static String workStatus = 'On Duty';

  static Future<void> setWorkStatus(String status) async {
    workStatus = status;
    final p = await SharedPreferences.getInstance();
    await p.setString('work_status', status);
  }

  // Cache data absensi hari ini dan total kehadiran
  static Map<String, dynamic>? todayAttendance;
  static String? attendanceDate;
  static int? attendanceCount;

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    token = p.getString('token') ?? '';
    workStatus = p.getString('work_status') ?? 'On Duty';
    attendanceCount = p.getInt('cached_attendance_count');
    final raw = p.getString('user');
    if (raw != null) {
      try {
        user = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {
        user = {};
      }
    }
  }

  static Future<void> setAttendanceCount(int count) async {
    attendanceCount = count;
    final p = await SharedPreferences.getInstance();
    await p.setInt('cached_attendance_count', count);
  }

  static Future<void> save(String newToken, Map<String, dynamic> newUser) async {
    token = newToken;
    user = newUser;
    final p = await SharedPreferences.getInstance();
    await p.setString('token', newToken);
    await p.setString('user', jsonEncode(newUser));
  }

  static Future<void> clear() async {
    token = '';
    user = {};
    todayAttendance = null;
    attendanceDate = null;
    attendanceCount = null;
    final p = await SharedPreferences.getInstance();
    await p.remove('token');
    await p.remove('user');
    await p.remove('cached_attendance_count');
  }
}
