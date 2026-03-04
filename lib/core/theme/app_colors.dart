import 'package:flutter/material.dart';

/// Design system colors extracted from Stitch UI.
/// Mobile primary: #1e398a | Web primary: #3b1e8a
class AppColors {
  AppColors._();

  // ── Primary Palette ──
  static const Color primaryMobile = Color(0xFF1E398A);
  static const Color primaryWeb = Color(0xFF3B1E8A);

  // ── Accent Colors ──
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentBlue = Color(0xFF1E3A8A);
  static const Color accentOrange = Color(0xFFF97316);

  // ── Background ──
  static const Color backgroundLight = Color(0xFFF6F6F8);
  static const Color backgroundLightWeb = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF121620);
  static const Color backgroundDarkWeb = Color(0xFF161220);
  static const Color navyDark = Color(0xFF0F172A);

  // ── Surface ──
  static const Color surfaceWhite = Colors.white;
  static const Color surfaceDark = Color(0xFF1E293B);

  // ── Semantic ──
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);

  // ── Glass Effect ──
  static const Color glassWhite = Color(0xB3FFFFFF); // rgba(255,255,255,0.7)
  static const Color glassBorder = Color(0x4DFFFFFF); // rgba(255,255,255,0.3)
  static const Color glassDark = Color(0xB3161220); // rgba(22,18,32,0.7)

  // ── Text ──
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textWhite = Colors.white;

  /// Returns the appropriate primary color based on platform.
  static Color primary({bool isWeb = false}) {
    return isWeb ? primaryWeb : primaryMobile;
  }

  /// Returns the appropriate background color based on platform and brightness.
  static Color background({bool isWeb = false, bool isDark = false}) {
    if (isDark) return isWeb ? backgroundDarkWeb : backgroundDark;
    return isWeb ? backgroundLightWeb : backgroundLight;
  }
}
