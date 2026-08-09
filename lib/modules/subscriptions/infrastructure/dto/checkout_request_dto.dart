import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_request_dto.freezed.dart';
part 'checkout_request_dto.g.dart';

/// Request body cho `POST /subscriptions/checkout`. `provider` luôn là
/// `'momo'` — giá trị duy nhất backend hỗ trợ. `returnUrl` bị lược khỏi JSON
/// khi null. `billingPeriod` là `'monthly' | 'yearly'` — trùng default
/// `'monthly'` với backend để client cũ không gửi field vẫn chạy đúng.
@freezed
abstract class CheckoutRequestDto with _$CheckoutRequestDto {
  const factory CheckoutRequestDto({
    @JsonKey(name: 'plan_id') required String planId,
    @Default('momo') String provider,
    @JsonKey(name: 'billing_period') @Default('monthly') String billingPeriod,
    @JsonKey(name: 'return_url', includeIfNull: false) String? returnUrl,
  }) = _CheckoutRequestDto;

  factory CheckoutRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CheckoutRequestDtoFromJson(json);
}
