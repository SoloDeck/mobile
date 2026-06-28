import 'package:flutter/material.dart';
import 'package:solodesk_mobile/core/storage/secure_storage.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/appearance_settings.dart';
import 'package:solodesk_mobile/modules/settings/domain/repositories/settings_repository.dart';
import 'package:solodesk_mobile/modules/settings/domain/value_objects/accent_preset.dart';

/// [SettingsRepository] backed by [SecureStorage] (same pattern as TokenManager).
///
/// TODO(sync): mirror these values to the backend via `PreferencesDto.theme`
/// (auth/infrastructure/dto/preferences_dto.dart) once a settings sync endpoint
/// is wired — local storage stays the source of truth for instant startup.
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._storage);

  final SecureStorage _storage;

  static const _themeModeKey = 'app.theme_mode';
  static const _accentKey = 'app.accent';

  @override
  Future<AppearanceSettings> loadAppearance() async {
    final mode = ThemeModeStorage.fromStorage(await _storage.read(_themeModeKey));
    final accent = AccentPreset.fromStorage(await _storage.read(_accentKey));
    return AppearanceSettings(mode: mode, accent: accent);
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) =>
      _storage.write(_themeModeKey, mode.storageValue);

  @override
  Future<void> saveAccent(AccentPreset accent) =>
      _storage.write(_accentKey, accent.name);
}
