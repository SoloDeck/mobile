import 'package:flutter/foundation.dart';

/// User-editable profile/business fields with no backend `PUT` yet.
///
/// Email is intentionally excluded — it is read-only from `AuthUser` and
/// never stored here.
@immutable
class BusinessProfile {
  const BusinessProfile({
    required this.displayName,
    required this.phone,
    required this.avatarLocalPath,
    required this.businessName,
    required this.logoLocalPath,
    required this.industry,
    required this.taxCode,
    required this.address,
    required this.bankAccountMasked,
    required this.publicSlug,
  });

  final String displayName;
  final String phone;
  final String? avatarLocalPath;
  final String businessName;
  final String? logoLocalPath;
  final String industry;
  final String taxCode;
  final String address;
  final String bankAccountMasked;
  final String? publicSlug;

  /// Defaults applied before any persisted value is loaded.
  static const BusinessProfile defaults = BusinessProfile(
    displayName: '',
    phone: '',
    avatarLocalPath: null,
    businessName: '',
    logoLocalPath: null,
    industry: '',
    taxCode: '',
    address: '',
    bankAccountMasked: '',
    publicSlug: null,
  );

  BusinessProfile copyWith({
    String? displayName,
    String? phone,
    String? avatarLocalPath,
    String? businessName,
    String? logoLocalPath,
    String? industry,
    String? taxCode,
    String? address,
    String? bankAccountMasked,
    String? publicSlug,
  }) {
    return BusinessProfile(
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
      businessName: businessName ?? this.businessName,
      logoLocalPath: logoLocalPath ?? this.logoLocalPath,
      industry: industry ?? this.industry,
      taxCode: taxCode ?? this.taxCode,
      address: address ?? this.address,
      bankAccountMasked: bankAccountMasked ?? this.bankAccountMasked,
      publicSlug: publicSlug ?? this.publicSlug,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BusinessProfile &&
      other.displayName == displayName &&
      other.phone == phone &&
      other.avatarLocalPath == avatarLocalPath &&
      other.businessName == businessName &&
      other.logoLocalPath == logoLocalPath &&
      other.industry == industry &&
      other.taxCode == taxCode &&
      other.address == address &&
      other.bankAccountMasked == bankAccountMasked &&
      other.publicSlug == publicSlug;

  @override
  int get hashCode => Object.hash(
    displayName,
    phone,
    avatarLocalPath,
    businessName,
    logoLocalPath,
    industry,
    taxCode,
    address,
    bankAccountMasked,
    publicSlug,
  );
}
