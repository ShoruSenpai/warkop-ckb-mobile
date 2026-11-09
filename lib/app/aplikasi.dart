import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/warna/warna_aplikasi.dart';
import 'router/pengatur_rute.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Karyawan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0B1C30),
          ),
        ),
      ),
      initialRoute: AppRouter.initialRoute,
      routes: AppRouter.routes,
    );
  }
}
