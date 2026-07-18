import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/create_invoice_request_dto.dart';

part 'update_invoice_request_dto.freezed.dart';
part 'update_invoice_request_dto.g.dart';

/// Request body for `PATCH /invoices/{id}` (draft only). Only the supplied
/// fields are sent; when `line_items` is present it **replaces** the whole list
/// (the backend does not merge).
@freezed
abstract class UpdateInvoiceRequestDto with _$UpdateInvoiceRequestDto {
  const factory UpdateInvoiceRequestDto({
    @JsonKey(includeIfNull: false) double? subtotal,
    @JsonKey(name: 'due_date', includeIfNull: false) String? dueDate,
    @JsonKey(name: 'tax_rate', includeIfNull: false) double? taxRate,
    @JsonKey(includeIfNull: false) String? notes,
    @JsonKey(name: 'line_items', includeIfNull: false)
    List<LineItemInputDto>? lineItems,
  }) = _UpdateInvoiceRequestDto;

  factory UpdateInvoiceRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateInvoiceRequestDtoFromJson(json);
}
