import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../services/session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;

  final TextEditingController _idController =
      TextEditingController(text: 'cici@gmail.com');
  final TextEditingController _passController =
      TextEditingController(text: 'admin123');
  bool _loading = false;

  @override
  void dispose() {
    _idController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _login() async {
    final id = _idController.text.trim();
    final pass = _passController.text;
    if (id.isEmpty || pass.isEmpty) {
      _toast('ID karyawan/email dan kata sandi wajib diisi');
      return;
    }
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      // 1. Cari user di database Supabase berdasarkan email atau username
      final user = await supabase
          .from('users')
          .select()
          .or('email.eq.$id,username.eq.$id')
          .maybeSingle();

      if (user != null) {
        final dbPassword = (user['password'] ?? '').toString();
        bool isPasswordValid = false;

        if (dbPassword == pass) {
          isPasswordValid = true;
        } else if (dbPassword.startsWith(r'$2y$') ||
            dbPassword.startsWith(r'$2a$') ||
            dbPassword.startsWith(r'$2b$')) {
          try {
            final normalized = dbPassword.startsWith(r'$2y$')
                ? dbPassword.replaceFirst(r'$2y$', r'$2a$')
                : dbPassword;
            isPasswordValid = BCrypt.checkpw(pass, normalized);
          } catch (_) {
            isPasswordValid = false;
          }
        }

        if (!isPasswordValid) {
          _toast('Kata sandi salah');
          return;
        }

        // 2. Ambil profil karyawan dari tabel employees jika ada
        final emp = await supabase
            .from('employees')
            .select()
            .eq('user_id', user['id'])
            .maybeSingle();

        await Session.save(user['id'].toString(), {
          'name': emp?['full_name'] ?? user['username'] ?? 'Karyawan',
          'role': emp?['position'] ?? user['role'] ?? 'Staf',
          'outlet': 'Cak Kebo Senopati',
          'shift': 'Shift Pagi',
          'employee_code': emp?['employee_code'] ?? 'CK-${user['id']}',
        });

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _toast('Email atau username tidak ditemukan di database Supabase');
      }
    } catch (e) {
      _toast('Gagal koneksi Supabase: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  final Color primaryColor = const Color(0xFF2563EB);
  final Color primaryDark = const Color(0xFF1D4ED8);
  final Color primaryLight = const Color(0xFFDBEAFE);
  final Color surfaceColor = const Color(0xFFF4F6FB);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  final Color surfaceContainerLow = const Color(0xFFEFF6FF);
  final Color onSurface = const Color(0xFF0F172A);
  final Color onSurfaceVariant = const Color(0xFF475569);
  final Color outlineColor = const Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: outlineColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.28),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Image.asset(
                              'assets/images/logo_cak_kebo_transparent.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'CAK KEBO',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Selamat Datang',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Masuk untuk mengakses portal staf & presensi',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'ID KARYAWAN / EMAIL',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _idController,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'contoh: alisa@cakkebo.id atau CK-88',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: onSurfaceVariant.withOpacity(0.6),
                          ),
                          prefixIcon: Icon(
                            Icons.badge_outlined,
                            color: primaryColor,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: outlineColor, width: 0.8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: primaryColor, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'KATA SANDI',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        obscureText: !_isPasswordVisible,
                        controller: _passController,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Masukkan kata sandi akun',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: onSurfaceVariant.withOpacity(0.6),
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: primaryColor,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: outlineColor, width: 0.8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: primaryColor, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Lupa Kata Sandi?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _loading ? 'Memproses...' : 'Masuk ke Sistem',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.gpp_good_outlined,
                              color: primaryColor, size: 17),
                          const SizedBox(width: 6),
                          Text(
                            'ENKRIPSI DATA AMAN TERPROTEKSI',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Butuh bantuan masuk? ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: onSurfaceVariant,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Hubungi Manager Outlet',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Cak Kebo Staff Portal v2.4.0',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}