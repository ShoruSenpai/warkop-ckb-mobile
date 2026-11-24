import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    scaffoldBackgroundColor: AppColors.surface,
  );
}
