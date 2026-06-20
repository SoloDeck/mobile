import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solodesk_mobile/core/theme/app_colors.dart';
import 'package:solodesk_mobile/core/theme/app_semantic_colors.dart';

class AppTheme {
  AppTheme._();

  /// Default brand seed (Blue-600) — used when no accent has been chosen.
  static const Color defaultSeed = AppColors.primary;

  /// Builds a fully-formed [ThemeData] for the given [brightness], seeded by
  /// [seed] (the personalization accent color).  Every surface, text and
  /// component color resolves from the brightness-aware [ColorScheme], so dark
  /// mode is correct by construction — no light-only constants leak through.
  static ThemeData build({
    required Brightness brightness,
    Color seed = defaultSeed,
  }) {
    final isDark = brightness == Brightness.dark;

    // Seed-driven scheme (accent personalization), with brand neutrals pinned
    // so the clean white/slate (light) and slate-900 (dark) identity stays.
    final base = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    final colorScheme = isDark
        ? base.copyWith(
            surface: AppColors.surfaceDark,
            onSurface: AppColors.textPrimaryDark,
            onSurfaceVariant: AppColors.textSecondaryDark,
            surfaceContainerHighest: AppColors.surfaceVariantDark,
            outline: AppColors.borderDark,
            outlineVariant: AppColors.dividerDark,
            error: AppColors.error,
          )
        : base.copyWith(
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
            onSurfaceVariant: AppColors.textSecondary,
            surfaceContainerHighest: AppColors.surfaceVariant,
            outline: AppColors.border,
            outlineVariant: AppColors.divider,
            error: AppColors.error,
          );

    final onSurface = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final textTertiary =
        isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    // Heading: Be Vietnam Pro — Vietnamese-first, clean, multilingual.
    // Body:    Noto Sans — excellent Vietnamese rendering at small sizes.
    final textTheme = GoogleFonts.notoSansTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ).copyWith(
      headlineLarge: GoogleFonts.beVietnamPro(
          fontSize: 28, fontWeight: FontWeight.w700, color: onSurface),
      headlineMedium: GoogleFonts.beVietnamPro(
          fontSize: 24, fontWeight: FontWeight.w600, color: onSurface),
      headlineSmall: GoogleFonts.beVietnamPro(
          fontSize: 20, fontWeight: FontWeight.w600, color: onSurface),
      titleLarge: GoogleFonts.beVietnamPro(
          fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),
      titleMedium: GoogleFonts.beVietnamPro(
          fontSize: 16, fontWeight: FontWeight.w500, color: onSurface),
      titleSmall: GoogleFonts.beVietnamPro(
          fontSize: 14, fontWeight: FontWeight.w500, color: onSurfaceVariant),
      bodyLarge: GoogleFonts.notoSans(
          fontSize: 16, fontWeight: FontWeight.w400, color: onSurface),
      bodyMedium: GoogleFonts.notoSans(
          fontSize: 14, fontWeight: FontWeight.w400, color: onSurfaceVariant),
      bodySmall: GoogleFonts.notoSans(
          fontSize: 12, fontWeight: FontWeight.w400, color: textTertiary),
      labelLarge: GoogleFonts.notoSans(
          fontSize: 14, fontWeight: FontWeight.w600, color: onSurface),
      labelMedium: GoogleFonts.notoSans(
          fontSize: 12, fontWeight: FontWeight.w500, color: onSurfaceVariant),
      labelSmall: GoogleFonts.notoSans(
          fontSize: 11, fontWeight: FontWeight.w400, color: textTertiary),
    );

    final cardColor =
        isDark ? AppColors.cardSurfaceDark : AppColors.cardSurface;
    final scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.background;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scaffoldBg,
      extensions: [
        isDark ? AppSemanticColors.dark : AppSemanticColors.light,
      ],

      // ── AppBar ──────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: colorScheme.surface,
        foregroundColor: onSurface,
        titleTextStyle: GoogleFonts.beVietnamPro(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
      ),

      // ── Card ────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outline, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // ── ElevatedButton ──────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.beVietnamPro(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── OutlinedButton ──────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: colorScheme.primary),
          textStyle: GoogleFonts.beVietnamPro(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── TextField / InputDecoration ─────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        hintStyle: GoogleFonts.notoSans(fontSize: 14, color: textTertiary),
        labelStyle: GoogleFonts.notoSans(
          fontSize: 14,
          color: onSurfaceVariant,
        ),
      ),

      // ── BottomNavigationBar ─────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: textTertiary,
        selectedLabelStyle: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        elevation: 8,
      ),

      // ── FloatingActionButton ────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ── Divider ─────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 0,
      ),

      // ── SnackBar ────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Convenience: default-seed light theme.
  static ThemeData get light => build(brightness: Brightness.light);

  /// Convenience: default-seed dark theme.
  static ThemeData get dark => build(brightness: Brightness.dark);
}
