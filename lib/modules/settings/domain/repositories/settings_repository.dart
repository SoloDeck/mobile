import 'package:flutter/material.dart' show ThemeMode;
import 'package:solodesk_mobile/modules/settings/domain/entities/appearance_settings.dart';
import 'package:solodesk_mobile/modules/settings/domain/value_objects/accent_preset.dart';

/// Persistence contract for user appearance settings.
abstract interface class SettingsRepository {
  /// Loads the persisted appearance settings, or [AppearanceSettings.defaults].
  Future<AppearanceSettings> loadAppearance();

  Future<void> saveThemeMode(ThemeMode mode);

  Future<void> saveAccent(AccentPreset accent);
}
