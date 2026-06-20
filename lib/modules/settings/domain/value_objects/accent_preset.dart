import 'package:flutter/material.dart';

/// The finite set of accent (seed) colors a user can personalize with.
///
/// Kept as an enum (not a free-form color) so the choice is persistable as a
/// stable string and the UI shows a curated, on-brand palette.
enum AccentPreset {
  blue(Color(0xFF2563EB), 'Xanh dương'),
  green(Color(0xFF059669), 'Xanh lá'),
  purple(Color(0xFF7C3AED), 'Tím'),
  orange(Color(0xFFEA580C), 'Cam');

  const AccentPreset(this.seed, this.label);

  /// Seed color fed to `ColorScheme.fromSeed`.
  final Color seed;

  /// Vietnamese label shown in the settings UI.
  final String label;

  /// The default accent when nothing has been chosen yet.
  static const AccentPreset fallback = AccentPreset.blue;

  /// Parses a persisted name; returns [fallback] for unknown/null input.
  static AccentPreset fromStorage(String? name) {
    return AccentPreset.values.firstWhere(
      (p) => p.name == name,
      orElse: () => fallback,
    );
  }
}
