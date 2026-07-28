import 'package:flutter/material.dart' show ThemeMode;
import 'package:solodesk_mobile/modules/settings/domain/entities/appearance_settings.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/business_profile.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/invoice_defaults.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/notification_preferences.dart';
import 'package:solodesk_mobile/modules/settings/domain/value_objects/accent_preset.dart';

/// Persistence contract for user appearance settings.
abstract interface class SettingsRepository {
  /// Loads the persisted appearance settings, or [AppearanceSettings.defaults].
  Future<AppearanceSettings> loadAppearance();

  Future<void> saveThemeMode(ThemeMode mode);

  Future<void> saveAccent(AccentPreset accent);

  /// Loads the persisted notification toggles, or
  /// [NotificationPreferences.defaults].
  Future<NotificationPreferences> loadNotificationPreferences();

  Future<void> saveNotificationPreferences(NotificationPreferences value);

  /// Loads the persisted invoice/quote defaults, or [InvoiceDefaults.defaults].
  Future<InvoiceDefaults> loadInvoiceDefaults();

  Future<void> saveInvoiceDefaults(InvoiceDefaults value);

  /// Loads the persisted profile/business fields, or [BusinessProfile.defaults].
  Future<BusinessProfile> loadBusinessProfile();

  Future<void> saveBusinessProfile(BusinessProfile value);
}
