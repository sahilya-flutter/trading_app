import 'package:flutter/material.dart';

/// Centralized Design System Tokens for 021 Trading App
/// Adhering to Stitch Light Theme design system with Dark Theme fallback.
class AppColors {
  AppColors._();

  // --- LIGHT THEME (PRIMARY DESIGN SYSTEM) ---
  static const Color lightBackground = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceHigh = Color(0xFFF1F5F9);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightDivider = Color(0xFFE5E7EB);

  static const Color lightPrimary = Color(0xFF2563EB); // Professional Blue
  static const Color lightPrimaryLight = Color(0xFF3B82F6);
  static const Color lightPrimaryContainer = Color(0xFFDBEAFE);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);

  static const Color lightGain = Color(0xFF16A34A); // Professional Green
  static const Color lightGainBg = Color(0xFFDCFCE7);
  static const Color lightGainBorder = Color(0xFF86EFAC);

  static const Color lightLoss = Color(0xFFDC2626); // Professional Red
  static const Color lightLossBg = Color(0xFFFEE2E2);
  static const Color lightLossBorder = Color(0xFFFCA5A5);

  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextMuted = Color(0xFF9CA3AF);
  static const Color lightTextDisabled = Color(0xFFD1D5DB);

  static const Color lightInputFill = Color(0xFFFFFFFF);
  static const Color lightChipBackground = Color(0xFFF3F4F6);

  // --- DARK THEME (SUPPORTED SECONDARY) ---
  static const Color darkBackground = Color(0xFF0A141F);
  static const Color darkSurface = Color(0xFF17202B);
  static const Color darkSurfaceHigh = Color(0xFF212B36);
  static const Color darkSurfaceElevated = Color(0xFF2C3641);
  static const Color darkBorder = Color(0xFF414754);
  static const Color darkDivider = Color(0xFF2B3642);

  static const Color darkPrimary = Color(0xFFADC7FF);
  static const Color darkPrimaryLight = Color(0xFF4A8EFF);
  static const Color darkPrimaryContainer = Color(0xFF004493);
  static const Color darkOnPrimary = Color(0xFF002E68);

  static const Color darkGain = Color(0xFF57DEA3);
  static const Color darkGainBg = Color(0xFF003824);
  static const Color darkGainBorder = Color(0xFF005236);

  static const Color darkLoss = Color(0xFFFFB4AB);
  static const Color darkLossBg = Color(0xFF690005);
  static const Color darkLossBorder = Color(0xFF93000A);

  static const Color darkTextPrimary = Color(0xFFD9E3F3);
  static const Color darkTextSecondary = Color(0xFFC1C6D7);
  static const Color darkTextMuted = Color(0xFF8B90A0);
  static const Color darkTextDisabled = Color(0xFF5E6573);

  static const Color darkInputFill = Color(0xFF17202B);
  static const Color darkChipBackground = Color(0xFF212B36);

  // --- LEGACY COMPATIBILITY ALIASES (Dynamic according to context or dark/light defaults) ---
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color surfaceHigh = lightSurfaceHigh;
  static const Color surfaceElevated = lightSurfaceElevated;
  static const Color border = lightBorder;
  static const Color divider = lightDivider;

  static const Color primary = lightPrimary;
  static const Color primaryLight = lightPrimaryLight;
  static const Color primaryDark = Color(0xFF1D4ED8);

  static const Color gain = lightGain;
  static const Color gainBg = lightGainBg;
  static const Color gainBorder = lightGainBorder;

  static const Color loss = lightLoss;
  static const Color lossBg = lightLossBg;
  static const Color lossBorder = lightLossBorder;

  static const Color neutral = lightTextSecondary;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textMuted = lightTextMuted;
  static const Color textDisabled = lightTextDisabled;

  static const Color inputFill = lightInputFill;
  static const Color chipBackground = lightChipBackground;

  // Stitch Design System Tokens
  static const Color stitchSurface = darkBackground;
  static const Color stitchSurfaceContainer = darkSurface;
  static const Color stitchSurfaceContainerHigh = darkSurfaceHigh;
  static const Color stitchSurfaceContainerHighest = darkSurfaceElevated;
  static const Color stitchOutline = darkTextMuted;
  static const Color stitchOutlineVariant = darkBorder;
  static const Color stitchPrimary = darkPrimary;
  static const Color stitchOnPrimary = darkOnPrimary;
  static const Color stitchPrimaryContainer = darkPrimaryLight;
  static const Color stitchSecondary = darkGain;
  static const Color stitchOnSecondary = Color(0xFF003824);
  static const Color stitchError = darkLoss;
  static const Color stitchOnError = Color(0xFF690005);
  static const Color stitchOnSurface = darkTextPrimary;
  static const Color stitchOnSurfaceVariant = darkTextSecondary;
}
