import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/core/services/url_opener.dart';
import 'package:solodesk_mobile/core/time/app_clock.dart';
import 'package:solodesk_mobile/modules/subscriptions/application/services/payment_link_launcher.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/payment_intent.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/plan.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/subscription.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/payment_intent_status.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/repository/subscriptions_repository_impl.dart';
import 'package:solodesk_mobile/modules/subscriptions/presentation/controllers/checkout_controller.dart';

const _instructions = 'momo://app?action=payWithApp&sid=abc123';
const _url = 'https://payment.momo.vn/v2/gateway/pay?s=abc123';
const _qrCodeUrl = 'https://payment.momo.vn/qr/abc123.png';

final _fixedNow = DateTime.utc(2026, 7, 27, 10);

/// Cả `instructions` lẫn `url` đều có mặt trên link này — dùng chung cho cả
/// ba kịch bản, chỉ [_RecordingUrlOpener] thay đổi kết quả mở được hay không.
const _link = PaymentLink(
  type: 'checkout_url',
  url: _url,
  qrCodeUrl: _qrCodeUrl,
  instructions: _instructions,
);

/// Ghi lại URL của mỗi lần gọi [open] theo đúng thứ tự, trả kết quả theo
/// kịch bản đã cấu hình sẵn (một phần tử `bool` cho mỗi lần gọi).
class _RecordingUrlOpener implements UrlOpener {
  _RecordingUrlOpener(this._results);

  final List<bool> _results;
  final List<String> calls = [];

  @override
  Future<bool> open(String rawUrl) async {
    calls.add(rawUrl);
    return _results[calls.length - 1];
  }
}

/// `createCheckout` trả về intent vừa mở link; `getPaymentIntent` trả về
/// intent đã "succeeded" ngay lần poll đầu — đủ để luồng thanh toán hoàn tất
/// mà không cần chờ thật (`PollPaymentIntentUseCase` dừng ngay khi settled).
class _FakeSubscriptionsRepository implements SubscriptionsRepository {
  _FakeSubscriptionsRepository(this._createdIntent, this._polledIntent);

  final PaymentIntent _createdIntent;
  final PaymentIntent _polledIntent;

  @override
  Future<PaymentIntent> createCheckout({
    required String planId,
    String? returnUrl,
  }) async => _createdIntent;

  @override
  Future<PaymentIntent> getPaymentIntent(String id) async => _polledIntent;

  @override
  Future<List<Plan>> listPlans() => throw UnimplementedError();

  @override
  Future<Subscription> getMySubscription() => throw UnimplementedError();

  @override
  Future<Subscription> cancelSubscription() => throw UnimplementedError();

  @override
  Future<PaymentIntent> cancelPaymentIntent(String id) =>
      throw UnimplementedError();
}

PaymentIntent _intentWith({
  PaymentIntentStatus status = PaymentIntentStatus.pending,
}) => PaymentIntent(
  id: 'pi-1',
  subscriptionId: 'sub-1',
  planId: 'plan-2',
  provider: 'momo',
  status: status,
  amount: 149000,
  currency: 'VND',
  paymentLink: _link,
  expiresAt: _fixedNow.add(const Duration(minutes: 15)),
);

ProviderContainer _containerFor(_RecordingUrlOpener opener) {
  final repo = _FakeSubscriptionsRepository(
    _intentWith(),
    _intentWith(status: PaymentIntentStatus.succeeded),
  );
  return ProviderContainer(
    overrides: [
      subscriptionsRepositoryProvider.overrideWithValue(repo),
      paymentLinkLauncherProvider.overrideWithValue(
        PaymentLinkLauncher(opener),
      ),
      appClockProvider.overrideWithValue(() => _fixedNow),
    ],
  );
}

void main() {
  test(
    'opens the deeplink (instructions) first and stops there when it works',
    () async {
      final opener = _RecordingUrlOpener([true]);
      final container = _containerFor(opener);
      addTearDown(container.dispose);

      await container
          .read(checkoutControllerProvider.notifier)
          .startCheckout('plan-2');

      expect(opener.calls, [_instructions]);
      final state = container.read(checkoutControllerProvider);
      expect(state.needsQr, isFalse);
      expect(state.step, CheckoutStep.succeeded);
    },
  );

  test('falls back to url when the deeplink does not open', () async {
    final opener = _RecordingUrlOpener([false, true]);
    final container = _containerFor(opener);
    addTearDown(container.dispose);

    await container
        .read(checkoutControllerProvider.notifier)
        .startCheckout('plan-2');

    expect(opener.calls, [_instructions, _url]);
    final state = container.read(checkoutControllerProvider);
    expect(state.needsQr, isFalse);
    expect(state.step, CheckoutStep.succeeded);
  });

  test(
    'falls back to the QR code without a third open() call when neither link opens',
    () async {
      final opener = _RecordingUrlOpener([false, false]);
      final container = _containerFor(opener);
      addTearDown(container.dispose);

      await container
          .read(checkoutControllerProvider.notifier)
          .startCheckout('plan-2');

      // Exactly two attempts — instructions then url — never a third for
      // the QR code (it is only ever displayed, not "opened").
      expect(opener.calls, [_instructions, _url]);
      final state = container.read(checkoutControllerProvider);
      expect(state.needsQr, isTrue);
    },
  );
}
