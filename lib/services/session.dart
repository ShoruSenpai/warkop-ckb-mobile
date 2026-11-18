import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static String token = '';
  static Map<String, dynamic> user = {};

  static bool get isLoggedIn => token.isNotEmpty;

  static String get name => (user['name'] ?? 'Karyawan').toString();
  static String get employeeCode =>
      (user['employee_code'] ?? user['code'] ?? '-').toString();
  static String get role => (user['role'] ?? 'Staf').toString();
  static String get outlet => (user['outlet'] ?? 'Cak Kebo').toString();
  static String get shift => (user['shift'] ?? '-').toString();

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    token = p.getString('token') ?? '';
    final raw = p.getString('user');
    if (raw != null) {
      try {
        user = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {
        user = {};
      }
    }
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
    final p = await SharedPreferences.getInstance();
    await p.remove('token');
    await p.remove('user');
  }
}
