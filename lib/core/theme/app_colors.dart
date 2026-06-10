import 'package:flutter/material.dart';

/// Bảng màu ứng dụng SoloDesk — tone sáng, hiện đại.
class AppColors {
  AppColors._();

  // ─── Primary ────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6366F1); // Indigo-500
  static const Color primaryLight = Color(0xFF818CF8); // Indigo-400
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo-600
  static const Color primaryContainer = Color(0xFFE0E7FF); // Indigo-100
  static const Color onPrimary = Colors.white;

  // ─── Secondary ──────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF8B5CF6); // Violet-500
  static const Color secondaryContainer = Color(0xFFEDE9FE); // Violet-100

  // ─── Tertiary ───────────────────────────────────────────────────────
  static const Color tertiary = Color(0xFF10B981); // Emerald-500
  static const Color tertiaryContainer = Color(0xFFD1FAE5); // Emerald-100

  // ─── Background & Surface ──────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC); // Slate-50
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate-100
  static const Color cardSurface = Colors.white;

  // ─── Text ───────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E293B); // Slate-800
  static const Color textSecondary = Color(0xFF64748B); // Slate-500
  static const Color textTertiary = Color(0xFF94A3B8); // Slate-400
  static const Color textOnPrimary = Colors.white;

  // ─── Borders & Dividers ─────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0); // Slate-200
  static const Color divider = Color(0xFFF1F5F9); // Slate-100

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
