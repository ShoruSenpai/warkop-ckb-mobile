import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'pages/login_page.dart';
import 'pages/absensi_page.dart';
import 'pages/verifikasi_lokasi_page.dart';
import 'pages/verifikasi_wajah_page.dart';
import 'pages/absen_berhasil_page.dart';
import 'pages/profil_karyawan.dart';
import 'pages/kasir_page.dart';
import 'pages/pesanan_berhasil.dart';
import 'pages/jadwal_kerja.dart';
import 'pages/ganti_shift.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Karyawan',
      theme: ThemeData(
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0B1C30),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/verifikasi_lokasi': (context) => const VerifikasiLokasiScreen(),
        '/verifikasi_wajah': (context) => const VerifikasiWajahScreen(),
        '/absen_sukses': (context) => const AbsenSuksesScreen(),
        '/profil': (context) => const ProfilScreen(),
        '/kasir': (context) => const KasirScreen(),
        '/pesanan_berhasil': (context) => const PesananBerhasilPage(),
        '/jadwal': (context) => const JadwalScreen(),
        '/shift': (context) => const ShiftScreen(),
      },
    );
  }
}
