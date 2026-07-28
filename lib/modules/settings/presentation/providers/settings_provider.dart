import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/storage/secure_storage.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/appearance_settings.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/business_profile.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/invoice_defaults.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/notification_preferences.dart';
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

/// Local-only notification toggle preferences (no backend sync yet).
///
/// [build] returns the defaults immediately so the first frame renders without
/// a flash, then asynchronously hydrates from persisted storage.  Mutations
/// persist before updating state.
@Riverpod(keepAlive: true)
class NotificationPreferencesController
    extends _$NotificationPreferencesController {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  NotificationPreferences build() {
    _hydrate();
    return NotificationPreferences.defaults;
  }

  Future<void> _hydrate() async {
    final loaded = await _repo.loadNotificationPreferences();
    if (loaded != state) state = loaded;
  }

  Future<void> setInvoiceDue(bool value) async {
    if (value == state.invoiceDue) return;
    final next = state.copyWith(invoiceDue: value);
    await _repo.saveNotificationPreferences(next);
    state = next;
  }

  Future<void> setQuoteResponse(bool value) async {
    if (value == state.quoteResponse) return;
    final next = state.copyWith(quoteResponse: value);
    await _repo.saveNotificationPreferences(next);
    state = next;
  }

  Future<void> setWeeklyEmailSummary(bool value) async {
    if (value == state.weeklyEmailSummary) return;
    final next = state.copyWith(weeklyEmailSummary: value);
    await _repo.saveNotificationPreferences(next);
    state = next;
  }
}

/// Local-only invoice/quote defaults (no backend sync yet).
///
/// [build] returns the defaults immediately so the first frame renders without
/// a flash, then asynchronously hydrates from persisted storage.  Mutations
/// persist before updating state.
@Riverpod(keepAlive: true)
class InvoiceDefaultsController extends _$InvoiceDefaultsController {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  InvoiceDefaults build() {
    _hydrate();
    return InvoiceDefaults.defaults;
  }

  Future<void> _hydrate() async {
    final loaded = await _repo.loadInvoiceDefaults();
    if (loaded != state) state = loaded;
  }

  Future<void> setVatPercent(double value) async {
    if (value == state.vatPercent) return;
    final next = state.copyWith(vatPercent: value);
    await _repo.saveInvoiceDefaults(next);
    state = next;
  }

  Future<void> setDueDays(int value) async {
    if (value == state.dueDays) return;
    final next = state.copyWith(dueDays: value);
    await _repo.saveInvoiceDefaults(next);
    state = next;
  }

  Future<void> setTermsText(String? value) async {
    if (value == state.termsText) return;
    final next = InvoiceDefaults(
      vatPercent: state.vatPercent,
      dueDays: state.dueDays,
      termsText: value,
    );
    await _repo.saveInvoiceDefaults(next);
    state = next;
  }
}

/// Local-only profile/business fields (no backend `PUT` yet).
///
/// [build] returns the defaults immediately so the first frame renders without
/// a flash, then asynchronously hydrates from persisted storage.  The Hồ sơ
/// screen has a single shared "Lưu" action, so this controller exposes one
/// [save] method rather than per-field setters.
@Riverpod(keepAlive: true)
class BusinessProfileController extends _$BusinessProfileController {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  BusinessProfile build() {
    _hydrate();
    return BusinessProfile.defaults;
  }

  Future<void> _hydrate() async {
    final loaded = await _repo.loadBusinessProfile();
    if (loaded != state) state = loaded;
  }

  Future<void> save(BusinessProfile value) async {
    await _repo.saveBusinessProfile(value);
    state = value;
  }
}
