import 'package:flutter/foundation.dart';

/// User's local notification toggle preferences (no backend sync yet).
@immutable
class NotificationPreferences {
  const NotificationPreferences({
    required this.invoiceDue,
    required this.quoteResponse,
    required this.weeklyEmailSummary,
  });

  final bool invoiceDue;
  final bool quoteResponse;
  final bool weeklyEmailSummary;

  /// Defaults applied before any persisted value is loaded.
  static const NotificationPreferences defaults = NotificationPreferences(
    invoiceDue: true,
    quoteResponse: true,
    weeklyEmailSummary: false,
  );

  NotificationPreferences copyWith({
    bool? invoiceDue,
    bool? quoteResponse,
    bool? weeklyEmailSummary,
  }) {
    return NotificationPreferences(
      invoiceDue: invoiceDue ?? this.invoiceDue,
      quoteResponse: quoteResponse ?? this.quoteResponse,
      weeklyEmailSummary: weeklyEmailSummary ?? this.weeklyEmailSummary,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is NotificationPreferences &&
      other.invoiceDue == invoiceDue &&
      other.quoteResponse == quoteResponse &&
      other.weeklyEmailSummary == weeklyEmailSummary;

  @override
  int get hashCode =>
      Object.hash(invoiceDue, quoteResponse, weeklyEmailSummary);
}
