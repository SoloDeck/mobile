import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:solodesk_mobile/core/storage/secure_storage.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/appearance_settings.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/business_profile.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/invoice_defaults.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/notification_preferences.dart';
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
  static const _notificationPrefsKey = 'app.notification_prefs';
  static const _invoiceDefaultsKey = 'app.invoice_defaults';
  static const _businessProfileKey = 'app.business_profile';

  @override
  Future<AppearanceSettings> loadAppearance() async {
    final mode = ThemeModeStorage.fromStorage(
      await _storage.read(_themeModeKey),
    );
    final accent = AccentPreset.fromStorage(await _storage.read(_accentKey));
    return AppearanceSettings(mode: mode, accent: accent);
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) =>
      _storage.write(_themeModeKey, mode.storageValue);

  @override
  Future<void> saveAccent(AccentPreset accent) =>
      _storage.write(_accentKey, accent.name);

  /// TODO(sync): mirror these toggles to the backend via
  /// `PUT /users/me/preferences` once a notification-preferences endpoint is
  /// wired — local storage stays the source of truth until then.
  @override
  Future<NotificationPreferences> loadNotificationPreferences() async {
    final raw = await _storage.read(_notificationPrefsKey);
    if (raw == null) return NotificationPreferences.defaults;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return NotificationPreferences(
      invoiceDue:
          json['invoiceDue'] as bool? ??
          NotificationPreferences.defaults.invoiceDue,
      quoteResponse:
          json['quoteResponse'] as bool? ??
          NotificationPreferences.defaults.quoteResponse,
      weeklyEmailSummary:
          json['weeklyEmailSummary'] as bool? ??
          NotificationPreferences.defaults.weeklyEmailSummary,
    );
  }

  /// TODO(sync): mirror these toggles to the backend via
  /// `PUT /users/me/preferences` once a notification-preferences endpoint is
  /// wired — local storage stays the source of truth until then.
  @override
  Future<void> saveNotificationPreferences(
    NotificationPreferences value,
  ) async {
    final json = {
      'invoiceDue': value.invoiceDue,
      'quoteResponse': value.quoteResponse,
      'weeklyEmailSummary': value.weeklyEmailSummary,
    };
    await _storage.write(_notificationPrefsKey, jsonEncode(json));
  }

  /// TODO(sync): mirror these defaults to the backend via
  /// `PUT /users/me/preferences` once an invoice-defaults endpoint is wired —
  /// local storage stays the source of truth until then.
  @override
  Future<InvoiceDefaults> loadInvoiceDefaults() async {
    final raw = await _storage.read(_invoiceDefaultsKey);
    if (raw == null) return InvoiceDefaults.defaults;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return InvoiceDefaults(
      vatPercent:
          (json['vatPercent'] as num?)?.toDouble() ??
          InvoiceDefaults.defaults.vatPercent,
      dueDays:
          json['dueDays'] as int? ?? InvoiceDefaults.defaults.dueDays,
      termsText: json['termsText'] as String?,
    );
  }

  /// TODO(sync): mirror these defaults to the backend via
  /// `PUT /users/me/preferences` once an invoice-defaults endpoint is wired —
  /// local storage stays the source of truth until then.
  @override
  Future<void> saveInvoiceDefaults(InvoiceDefaults value) async {
    final json = {
      'vatPercent': value.vatPercent,
      'dueDays': value.dueDays,
      'termsText': value.termsText,
    };
    await _storage.write(_invoiceDefaultsKey, jsonEncode(json));
  }

  /// TODO(sync): mirror this profile to the backend via `PUT /users/me` once
  /// a profile-update endpoint is wired — local storage stays the source of
  /// truth until then.
  @override
  Future<BusinessProfile> loadBusinessProfile() async {
    final raw = await _storage.read(_businessProfileKey);
    if (raw == null) return BusinessProfile.defaults;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return BusinessProfile(
      displayName:
          json['displayName'] as String? ??
          BusinessProfile.defaults.displayName,
      phone: json['phone'] as String? ?? BusinessProfile.defaults.phone,
      avatarLocalPath: json['avatarLocalPath'] as String?,
      businessName:
          json['businessName'] as String? ??
          BusinessProfile.defaults.businessName,
      logoLocalPath: json['logoLocalPath'] as String?,
      industry:
          json['industry'] as String? ?? BusinessProfile.defaults.industry,
      taxCode: json['taxCode'] as String? ?? BusinessProfile.defaults.taxCode,
      address: json['address'] as String? ?? BusinessProfile.defaults.address,
      bankAccountMasked:
          json['bankAccountMasked'] as String? ??
          BusinessProfile.defaults.bankAccountMasked,
      publicSlug: json['publicSlug'] as String?,
    );
  }

  /// TODO(sync): mirror this profile to the backend via `PUT /users/me` once
  /// a profile-update endpoint is wired — local storage stays the source of
  /// truth until then.
  @override
  Future<void> saveBusinessProfile(BusinessProfile value) async {
    final json = {
      'displayName': value.displayName,
      'phone': value.phone,
      'avatarLocalPath': value.avatarLocalPath,
      'businessName': value.businessName,
      'logoLocalPath': value.logoLocalPath,
      'industry': value.industry,
      'taxCode': value.taxCode,
      'address': value.address,
      'bankAccountMasked': value.bankAccountMasked,
      'publicSlug': value.publicSlug,
    };
    await _storage.write(_businessProfileKey, jsonEncode(json));
  }
}
