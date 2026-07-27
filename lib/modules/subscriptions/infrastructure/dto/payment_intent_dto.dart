import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/dto/payment_link_dto.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/dto/plan_dto.dart';

part 'payment_intent_dto.freezed.dart';
part 'payment_intent_dto.g.dart';

/// Wire shape của một lượt thanh toán MoMo — khớp `PaymentIntentResponse`
/// backend. `status` giữ nguyên dạng chuỗi thô, chuyển sang enum domain ở
/// mapper qua `paymentIntentStatusFromWire`. `amount` dùng lại
/// [decimalFromJson] khai ở `plan_dto.dart`.
@freezed
abstract class PaymentIntentDto with _$PaymentIntentDto {
  const factory PaymentIntentDto({
    required String id,
    @JsonKey(name: 'subscription_id') required String subscriptionId,
    @JsonKey(name: 'plan_id') required String planId,
    required String provider,
    required String status,
    @JsonKey(fromJson: decimalFromJson) required double amount,
    required String currency,
    @JsonKey(name: 'payment_link') required PaymentLinkDto paymentLink,
    @JsonKey(name: 'provider_reference') String? providerReference,
    @JsonKey(name: 'paid_at') String? paidAt,
    @JsonKey(name: 'expires_at') required String expiresAt,
    @JsonKey(name: 'failure_reason') String? failureReason,
  }) = _PaymentIntentDto;

  factory PaymentIntentDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentIntentDtoFromJson(json);
}
