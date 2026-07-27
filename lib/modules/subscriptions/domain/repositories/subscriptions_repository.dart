import 'package:solodesk_mobile/modules/subscriptions/domain/entities/payment_intent.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/plan.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/subscription.dart';

/// Contract for reading gói dịch vụ (plans) và quản lý thanh toán MoMo.
/// Implemented in `infrastructure/repository/subscriptions_repository_impl.dart`.
///
/// Module này KHÔNG cache Drift — danh sách gói, gói hiện tại và trạng thái
/// thanh toán đều cần dữ liệu tươi từ server (đặc biệt payment intent có TTL
/// 15 phút), nên mọi lệnh gọi luôn đi thẳng network.
abstract interface class SubscriptionsRepository {
  /// `GET /subscriptions/plans` — public, không cần đăng nhập.
  Future<List<Plan>> listPlans();

  /// `GET /subscriptions/me`.
  Future<Subscription> getMySubscription();

  /// `POST /subscriptions/checkout`. `provider` luôn là `'momo'` — giá trị
  /// duy nhất backend hỗ trợ. [returnUrl], nếu có, phải bắt đầu bằng
  /// `http://` hoặc `https://`.
  Future<PaymentIntent> createCheckout({
    required String planId,
    String? returnUrl,
  });

  /// `POST /subscriptions/cancel` — không có body, huỷ gia hạn ở cuối kỳ.
  Future<Subscription> cancelSubscription();

  /// `GET /payments/intents/{id}` — dùng để poll trạng thái sau khi mở link
  /// MoMo.
  Future<PaymentIntent> getPaymentIntent(String id);

  /// `POST /payments/intents/{id}/cancel`.
  Future<PaymentIntent> cancelPaymentIntent(String id);
}
