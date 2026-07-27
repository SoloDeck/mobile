import 'package:solodesk_mobile/modules/subscriptions/domain/entities/payment_intent.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/repositories/subscriptions_repository.dart';

/// Khởi tạo một lượt thanh toán MoMo cho gói [planId].
class StartCheckoutUseCase {
  const StartCheckoutUseCase(this._repository);

  final SubscriptionsRepository _repository;

  Future<PaymentIntent> call({required String planId, String? returnUrl}) =>
      _repository.createCheckout(planId: planId, returnUrl: returnUrl);
}
