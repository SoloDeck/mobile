import 'package:solodesk_mobile/modules/subscriptions/domain/entities/payment_intent.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/payment_intent_status.dart';

/// Lặp lại việc kiểm tra trạng thái một payment intent sau khi người dùng đã
/// mở liên kết MoMo.
class PollPaymentIntentUseCase {
  const PollPaymentIntentUseCase(this._repository, this._clock);

  final SubscriptionsRepository _repository;
  final DateTime Function() _clock;

  /// Backoff 2 giây x 5 lần, sau đó 5 giây/lần. Dừng khi [isSettled] HOẶC đã
  /// quá `expiresAt`. KHÔNG lặp vô hạn — giới hạn cứng 30 lượt kiểm (đủ phủ
  /// vài phút, xa hơn TTL 15 phút của intent nhiều lần).
  Stream<PaymentIntent> call(String intentId) async* {
    var attempt = 0;
    while (attempt < 30) {
      final intent = await _repository.getPaymentIntent(intentId);
      yield intent;
      if (intent.status.isSettled) return;
      if (_clock().isAfter(intent.expiresAt)) return;
      final delay = attempt < 5
          ? const Duration(seconds: 2)
          : const Duration(seconds: 5);
      await Future<void>.delayed(delay);
      attempt++;
    }
  }
}
