import 'package:flutter/material.dart';
import 'package:solodesk_mobile/modules/settings/domain/value_objects/accent_preset.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';

/// Maps each [AccentPreset] to its seed [Color].
///
/// Lives in the presentation layer because [Color] is a Flutter/UI concern —
/// the domain enum only carries the preset name.
extension AccentPresetColor on AccentPreset {
  Color get seed => switch (this) {
    AccentPreset.blue => AppColors.accentBlue,
    AccentPreset.green => AppColors.accentGreen,
    AccentPreset.purple => AppColors.accentPurple,
    AccentPreset.orange => AppColors.accentOrange,
  };
}
