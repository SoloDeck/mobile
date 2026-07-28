import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/appearance_settings.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/business_profile.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/invoice_defaults.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/notification_preferences.dart';
import 'package:solodesk_mobile/modules/settings/domain/repositories/settings_repository.dart';
import 'package:solodesk_mobile/modules/settings/domain/value_objects/accent_preset.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';

/// In-memory [SettingsRepository] standing in for SecureStorage.
class _FakeSettingsRepository implements SettingsRepository {
  AppearanceSettings _stored;
  NotificationPreferences _notificationPreferences =
      NotificationPreferences.defaults;
  InvoiceDefaults _invoiceDefaults = InvoiceDefaults.defaults;
  BusinessProfile _businessProfile = BusinessProfile.defaults;

  _FakeSettingsRepository(this._stored);

  @override
  Future<AppearanceSettings> loadAppearance() async => _stored;

  @override
  Future<void> saveThemeMode(ThemeMode mode) async =>
      _stored = _stored.copyWith(mode: mode);

  @override
  Future<void> saveAccent(AccentPreset accent) async =>
      _stored = _stored.copyWith(accent: accent);

  @override
  Future<NotificationPreferences> loadNotificationPreferences() async =>
      _notificationPreferences;

  @override
  Future<void> saveNotificationPreferences(
    NotificationPreferences value,
  ) async => _notificationPreferences = value;

  @override
  Future<InvoiceDefaults> loadInvoiceDefaults() async => _invoiceDefaults;

  @override
  Future<void> saveInvoiceDefaults(InvoiceDefaults value) async =>
      _invoiceDefaults = value;

  @override
  Future<BusinessProfile> loadBusinessProfile() async => _businessProfile;

  @override
  Future<void> saveBusinessProfile(BusinessProfile value) async =>
      _businessProfile = value;
}

ProviderContainer _containerWith(_FakeSettingsRepository repo) {
  final container = ProviderContainer(
    overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('defaults to system + blue before hydration', () {
    final container = _containerWith(
      _FakeSettingsRepository(AppearanceSettings.defaults),
    );

    final state = container.read(appearanceControllerProvider);

    expect(state.mode, ThemeMode.system);
    expect(state.accent, AccentPreset.blue);
  });

  test('hydrates persisted appearance settings', () async {
    final container = _containerWith(
      _FakeSettingsRepository(
        const AppearanceSettings(
          mode: ThemeMode.dark,
          accent: AccentPreset.purple,
        ),
      ),
    );

    // Initial synchronous build returns defaults; pump the microtask queue so
    // the async _hydrate() completes.
    container.read(appearanceControllerProvider);
    await container.pump();

    final state = container.read(appearanceControllerProvider);
    expect(state.mode, ThemeMode.dark);
    expect(state.accent, AccentPreset.purple);
  });

  test('setMode persists and updates state', () async {
    final repo = _FakeSettingsRepository(AppearanceSettings.defaults);
    final container = _containerWith(repo);
    final controller = container.read(appearanceControllerProvider.notifier);

    await controller.setMode(ThemeMode.dark);

    expect(container.read(appearanceControllerProvider).mode, ThemeMode.dark);
    expect((await repo.loadAppearance()).mode, ThemeMode.dark);
  });

  test('setAccent persists and updates state', () async {
    final repo = _FakeSettingsRepository(AppearanceSettings.defaults);
    final container = _containerWith(repo);
    final controller = container.read(appearanceControllerProvider.notifier);

    await controller.setAccent(AccentPreset.green);

    expect(
      container.read(appearanceControllerProvider).accent,
      AccentPreset.green,
    );
    expect((await repo.loadAppearance()).accent, AccentPreset.green);
  });
}
