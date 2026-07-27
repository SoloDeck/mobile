import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_request_dto.freezed.dart';
part 'checkout_request_dto.g.dart';

/// Request body cho `POST /subscriptions/checkout`. `provider` luôn là
/// `'momo'` — giá trị duy nhất backend hỗ trợ. `returnUrl` bị lược khỏi JSON
/// khi null.
@freezed
abstract class CheckoutRequestDto with _$CheckoutRequestDto {
  const factory CheckoutRequestDto({
    @JsonKey(name: 'plan_id') required String planId,
    @Default('momo') String provider,
    @JsonKey(name: 'return_url', includeIfNull: false) String? returnUrl,
  }) = _CheckoutRequestDto;

  factory CheckoutRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CheckoutRequestDtoFromJson(json);
}
