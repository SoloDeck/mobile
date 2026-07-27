import 'package:flutter/material.dart';
import 'package:solodesk_mobile/core/theme/app_colors.dart';
import 'package:solodesk_mobile/core/theme/app_semantic_colors.dart';

class AppTheme {
  AppTheme._();

  /// Default brand seed (Blue-600) — used when no accent has been chosen.
  static const Color defaultSeed = AppColors.primary;

  /// The only font family this theme bundles — see assets/fonts/README.md.
  /// Vietnamese-first, clean, multilingual; used for both headings and body
  /// so the theme doesn't depend on `google_fonts` fetching anything at
  /// runtime (AGENTS.md rule 6 — the app must run offline on first launch).
  static const String _fontFamily = 'Be Vietnam Pro';

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
    final textTertiary = isDark
        ? AppColors.textTertiaryDark
        : AppColors.textTertiary;

    final textTheme = (isDark ? ThemeData.dark() : ThemeData.light()).textTheme
        .apply(fontFamily: _fontFamily)
        .copyWith(
          headlineLarge: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: onSurface,
          ),
          headlineMedium: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
          headlineSmall: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
          titleLarge: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
          titleMedium: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: onSurface,
          ),
          titleSmall: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: onSurfaceVariant,
          ),
          bodyLarge: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: onSurface,
          ),
          bodyMedium: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: onSurfaceVariant,
          ),
          bodySmall: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textTertiary,
          ),
          labelLarge: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
          labelMedium: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: onSurfaceVariant,
          ),
          labelSmall: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: textTertiary,
          ),
        );

    final cardColor = isDark
        ? AppColors.cardSurfaceDark
        : AppColors.cardSurface;
    final scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.background;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scaffoldBg,
      extensions: [isDark ? AppSemanticColors.dark : AppSemanticColors.light],

      // ── AppBar ──────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: colorScheme.surface,
        foregroundColor: onSurface,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
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
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
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
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
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
        hintStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          color: textTertiary,
        ),
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
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
        selectedLabelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: _fontFamily,
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
