import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/payment_method.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/line_item_dto.dart';

part 'payment_record_dto.freezed.dart';
part 'payment_record_dto.g.dart';

/// Wire shape of a recorded payment as returned by `GET /invoices/{id}/payments`
/// — matches the backend `PaymentRecordResponse`.
@freezed
abstract class PaymentRecordDto with _$PaymentRecordDto {
  const factory PaymentRecordDto({
    required String id,
    @JsonKey(name: 'invoice_id') required String invoiceId,
    @JsonKey(fromJson: decimalFromJson) required double amount,
    @JsonKey(name: 'payment_date') required String paymentDate,
    @JsonKey(name: 'payment_method') required PaymentMethod paymentMethod,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'reference_note') String? referenceNote,
  }) = _PaymentRecordDto;

  factory PaymentRecordDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentRecordDtoFromJson(json);
}
