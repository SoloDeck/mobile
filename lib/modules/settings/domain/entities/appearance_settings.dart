import 'package:flutter/material.dart';
import 'package:solodesk_mobile/modules/settings/domain/value_objects/accent_preset.dart';

/// User's appearance personalization: theme mode + accent color.
@immutable
class AppearanceSettings {
  const AppearanceSettings({
    required this.mode,
    required this.accent,
  });

  final ThemeMode mode;
  final AccentPreset accent;

  /// Defaults applied before any persisted value is loaded.
  static const AppearanceSettings defaults = AppearanceSettings(
    mode: ThemeMode.system,
    accent: AccentPreset.fallback,
  );

  AppearanceSettings copyWith({ThemeMode? mode, AccentPreset? accent}) {
    return AppearanceSettings(
      mode: mode ?? this.mode,
      accent: accent ?? this.accent,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppearanceSettings &&
      other.mode == mode &&
      other.accent == accent;

  @override
  int get hashCode => Object.hash(mode, accent);
}

/// Maps [ThemeMode] to/from a stable storage string.
extension ThemeModeStorage on ThemeMode {
  String get storageValue => switch (this) {
        ThemeMode.system => 'system',
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
      };

  static ThemeMode fromStorage(String? value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
}
