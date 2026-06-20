import 'package:flutter/material.dart';

/// Bảng màu ứng dụng SoloDesk — tone sáng, hiện đại.
class AppColors {
  AppColors._();

  // ─── Primary ────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF2563EB); // Blue-600
  static const Color primaryLight = Color(0xFF3B82F6); // Blue-500
  static const Color primaryDark = Color(0xFF1D4ED8); // Blue-700
  static const Color primaryContainer = Color(0xFFDBEAFE); // Blue-100
  static const Color onPrimary = Colors.white;

  // ─── Secondary ──────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF3B82F6); // Blue-500
  static const Color secondaryContainer = Color(0xFFDBEAFE); // Blue-100

  // ─── Tertiary (accent/CTA — deal green) ─────────────────────────────
  static const Color tertiary = Color(0xFF059669); // Emerald-600
  static const Color tertiaryContainer = Color(0xFFD1FAE5); // Emerald-100

  // ─── Background & Surface (light) ──────────────────────────────────
  static const Color background = Color(0xFFF8FAFC); // Slate-50
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate-100
  static const Color cardSurface = Colors.white;

  // ─── Background & Surface (dark) ───────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F172A); // Slate-900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate-800
  static const Color surfaceVariantDark = Color(0xFF334155); // Slate-700
  static const Color cardSurfaceDark = Color(0xFF1E293B); // Slate-800

  // ─── Text (light) ───────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E293B); // Slate-800
  static const Color textSecondary = Color(0xFF64748B); // Slate-500
  static const Color textTertiary = Color(0xFF94A3B8); // Slate-400
  static const Color textOnPrimary = Colors.white;

  // ─── Text (dark) ────────────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFF1F5F9); // Slate-100
  static const Color textSecondaryDark = Color(0xFFCBD5E1); // Slate-300
  static const Color textTertiaryDark = Color(0xFF94A3B8); // Slate-400

  // ─── Borders & Dividers ─────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0); // Slate-200
  static const Color divider = Color(0xFFF1F5F9); // Slate-100
  static const Color borderDark = Color(0xFF334155); // Slate-700
  static const Color dividerDark = Color(0xFF1E293B); // Slate-800

  // ─── Status ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color error = Color(0xFFEF4444); // Red-500
  static const Color info = Color(0xFF3B82F6); // Blue-500

  static const Color successBg = Color(0xFFD1FAE5);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color infoBg = Color(0xFFDBEAFE);

  // ─── Pipeline Stage Colors ──────────────────────────────────────────
  static const Color stageNewLead = Color(0xFF6366F1);
  static const Color stageQualified = Color(0xFF8B5CF6);
  static const Color stageProposalSent = Color(0xFFF59E0B);
  static const Color stageInNegotiation = Color(0xFFF97316);
  static const Color stageActive = Color(0xFF10B981);
  static const Color stageCompleted = Color(0xFF3B82F6);

  // ─── Shimmer ────────────────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
}
