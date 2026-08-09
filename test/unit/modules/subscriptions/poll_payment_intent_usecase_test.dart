import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/subscriptions/application/usecases/poll_payment_intent_usecase.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/payment_intent.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/plan.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/subscription.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/billing_period.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/payment_intent_status.dart';

/// Repo giả trả về các [PaymentIntent] đã kịch bản sẵn THEO THỨ TỰ cho các
/// lần gọi [getPaymentIntent] liên tiếp — phần tử cuối cùng được lặp lại nếu
/// gọi nhiều hơn độ dài danh sách (dùng cho kịch bản "luôn pending").
class _ScriptedRepository implements SubscriptionsRepository {
  _ScriptedRepository(this._responses);

  final List<PaymentIntent> _responses;
  int callCount = 0;

  @override
  Future<PaymentIntent> getPaymentIntent(String id) async {
    final index = callCount < _responses.length
        ? callCount
        : _responses.length - 1;
    callCount++;
    return _responses[index];
  }

  @override
  Future<List<Plan>> listPlans() => throw UnimplementedError();

  @override
  Future<Subscription> getMySubscription() => throw UnimplementedError();

  @override
  Future<PaymentIntent> createCheckout({
    required String planId,
    BillingPeriod billingPeriod = BillingPeriod.monthly,
    String? returnUrl,
  }) => throw UnimplementedError();

  @override
  Future<Subscription> cancelSubscription() => throw UnimplementedError();

  @override
  Future<PaymentIntent> cancelPaymentIntent(String id) =>
      throw UnimplementedError();
}

PaymentIntent _intent({
  required PaymentIntentStatus status,
  required DateTime expiresAt,
}) => PaymentIntent(
  id: 'pi-1',
  subscriptionId: 'sub-1',
  planId: 'plan-1',
  provider: 'momo',
  status: status,
  amount: 149000,
  currency: 'VND',
  paymentLink: const PaymentLink(type: 'checkout_url'),
  expiresAt: expiresAt,
);

void main() {
  final fixedNow = DateTime.utc(2026, 7, 27, 10);

  test('stops after the first item when it is already settled', () async {
    final repo = _ScriptedRepository([
      _intent(
        status: PaymentIntentStatus.succeeded,
        expiresAt: fixedNow.add(const Duration(minutes: 10)),
      ),
    ]);
    final useCase = PollPaymentIntentUseCase(repo, () => fixedNow);

    final results = await useCase('pi-1').toList();

    expect(results, hasLength(1));
    expect(results.single.status, PaymentIntentStatus.succeeded);
    expect(repo.callCount, 1);
  });

  test(
    'stops without another call once the fixed clock is already past expiresAt',
    () async {
      final repo = _ScriptedRepository([
        _intent(
          status: PaymentIntentStatus.pending,
          expiresAt: fixedNow.subtract(const Duration(minutes: 1)),
        ),
      ]);
      final useCase = PollPaymentIntentUseCase(repo, () => fixedNow);

      final results = await useCase('pi-1').toList();

      expect(results, hasLength(1));
      expect(results.single.status, PaymentIntentStatus.pending);
      expect(repo.callCount, 1);
    },
  );

  test(
    'never loops forever — hard cap of exactly 30 attempts when always pending',
    () {
      final repo = _ScriptedRepository([
        _intent(
          status: PaymentIntentStatus.pending,
          // Far in the future — the loop must stop on the attempt cap, not
          // on expiry.
          expiresAt: fixedNow.add(const Duration(days: 1)),
        ),
      ]);
      final useCase = PollPaymentIntentUseCase(repo, () => fixedNow);

      fakeAsync((async) {
        final results = <PaymentIntent>[];
        var done = false;
        useCase('pi-1').listen(results.add, onDone: () => done = true);

        // Worst-case wall time is 5 attempts * 2s + 25 attempts * 5s = 135s.
        // Elapse well past that without waiting for it in real time.
        async.elapse(const Duration(minutes: 5));

        expect(done, isTrue);
        expect(repo.callCount, 30);
        expect(results, hasLength(30));
        expect(
          results.every((i) => i.status == PaymentIntentStatus.pending),
          isTrue,
        );
      });
    },
  );
}
