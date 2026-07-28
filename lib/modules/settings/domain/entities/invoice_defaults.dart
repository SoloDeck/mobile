import 'package:flutter/foundation.dart';

/// User's local defaults applied to new invoices/quotes (no backend sync yet).
@immutable
class InvoiceDefaults {
  const InvoiceDefaults({
    required this.vatPercent,
    required this.dueDays,
    required this.termsText,
  });

  final double vatPercent;
  final int dueDays;
  final String? termsText;

  /// Defaults applied before any persisted value is loaded.
  static const InvoiceDefaults defaults = InvoiceDefaults(
    vatPercent: 8,
    dueDays: 14,
    termsText: null,
  );

  InvoiceDefaults copyWith({
    double? vatPercent,
    int? dueDays,
    String? termsText,
  }) {
    return InvoiceDefaults(
      vatPercent: vatPercent ?? this.vatPercent,
      dueDays: dueDays ?? this.dueDays,
      termsText: termsText ?? this.termsText,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is InvoiceDefaults &&
      other.vatPercent == vatPercent &&
      other.dueDays == dueDays &&
      other.termsText == termsText;

  @override
  int get hashCode => Object.hash(vatPercent, dueDays, termsText);
}
