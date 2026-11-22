import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import 'services/session.dart';
import 'theme/app_theme.dart';

import 'pages/main_tab_screen.dart';
import 'pages/login_page.dart';
import 'pages/verifikasi_lokasi_page.dart';
import 'pages/verifikasi_wajah_page.dart';
import 'pages/absen_berhasil_page.dart';
import 'pages/pesanan_berhasil.dart';
import 'pages/ganti_shift.dart';

// Instance Supabase
final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  await Supabase.initialize(
    url: 'https://nxoldftqeclfdalotbqx.supabase.co',
    publishableKey: 'sb_publishable_YUxWsuN-HmPzRupF8OXCsw_NVLHi3RN',
  );

  await Session.load(); // Baca session login tersimpan
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cak Kebo',
      theme: AppTheme.lightTheme,
      initialRoute: Session.isLoggedIn ? '/home' : '/login',
      routes: {
        '/': (context) => const MainTabScreen(initialTab: 0),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainTabScreen(initialTab: 0),
        '/verifikasi_lokasi': (context) => const VerifikasiLokasiScreen(),
        '/verifikasi_wajah': (context) => const VerifikasiWajahScreen(),
        '/absen_sukses': (context) => const AbsenSuksesScreen(),
        '/profil': (context) => const MainTabScreen(initialTab: 3),
        '/kasir': (context) => const MainTabScreen(initialTab: 2),
        '/pesanan_berhasil': (context) => const PesananBerhasilPage(),
        '/jadwal': (context) => const MainTabScreen(initialTab: 1),
        '/shift': (context) => const ShiftScreen(),
      },
    );
  }
}
