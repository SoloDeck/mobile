import 'package:flutter/material.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/appearance_settings.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/business_profile.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/invoice_defaults.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/notification_preferences.dart';
import 'package:solodesk_mobile/modules/settings/domain/repositories/settings_repository.dart';
import 'package:solodesk_mobile/modules/settings/domain/value_objects/accent_preset.dart';

/// In-memory [SettingsRepository] standing in for SecureStorage in widget/
/// golden tests — those never wire a real `flutter_secure_storage` plugin, so
/// hitting the real [SettingsRepositoryImpl] throws `MissingPluginException`
/// out of `AppearanceController._hydrate()` (unawaited from `build()`) and
/// fails the test even though nothing under test cares about persistence.
///
/// Override `settingsRepositoryProvider` with this wherever the page under
/// test reads `appearanceControllerProvider` (directly or via a shared
/// `Theme(data: AppTheme.light(seed: ...))` wrapper).
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({AppearanceSettings? appearance})
    : _appearance = appearance ?? AppearanceSettings.defaults;

  AppearanceSettings _appearance;
  NotificationPreferences _notificationPreferences =
      NotificationPreferences.defaults;
  InvoiceDefaults _invoiceDefaults = InvoiceDefaults.defaults;
  BusinessProfile _businessProfile = BusinessProfile.defaults;

  @override
  Future<AppearanceSettings> loadAppearance() async => _appearance;

  @override
  Future<void> saveThemeMode(ThemeMode mode) async =>
      _appearance = _appearance.copyWith(mode: mode);

  @override
  Future<void> saveAccent(AccentPreset accent) async =>
      _appearance = _appearance.copyWith(accent: accent);

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
