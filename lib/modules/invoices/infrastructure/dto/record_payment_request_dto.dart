import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/payment_method.dart';

part 'record_payment_request_dto.freezed.dart';
part 'record_payment_request_dto.g.dart';

/// Request body for `POST /invoices/{id}/payments`. `amount` must not exceed the
/// invoice's outstanding balance — enforced client-side and by the backend
/// (400).
@freezed
abstract class RecordPaymentRequestDto with _$RecordPaymentRequestDto {
  const factory RecordPaymentRequestDto({
    required double amount,
    @JsonKey(name: 'payment_date') required String paymentDate,
    @JsonKey(name: 'payment_method', includeIfNull: false)
    PaymentMethod? paymentMethod,
    @JsonKey(name: 'reference_note', includeIfNull: false)
    String? referenceNote,
  }) = _RecordPaymentRequestDto;

  factory RecordPaymentRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RecordPaymentRequestDtoFromJson(json);
}
