import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/payment_intent_status.dart';

part 'payment_intent.freezed.dart';

/// Điểm khởi tạo thanh toán MoMo do backend trả về.
///
/// LƯU Ý: `type` LUÔN LÀ `'checkout_url'` bất kể thực tế — KHÔNG BAO GIỜ
/// switch logic theo `type`. `instructions` mới chính là DEEPLINK MoMo cần
/// mở (không phải `url`!). Logic chọn thử [instructions] → [url] →
/// [qrCodeUrl] nằm ở `application/services/payment_link_launcher.dart`.
@freezed
abstract class PaymentLink with _$PaymentLink {
  const factory PaymentLink({
    required String type,
    String? url,
    String? qrCodeUrl,
    String? instructions,
  }) = _PaymentLink;
}

/// Một lượt thanh toán MoMo cho gói dịch vụ. Pure domain entity — mirrors the
/// backend `PaymentIntentResponse` contract. Hết hạn sau 15 phút kể từ khi
/// tạo (server tính, xem [expiresAt]).
@freezed
abstract class PaymentIntent with _$PaymentIntent {
  const factory PaymentIntent({
    required String id,
    required String subscriptionId,
    required String planId,
    required String provider,
    required PaymentIntentStatus status,
    required double amount,
    required String currency,
    required PaymentLink paymentLink,
    String? providerReference,
    DateTime? paidAt,
    required DateTime expiresAt,
    String? failureReason,
  }) = _PaymentIntent;
}

extension PaymentIntentX on PaymentIntent {
  /// Còn hiệu lực để mở link thanh toán hoặc tiếp tục poll trạng thái.
  bool get isActive => !status.isSettled;
}
