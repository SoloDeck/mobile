/// The finite set of accent (seed) colors a user can personalize with.
///
/// Kept as an enum (not a free-form color) so the choice is persistable as a
/// stable string and the UI shows a curated, on-brand palette.
///
/// This is a pure domain value object — it only knows preset *names*. The
/// [Color] each preset maps to lives in the presentation layer (see the
/// `AccentPresetColor` extension in
/// `presentation/theme/accent_preset_colors.dart`) since `dart:ui` colors
/// are not a domain concern.
enum AccentPreset {
  blue('Xanh dương'),
  green('Xanh lá'),
  purple('Tím'),
  orange('Cam');

  const AccentPreset(this.label);

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
