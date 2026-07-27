import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/subscription_status.dart';

part 'subscription.freezed.dart';

/// Gói đăng ký hiện tại của người dùng. Pure domain entity — mirrors the
/// backend `SubscriptionResponse` contract (`GET /subscriptions/me`).
@freezed
abstract class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String userId,
    required String planId,
    required String planName,
    required String planSlug,
    required SubscriptionStatus status,
    required DateTime currentPeriodStart,
    required DateTime currentPeriodEnd,
    required bool cancelAtPeriodEnd,
  }) = _Subscription;
}

extension SubscriptionX on Subscription {
  /// Gia hạn sẽ được thực hiện ở cuối kỳ trừ khi đã đặt huỷ.
  bool get willRenew => !cancelAtPeriodEnd;

  /// Có thể yêu cầu huỷ gia hạn khi gói còn hoạt động và chưa đặt huỷ.
  bool get canCancel =>
      status == SubscriptionStatus.active && !cancelAtPeriodEnd;
}
