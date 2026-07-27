import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_dto.freezed.dart';
part 'subscription_dto.g.dart';

/// Wire shape của gói đăng ký hiện tại — khớp `SubscriptionResponse` backend
/// (`GET /subscriptions/me`). `status` giữ nguyên dạng chuỗi thô, chuyển sang
/// enum domain ở mapper qua `subscriptionStatusFromWire`.
@freezed
abstract class SubscriptionDto with _$SubscriptionDto {
  const factory SubscriptionDto({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'plan_id') required String planId,
    @JsonKey(name: 'plan_name') required String planName,
    @JsonKey(name: 'plan_slug') required String planSlug,
    required String status,
    @JsonKey(name: 'current_period_start') required String currentPeriodStart,
    @JsonKey(name: 'current_period_end') required String currentPeriodEnd,
    @JsonKey(name: 'cancel_at_period_end') required bool cancelAtPeriodEnd,
  }) = _SubscriptionDto;

  factory SubscriptionDto.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionDtoFromJson(json);
}
