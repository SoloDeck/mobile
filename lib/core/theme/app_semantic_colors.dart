import 'package:flutter/material.dart';
import 'package:solodesk_mobile/core/theme/app_colors.dart';

/// Brightness-aware semantic colors that have no slot in [ColorScheme].
///
/// Status colors, pipeline-stage colors, lead-score badges and shimmer tones
/// live here so widgets read them via
/// `Theme.of(context).extension<AppSemanticColors>()!` and automatically get
/// the right value for the active brightness — instead of hardcoding
/// `Colors.white` / `AppColors.*` (which only ever worked in light mode).
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.info,
    required this.infoContainer,
    required this.scoreHot,
    required this.scoreWarm,
    required this.scoreCold,
    required this.onScore,
    required this.stageNewLead,
    required this.stageQualified,
    required this.stageProposalSent,
    required this.stageInNegotiation,
    required this.stageActive,
    required this.stageCompleted,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color info;
  final Color infoContainer;

  // Lead-score badges (voice capture).
  final Color scoreHot;
  final Color scoreWarm;
  final Color scoreCold;
  final Color onScore;

  // Pipeline stages.
  final Color stageNewLead;
  final Color stageQualified;
  final Color stageProposalSent;
  final Color stageInNegotiation;
  final Color stageActive;
  final Color stageCompleted;

  // Loading shimmer.
  final Color shimmerBase;
  final Color shimmerHighlight;

  static const AppSemanticColors light = AppSemanticColors(
    success: AppColors.success,
    onSuccess: Colors.white,
    successContainer: AppColors.successBg,
    warning: AppColors.warning,
    warningContainer: AppColors.warningBg,
    info: AppColors.info,
    infoContainer: AppColors.infoBg,
    scoreHot: Color(0xFFB91C1C), // red-700
    scoreWarm: Color(0xFFC2410C), // orange-700
    scoreCold: Color(0xFF1D4ED8), // blue-700
    onScore: Colors.white,
    stageNewLead: AppColors.stageNewLead,
    stageQualified: AppColors.stageQualified,
    stageProposalSent: AppColors.stageProposalSent,
    stageInNegotiation: AppColors.stageInNegotiation,
    stageActive: AppColors.stageActive,
    stageCompleted: AppColors.stageCompleted,
    shimmerBase: AppColors.shimmerBase,
    shimmerHighlight: AppColors.shimmerHighlight,
  );

  static const AppSemanticColors dark = AppSemanticColors(
    success: Color(0xFF34D399), // emerald-400
    onSuccess: Color(0xFF052E1A),
    successContainer: Color(0xFF0C3D2B),
    warning: Color(0xFFFBBF24), // amber-400
    warningContainer: Color(0xFF422F0B),
    info: Color(0xFF60A5FA), // blue-400
    infoContainer: Color(0xFF12325E),
    scoreHot: Color(0xFFF87171), // red-400
    scoreWarm: Color(0xFFFB923C), // orange-400
    scoreCold: Color(0xFF60A5FA), // blue-400
    onScore: Color(0xFF0F172A),
    stageNewLead: Color(0xFF818CF8), // indigo-400
    stageQualified: Color(0xFFA78BFA), // violet-400
    stageProposalSent: Color(0xFFFBBF24), // amber-400
    stageInNegotiation: Color(0xFFFB923C), // orange-400
    stageActive: Color(0xFF34D399), // emerald-400
    stageCompleted: Color(0xFF60A5FA), // blue-400
    shimmerBase: Color(0xFF1E293B), // slate-800
    shimmerHighlight: Color(0xFF334155), // slate-700
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? info,
    Color? infoContainer,
    Color? scoreHot,
    Color? scoreWarm,
    Color? scoreCold,
    Color? onScore,
    Color? stageNewLead,
    Color? stageQualified,
    Color? stageProposalSent,
    Color? stageInNegotiation,
    Color? stageActive,
    Color? stageCompleted,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      scoreHot: scoreHot ?? this.scoreHot,
      scoreWarm: scoreWarm ?? this.scoreWarm,
      scoreCold: scoreCold ?? this.scoreCold,
      onScore: onScore ?? this.onScore,
      stageNewLead: stageNewLead ?? this.stageNewLead,
      stageQualified: stageQualified ?? this.stageQualified,
      stageProposalSent: stageProposalSent ?? this.stageProposalSent,
      stageInNegotiation: stageInNegotiation ?? this.stageInNegotiation,
      stageActive: stageActive ?? this.stageActive,
      stageCompleted: stageCompleted ?? this.stageCompleted,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      scoreHot: Color.lerp(scoreHot, other.scoreHot, t)!,
      scoreWarm: Color.lerp(scoreWarm, other.scoreWarm, t)!,
      scoreCold: Color.lerp(scoreCold, other.scoreCold, t)!,
      onScore: Color.lerp(onScore, other.onScore, t)!,
      stageNewLead: Color.lerp(stageNewLead, other.stageNewLead, t)!,
      stageQualified: Color.lerp(stageQualified, other.stageQualified, t)!,
      stageProposalSent:
          Color.lerp(stageProposalSent, other.stageProposalSent, t)!,
      stageInNegotiation:
          Color.lerp(stageInNegotiation, other.stageInNegotiation, t)!,
      stageActive: Color.lerp(stageActive, other.stageActive, t)!,
      stageCompleted: Color.lerp(stageCompleted, other.stageCompleted, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
    );
  }
}

/// Convenience accessor: `context.semanticColors.success`.
extension AppSemanticColorsX on BuildContext {
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;
}
