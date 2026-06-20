import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/storage/secure_storage.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/appearance_settings.dart';
import 'package:solodesk_mobile/modules/settings/domain/repositories/settings_repository.dart';
import 'package:solodesk_mobile/modules/settings/domain/value_objects/accent_preset.dart';
import 'package:solodesk_mobile/modules/settings/infrastructure/repository/settings_repository_impl.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepositoryImpl(ref.read(secureStorageProvider));
}

/// App-wide appearance state (theme mode + accent).
///
/// [build] returns the defaults immediately so the first frame renders without
/// a flash, then asynchronously hydrates from persisted storage.  Mutations
/// persist before updating state.
@Riverpod(keepAlive: true)
class AppearanceController extends _$AppearanceController {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  AppearanceSettings build() {
    _hydrate();
    return AppearanceSettings.defaults;
  }

  Future<void> _hydrate() async {
    final loaded = await _repo.loadAppearance();
    if (loaded != state) state = loaded;
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == state.mode) return;
    await _repo.saveThemeMode(mode);
    state = state.copyWith(mode: mode);
  }

  Future<void> setAccent(AccentPreset accent) async {
    if (accent == state.accent) return;
    await _repo.saveAccent(accent);
    state = state.copyWith(accent: accent);
  }
}
