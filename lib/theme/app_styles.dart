import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Custom style
  static TextStyle poppins({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    List<Shadow>? shadows,
  }) =>
      GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
        decorationColor: decorationColor,
        shadows: shadows,
      );

  static TextStyle plusJakartaSans({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    List<Shadow>? shadows,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
        decorationColor: decorationColor,
        shadows: shadows,
      );

  // Monospace
  static TextStyle mono({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) =>
      GoogleFonts.firaCode(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
      );

  // Heading
  static TextStyle get h1 => poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
        letterSpacing: -0.3,
      );

  static TextStyle get h2 => poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      );

  static TextStyle get h3 => poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      );

  static TextStyle get h4 => poppins(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      );

  static TextStyle get cardTitle => poppins(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      );

  // Body dan subtitle
  static TextStyle get bodyLarge => plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyLargeBold => plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      );

  static TextStyle get body => plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceVariant,
        height: 1.45,
      );

  static TextStyle get bodyBold => plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      );

  static TextStyle get subtitle => plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.secondary,
      );

  static TextStyle get caption => plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.secondary,
      );

  static TextStyle get captionBold => plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.secondary,
      );

  static TextStyle get badge => plusJakartaSans(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get button => plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.surfaceContainerLowest,
      );

  static TextStyle get overline => plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: AppColors.secondary,
      );

  static TextStyle get priceLarge => poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  static TextStyle get priceMedium => poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );
}

/// container dan kartu
class AppDecorations {
  /// Kartu putih
  static BoxDecoration card({
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
  }) =>
      BoxDecoration(
        color: color ?? AppColors.surfaceContainerLowest,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        border: border ?? Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  /// Kartu biru
  static BoxDecoration elevatedCard({
    Color? color,
    BorderRadius? borderRadius,
  }) =>
      BoxDecoration(
        color: color ?? AppColors.surfaceContainerLowest,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );

  /// Kontainer abu-abu
  static BoxDecoration softBox({
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
  }) =>
      BoxDecoration(
        color: color ?? AppColors.surfaceContainerLow,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: border,
      );

  /// Tile untuk item daftar
  static BoxDecoration tile({
    Color? color,
    BorderRadius? borderRadius,
  }) =>
      BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      );

  /// Pill status
  static BoxDecoration statusPill({
    required Color bgColor,
    Color? borderColor,
  }) =>
      BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      );
}
