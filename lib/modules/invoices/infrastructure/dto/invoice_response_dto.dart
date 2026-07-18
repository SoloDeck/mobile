import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/line_item_dto.dart';

part 'invoice_response_dto.freezed.dart';
part 'invoice_response_dto.g.dart';

/// Wire shape of an invoice as returned by `GET /invoices` and the single-invoice
/// endpoints. Money fields arrive as JSON numbers and are parsed via
/// [decimalFromJson]; date/date-time fields stay as strings and are parsed in
/// the mapper.
@freezed
abstract class InvoiceResponseDto with _$InvoiceResponseDto {
  const factory InvoiceResponseDto({
    required String id,
    @JsonKey(name: 'owner_user_id') required String ownerUserId,
    @JsonKey(name: 'client_id') required String clientId,
    @JsonKey(name: 'invoice_number') required String invoiceNumber,
    required InvoiceStatus status,
    @JsonKey(name: 'issue_date') required String issueDate,
    @JsonKey(name: 'due_date') required String dueDate,
    @JsonKey(fromJson: decimalFromJson) required double total,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'client_name') String? clientName,
    @JsonKey(name: 'contract_id') String? contractId,
    @JsonKey(name: 'deal_id') String? dealId,
    @Default('VND') String currency,
    @JsonKey(fromJson: decimalFromJson) @Default(0) double subtotal,
    @JsonKey(name: 'tax_rate', fromJson: decimalFromJson)
    @Default(0)
    double taxRate,
    @JsonKey(name: 'tax_amount', fromJson: decimalFromJson)
    @Default(0)
    double taxAmount,
    @JsonKey(name: 'amount_paid', fromJson: decimalFromJson)
    @Default(0)
    double amountPaid,
    @JsonKey(name: 'amount_outstanding', fromJson: decimalFromJson)
    @Default(0)
    double amountOutstanding,
    String? notes,
    @JsonKey(name: 'line_items')
    @Default(<LineItemDto>[])
    List<LineItemDto> lineItems,
    @JsonKey(name: 'sent_at') String? sentAt,
    @JsonKey(name: 'voided_at') String? voidedAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _InvoiceResponseDto;

  factory InvoiceResponseDto.fromJson(Map<String, dynamic> json) =>
      _$InvoiceResponseDtoFromJson(json);
}
