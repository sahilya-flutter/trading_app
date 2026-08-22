import 'package:flutter/material.dart';

/// Centralized Design System Tokens for 021 Trading App
/// Adhering to Google Stitch Design System with full Light & Dark mode support.
class AppColors {
  AppColors._();

  // --- LIGHT THEME TOKENS (STITCH LIGHT) ---
  static const Color lightBackground = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceHigh = Color(0xFFF1F5F9);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightDivider = Color(0xFFECEFF2);

  static const Color lightPrimary = Color(0xFF1F4FD8);
  static const Color lightPrimaryLight = Color(0xFF3B82F6);
  static const Color lightPrimaryContainer = Color(0xFFDBEAFE);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);

  static const Color lightGain = Color(0xFF16A34A);
  static const Color lightGainBg = Color(0xFFDCFCE7);
  static const Color lightGainBorder = Color(0xFF86EFAC);

  static const Color lightLoss = Color(0xFFDC2626);
  static const Color lightLossBg = Color(0xFFFEE2E2);
  static const Color lightLossBorder = Color(0xFFFCA5A5);

  static const Color lightTextPrimary = Color(0xFF0E1621);
  static const Color lightTextSecondary = Color(0xFF65707D);
  static const Color lightTextMuted = Color(0xFF9AA4B0);
  static const Color lightTextDisabled = Color(0xFFCBD5E1);

  static const Color lightInputFill = Color(0xFFFFFFFF);
  static const Color lightChipBackground = Color(0xFFF1F5F9);
  static const Color lightCardShadow = Color(0x0F000000);

  // --- DARK THEME TOKENS (STITCH DARK) ---
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
  static const Color darkCardShadow = Color(0x59000000);

  // --- LEGACY STATIC CONSTANTS (For non-contextual or fallback usage) ---
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

  // Stitch Material 3 semantic aliases
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

/// ThemeExtension providing semantic colors that automatically resolve
/// based on the active theme mode (Light or Dark).
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color surfaceElevated;
  final Color border;
  final Color divider;

  final Color primary;
  final Color primaryLight;
  final Color primaryContainer;
  final Color onPrimary;

  final Color gain;
  final Color gainBg;
  final Color gainBorder;

  final Color loss;
  final Color lossBg;
  final Color lossBorder;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;

  final Color inputFill;
  final Color chipBackground;
  final Color cardShadow;

  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.surfaceElevated,
    required this.border,
    required this.divider,
    required this.primary,
    required this.primaryLight,
    required this.primaryContainer,
    required this.onPrimary,
    required this.gain,
    required this.gainBg,
    required this.gainBorder,
    required this.loss,
    required this.lossBg,
    required this.lossBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.inputFill,
    required this.chipBackground,
    required this.cardShadow,
  });

  static const AppThemeColors light = AppThemeColors(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceHigh: AppColors.lightSurfaceHigh,
    surfaceElevated: AppColors.lightSurfaceElevated,
    border: AppColors.lightBorder,
    divider: AppColors.lightDivider,
    primary: AppColors.lightPrimary,
    primaryLight: AppColors.lightPrimaryLight,
    primaryContainer: AppColors.lightPrimaryContainer,
    onPrimary: AppColors.lightOnPrimary,
    gain: AppColors.lightGain,
    gainBg: AppColors.lightGainBg,
    gainBorder: AppColors.lightGainBorder,
    loss: AppColors.lightLoss,
    lossBg: AppColors.lightLossBg,
    lossBorder: AppColors.lightLossBorder,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textMuted: AppColors.lightTextMuted,
    textDisabled: AppColors.lightTextDisabled,
    inputFill: AppColors.lightInputFill,
    chipBackground: AppColors.lightChipBackground,
    cardShadow: AppColors.lightCardShadow,
  );

  static const AppThemeColors dark = AppThemeColors(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceHigh: AppColors.darkSurfaceHigh,
    surfaceElevated: AppColors.darkSurfaceElevated,
    border: AppColors.darkBorder,
    divider: AppColors.darkDivider,
    primary: AppColors.darkPrimary,
    primaryLight: AppColors.darkPrimaryLight,
    primaryContainer: AppColors.darkPrimaryContainer,
    onPrimary: AppColors.darkOnPrimary,
    gain: AppColors.darkGain,
    gainBg: AppColors.darkGainBg,
    gainBorder: AppColors.darkGainBorder,
    loss: AppColors.darkLoss,
    lossBg: AppColors.darkLossBg,
    lossBorder: AppColors.darkLossBorder,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: AppColors.darkTextMuted,
    textDisabled: AppColors.darkTextDisabled,
    inputFill: AppColors.darkInputFill,
    chipBackground: AppColors.darkChipBackground,
    cardShadow: AppColors.darkCardShadow,
  );

  @override
  ThemeExtension<AppThemeColors> copyWith({
    Color? background,
    Color? surface,
    Color? surfaceHigh,
    Color? surfaceElevated,
    Color? border,
    Color? divider,
    Color? primary,
    Color? primaryLight,
    Color? primaryContainer,
    Color? onPrimary,
    Color? gain,
    Color? gainBg,
    Color? gainBorder,
    Color? loss,
    Color? lossBg,
    Color? lossBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textDisabled,
    Color? inputFill,
    Color? chipBackground,
    Color? cardShadow,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimary: onPrimary ?? this.onPrimary,
      gain: gain ?? this.gain,
      gainBg: gainBg ?? this.gainBg,
      gainBorder: gainBorder ?? this.gainBorder,
      loss: loss ?? this.loss,
      lossBg: lossBg ?? this.lossBg,
      lossBorder: lossBorder ?? this.lossBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textDisabled: textDisabled ?? this.textDisabled,
      inputFill: inputFill ?? this.inputFill,
      chipBackground: chipBackground ?? this.chipBackground,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  ThemeExtension<AppThemeColors> lerp(
    covariant ThemeExtension<AppThemeColors>? other,
    double t,
  ) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t) ?? surfaceHigh,
      surfaceElevated:
          Color.lerp(surfaceElevated, other.surfaceElevated, t) ?? surfaceElevated,
      border: Color.lerp(border, other.border, t) ?? border,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      primaryLight:
          Color.lerp(primaryLight, other.primaryLight, t) ?? primaryLight,
      primaryContainer:
          Color.lerp(primaryContainer, other.primaryContainer, t) ??
              primaryContainer,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t) ?? onPrimary,
      gain: Color.lerp(gain, other.gain, t) ?? gain,
      gainBg: Color.lerp(gainBg, other.gainBg, t) ?? gainBg,
      gainBorder: Color.lerp(gainBorder, other.gainBorder, t) ?? gainBorder,
      loss: Color.lerp(loss, other.loss, t) ?? loss,
      lossBg: Color.lerp(lossBg, other.lossBg, t) ?? lossBg,
      lossBorder: Color.lerp(lossBorder, other.lossBorder, t) ?? lossBorder,
      textPrimary:
          Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      textDisabled:
          Color.lerp(textDisabled, other.textDisabled, t) ?? textDisabled,
      inputFill: Color.lerp(inputFill, other.inputFill, t) ?? inputFill,
      chipBackground:
          Color.lerp(chipBackground, other.chipBackground, t) ?? chipBackground,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t) ?? cardShadow,
    );
  }
}

/// Convenience BuildContext extension for concise and reactive theme consumption.
extension ThemeContextExtension on BuildContext {
  AppThemeColors get colors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.light;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
