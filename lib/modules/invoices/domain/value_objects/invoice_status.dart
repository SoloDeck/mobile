import 'package:freezed_annotation/freezed_annotation.dart';

/// Lifecycle status of an invoice (hóa đơn). Mirrors the backend `InvoiceStatus`
/// enum. `void` is a Dart reserved word, so the terminal "cancelled" status is
/// named [voided] while keeping the `void` wire value.
enum InvoiceStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('sent')
  sent,
  @JsonValue('partially_paid')
  partiallyPaid,
  @JsonValue('paid')
  paid,
  @JsonValue('overdue')
  overdue,
  @JsonValue('void')
  voided,
}

extension InvoiceStatusX on InvoiceStatus {
  /// Snake-case value the backend expects (matches the `@JsonValue` strings),
  /// used for query parameters and drift row storage.
  String get wireValue => switch (this) {
    InvoiceStatus.draft => 'draft',
    InvoiceStatus.sent => 'sent',
    InvoiceStatus.partiallyPaid => 'partially_paid',
    InvoiceStatus.paid => 'paid',
    InvoiceStatus.overdue => 'overdue',
    InvoiceStatus.voided => 'void',
  };

  String get label => switch (this) {
    InvoiceStatus.draft => 'Nháp',
    InvoiceStatus.sent => 'Đã gửi',
    InvoiceStatus.partiallyPaid => 'Thanh toán một phần',
    InvoiceStatus.paid => 'Đã thanh toán',
    InvoiceStatus.overdue => 'Quá hạn',
    InvoiceStatus.voided => 'Đã huỷ',
  };

  /// A draft can be edited and sent; nothing else can.
  bool get isDraft => this == InvoiceStatus.draft;

  /// Terminal states expose no further actions.
  bool get isTerminal =>
      this == InvoiceStatus.paid || this == InvoiceStatus.voided;

  /// Voiding is blocked once any payment has been recorded (mirrors the backend
  /// rule) or the invoice is already void.
  bool get canVoid =>
      this != InvoiceStatus.paid &&
      this != InvoiceStatus.partiallyPaid &&
      this != InvoiceStatus.voided;

  /// Payments can be recorded only against a live, sent invoice with a balance.
  bool get canRecordPayment =>
      this == InvoiceStatus.sent ||
      this == InvoiceStatus.partiallyPaid ||
      this == InvoiceStatus.overdue;
}

InvoiceStatus invoiceStatusFromWire(String value) => switch (value) {
  'draft' => InvoiceStatus.draft,
  'sent' => InvoiceStatus.sent,
  'partially_paid' => InvoiceStatus.partiallyPaid,
  'paid' => InvoiceStatus.paid,
  'overdue' => InvoiceStatus.overdue,
  'void' => InvoiceStatus.voided,
  _ => throw ArgumentError.value(value, 'value', 'Unknown invoice status'),
};
