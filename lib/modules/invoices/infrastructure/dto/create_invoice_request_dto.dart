import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_invoice_request_dto.freezed.dart';
part 'create_invoice_request_dto.g.dart';

/// One line item as sent in a create/update request body. `amount` is computed
/// server-side from `quantity * unit_price`, so it is never sent.
@freezed
abstract class LineItemInputDto with _$LineItemInputDto {
  const factory LineItemInputDto({
    required String description,
    required double quantity,
    @JsonKey(name: 'unit_price') required double unitPrice,
    @JsonKey(name: 'sort_order', includeIfNull: false) int? sortOrder,
  }) = _LineItemInputDto;

  factory LineItemInputDto.fromJson(Map<String, dynamic> json) =>
      _$LineItemInputDtoFromJson(json);
}

/// Request body for `POST /invoices`. The invoice always starts in `draft`, so
/// no status is sent. Null fields are omitted. The backend requires
/// `contract_id` OR `deal_id`, and at least one line item (or a `subtotal`) —
/// enforced client-side before submit.
@freezed
abstract class CreateInvoiceRequestDto with _$CreateInvoiceRequestDto {
  const factory CreateInvoiceRequestDto({
    @JsonKey(name: 'client_id') required String clientId,
    @JsonKey(name: 'due_date') required String dueDate,
    @JsonKey(name: 'contract_id', includeIfNull: false) String? contractId,
    @JsonKey(name: 'deal_id', includeIfNull: false) String? dealId,
    @JsonKey(name: 'issue_date', includeIfNull: false) String? issueDate,
    @JsonKey(includeIfNull: false) String? currency,
    @JsonKey(includeIfNull: false) double? subtotal,
    @JsonKey(name: 'tax_rate', includeIfNull: false) double? taxRate,
    @JsonKey(includeIfNull: false) String? notes,
    @JsonKey(name: 'line_items', includeIfNull: false)
    List<LineItemInputDto>? lineItems,
  }) = _CreateInvoiceRequestDto;

  factory CreateInvoiceRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateInvoiceRequestDtoFromJson(json);
}
