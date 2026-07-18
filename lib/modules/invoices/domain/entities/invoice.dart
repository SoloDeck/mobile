import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/payment_method.dart';

part 'invoice.freezed.dart';

/// A single billable line on an invoice. Pure domain entity — mirrors the
/// backend `LineItemDTO`.
@freezed
abstract class LineItem with _$LineItem {
  const factory LineItem({
    required String description,
    required double quantity,
    required double unitPrice,
    required double amount,
    @Default(0) int sortOrder,
  }) = _LineItem;
}

/// One recorded payment against an invoice (append-only on the backend). Mirrors
/// `PaymentRecordResponse`.
@freezed
abstract class PaymentRecord with _$PaymentRecord {
  const factory PaymentRecord({
    required String id,
    required String invoiceId,
    required double amount,
    required DateTime paymentDate,
    required PaymentMethod paymentMethod,
    required DateTime createdAt,
    String? referenceNote,
  }) = _PaymentRecord;
}

/// An invoice (hóa đơn). Pure domain entity — fields mirror the backend
/// `InvoiceResponse` contract (`/invoices`).
@freezed
abstract class Invoice with _$Invoice {
  const factory Invoice({
    required String id,
    required String ownerUserId,
    required String clientId,
    required String invoiceNumber,
    required InvoiceStatus status,
    required DateTime issueDate,
    required DateTime dueDate,
    required double total,
    required DateTime createdAt,
    String? clientName,
    String? contractId,
    String? dealId,
    @Default('VND') String currency,
    @Default(0) double subtotal,
    @Default(0) double taxRate,
    @Default(0) double taxAmount,
    @Default(0) double amountPaid,
    @Default(0) double amountOutstanding,
    String? notes,
    @Default(<LineItem>[]) List<LineItem> lineItems,
    DateTime? sentAt,
    DateTime? voidedAt,
    DateTime? updatedAt,
  }) = _Invoice;
}

extension InvoiceX on Invoice {
  /// A draft may be edited and sent.
  bool get canEdit => status.isDraft;

  bool get canSend => status.isDraft;

  bool get canVoid => status.canVoid;

  /// Payment can be recorded while the invoice is live and still has a balance.
  bool get canRecordPayment => status.canRecordPayment && amountOutstanding > 0;

  /// Past the due date with money still owed — surfaced with a danger accent
  /// even when the backend has not yet flipped the status to `overdue`.
  bool get isOverdue =>
      status == InvoiceStatus.overdue ||
      (amountOutstanding > 0 &&
          !status.isTerminal &&
          dueDate.isBefore(DateTime.now()));
}
