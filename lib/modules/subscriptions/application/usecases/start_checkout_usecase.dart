import 'package:solodesk_mobile/modules/subscriptions/domain/entities/payment_intent.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/billing_period.dart';

/// Khởi tạo một lượt thanh toán MoMo cho gói [planId] theo kỳ
/// [billingPeriod] (mặc định theo tháng — default param để chữ ký cũ và các
/// fake hiện có không vỡ).
class StartCheckoutUseCase {
  const StartCheckoutUseCase(this._repository);

  final SubscriptionsRepository _repository;

  Future<PaymentIntent> call({
    required String planId,
    BillingPeriod billingPeriod = BillingPeriod.monthly,
    String? returnUrl,
  }) => _repository.createCheckout(
    planId: planId,
    billingPeriod: billingPeriod,
    returnUrl: returnUrl,
  );
}
