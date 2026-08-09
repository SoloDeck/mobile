import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/core/services/url_opener.dart';
import 'package:solodesk_mobile/core/time/app_clock.dart';
import 'package:solodesk_mobile/modules/subscriptions/application/services/payment_link_launcher.dart';
import 'package:solodesk_mobile/modules/subscriptions/application/services/payment_result_deep_link.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/payment_intent.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/plan.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/subscription.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/billing_period.dart';
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

  /// `returnUrl` của lần gọi [createCheckout] gần nhất — phải là deep link đã
  /// đăng ký, xem [paymentResultDeepLink].
  String? capturedReturnUrl;

  /// Kỳ thanh toán controller truyền xuống ở lần gọi gần nhất.
  BillingPeriod? capturedBillingPeriod;

  /// Đếm số lần backend bị hỏi trạng thái, để khẳng định deep link lúc `idle`
  /// KHÔNG gọi gì cả.
  int getPaymentIntentCallCount = 0;

  @override
  Future<PaymentIntent> createCheckout({
    required String planId,
    BillingPeriod billingPeriod = BillingPeriod.monthly,
    String? returnUrl,
  }) async {
    capturedReturnUrl = returnUrl;
    capturedBillingPeriod = billingPeriod;
    return _createdIntent;
  }

  @override
  Future<PaymentIntent> getPaymentIntent(String id) async {
    getPaymentIntentCallCount++;
    return _polledIntent;
  }

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

/// Trả về các [PaymentIntent] đã kịch bản sẵn THEO THỨ TỰ cho các lần gọi
/// [getPaymentIntent] liên tiếp — phần tử cuối được lặp lại nếu gọi quá độ
/// dài danh sách (giống bản trong `poll_payment_intent_usecase_test.dart`,
/// thêm `createCheckout` để chạy được trọn luồng của controller).
///
/// Dùng cho các kịch bản deep link: lần gọi ĐẦU là của vòng poll nền (trả về
/// `pending` để nó ngồi chờ hết 2s backoff), lần gọi SAU là của deep link.
class _ScriptedRepository implements SubscriptionsRepository {
  _ScriptedRepository(this._createdIntent, this._responses);

  final PaymentIntent _createdIntent;
  final List<PaymentIntent> _responses;
  int callCount = 0;

  @override
  Future<PaymentIntent> createCheckout({
    required String planId,
    BillingPeriod billingPeriod = BillingPeriod.monthly,
    String? returnUrl,
  }) async => _createdIntent;

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

/// [deepLinkStream] LUÔN được ghi đè, kể cả khi test không quan tâm: `build()`
/// của controller nghe [paymentResultDeepLinkStreamProvider], mà bản thật lại
/// dựng `AppLinksDeepLinkService` — một plugin nền tảng không tồn tại trong
/// `flutter test` (`MissingPluginException`).
ProviderContainer _containerFor(
  _RecordingUrlOpener opener, {
  SubscriptionsRepository? repository,
  Stream<Uri>? deepLinkStream,
}) {
  final repo =
      repository ??
      _FakeSubscriptionsRepository(
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
      paymentResultDeepLinkStreamProvider.overrideWith(
        (ref) => deepLinkStream ?? const Stream<Uri>.empty(),
      ),
    ],
  );
}

void main() {
  test(
    'opens the web payUrl (url) first and stops there when it works',
    () async {
      final opener = _RecordingUrlOpener([true]);
      final container = _containerFor(opener);
      addTearDown(container.dispose);

      await container
          .read(checkoutControllerProvider.notifier)
          .startCheckout('plan-2');

      expect(opener.calls, [_url]);
      final state = container.read(checkoutControllerProvider);
      expect(state.needsQr, isFalse);
      expect(state.step, CheckoutStep.succeeded);
    },
  );

  test('falls back to the deeplink when the payUrl does not open', () async {
    final opener = _RecordingUrlOpener([false, true]);
    final container = _containerFor(opener);
    addTearDown(container.dispose);

    await container
        .read(checkoutControllerProvider.notifier)
        .startCheckout('plan-2');

    expect(opener.calls, [_url, _instructions]);
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

      // Exactly two attempts — url then instructions — never a third for
      // the QR code (it is only ever displayed, not "opened").
      expect(opener.calls, [_url, _instructions]);
      final state = container.read(checkoutControllerProvider);
      expect(state.needsQr, isTrue);
    },
  );

  test('defaults billingPeriod to monthly when the caller omits it', () async {
    final repo = _FakeSubscriptionsRepository(
      _intentWith(),
      _intentWith(status: PaymentIntentStatus.succeeded),
    );
    final container = _containerFor(
      _RecordingUrlOpener([true]),
      repository: repo,
    );
    addTearDown(container.dispose);

    await container
        .read(checkoutControllerProvider.notifier)
        .startCheckout('plan-2');

    expect(repo.capturedBillingPeriod, BillingPeriod.monthly);
  });

  test('passes billingPeriod yearly through to the repository', () async {
    final repo = _FakeSubscriptionsRepository(
      _intentWith(),
      _intentWith(status: PaymentIntentStatus.succeeded),
    );
    final container = _containerFor(
      _RecordingUrlOpener([true]),
      repository: repo,
    );
    addTearDown(container.dispose);

    await container
        .read(checkoutControllerProvider.notifier)
        .startCheckout('plan-2', billingPeriod: BillingPeriod.yearly);

    expect(repo.capturedBillingPeriod, BillingPeriod.yearly);
  });

  test('sends the registered deep link as returnUrl to the backend', () async {
    final repo = _FakeSubscriptionsRepository(
      _intentWith(),
      _intentWith(status: PaymentIntentStatus.succeeded),
    );
    final container = _containerFor(
      _RecordingUrlOpener([true]),
      repository: repo,
    );
    addTearDown(container.dispose);

    await container
        .read(checkoutControllerProvider.notifier)
        .startCheckout('plan-2');

    // Chuỗi LITERAL này là hợp đồng với backend và với scheme+host đã khai
    // báo ở AndroidManifest.xml / Info.plist — đổi một chỗ là hỏng cả luồng.
    expect(repo.capturedReturnUrl, 'solodesk://payment-result');
    expect(paymentResultDeepLink, 'solodesk://payment-result');
  });

  test(
    'deep link settles the checkout before the poll backoff elapses',
    () {
      final links = StreamController<Uri>.broadcast();
      addTearDown(links.close);
      // Lần poll đầu vẫn pending -> vòng poll ngồi chờ 2s; deep link tới
      // trước và lấy được trạng thái succeeded ở lần gọi thứ hai.
      final repo = _ScriptedRepository(_intentWith(), [
        _intentWith(),
        _intentWith(status: PaymentIntentStatus.succeeded),
      ]);
      final container = _containerFor(
        _RecordingUrlOpener([true]),
        repository: repo,
        deepLinkStream: links.stream,
      );
      addTearDown(container.dispose);

      fakeAsync((async) {
        container.listen(checkoutControllerProvider, (_, _) {});
        unawaited(
          container
              .read(checkoutControllerProvider.notifier)
              .startCheckout('plan-2'),
        );
        async.flushMicrotasks();
        expect(
          container.read(checkoutControllerProvider).step,
          CheckoutStep.awaitingPayment,
        );
        expect(repo.callCount, 1);

        links.add(Uri.parse(paymentResultDeepLink));
        async.flushMicrotasks();

        // KHÔNG elapse 2s backoff của vòng poll — nếu bước này đã succeeded
        // thì đúng là deep link đã rút ngắn thời gian chờ.
        expect(
          container.read(checkoutControllerProvider).step,
          CheckoutStep.succeeded,
        );
        expect(repo.callCount, 2);
      });
    },
  );

  test(
    'deep link on a cancelled payment fails the checkout, and the '
    'background poll does not later overwrite that result',
    () {
      final links = StreamController<Uri>.broadcast();
      addTearDown(links.close);
      final repo = _ScriptedRepository(_intentWith(), [
        _intentWith(),
        _intentWith(status: PaymentIntentStatus.cancelled),
      ]);
      final container = _containerFor(
        _RecordingUrlOpener([true]),
        repository: repo,
        deepLinkStream: links.stream,
      );
      addTearDown(container.dispose);

      fakeAsync((async) {
        container.listen(checkoutControllerProvider, (_, _) {});
        unawaited(
          container
              .read(checkoutControllerProvider.notifier)
              .startCheckout('plan-2'),
        );
        async.flushMicrotasks();
        expect(
          container.read(checkoutControllerProvider).step,
          CheckoutStep.awaitingPayment,
        );

        links.add(Uri.parse(paymentResultDeepLink));
        async.flushMicrotasks();

        final state = container.read(checkoutControllerProvider);
        expect(state.step, CheckoutStep.failed);
        expect(state.error, 'Thanh toán đã bị huỷ hoặc thất bại');
        expect(repo.callCount, 2);

        // Vòng poll nền vẫn đang ngồi chờ hết 2s backoff của lượt đầu (pending)
        // khi deep link tới. Cho thời gian trôi qua để nó tỉnh dậy và gọi lại
        // getPaymentIntent (lần thứ 3, vẫn trả "cancelled" theo kịch bản) —
        // kết quả từ deep link phải đứng vững, không bị nhánh "hết hạn" của
        // vòng poll ghi đè lên.
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();

        final stateAfterPollTick = container.read(checkoutControllerProvider);
        expect(stateAfterPollTick.step, CheckoutStep.failed);
        expect(
          stateAfterPollTick.error,
          'Thanh toán đã bị huỷ hoặc thất bại',
          reason:
              'the background poll loop must not clobber a result already '
              'settled by the deep link handler',
        );
      });
    },
  );

  test('deep link with no checkout in flight is a no-op', () {
    final links = StreamController<Uri>.broadcast();
    addTearDown(links.close);
    final repo = _FakeSubscriptionsRepository(
      _intentWith(),
      _intentWith(status: PaymentIntentStatus.succeeded),
    );
    final container = _containerFor(
      _RecordingUrlOpener([true]),
      repository: repo,
      deepLinkStream: links.stream,
    );
    addTearDown(container.dispose);

    fakeAsync((async) {
      // Đọc một lần để controller được dựng -> `ref.listen` deep link chạy.
      container.listen(checkoutControllerProvider, (_, _) {});
      expect(container.read(checkoutControllerProvider).step, CheckoutStep.idle);

      links.add(Uri.parse(paymentResultDeepLink));
      async.flushMicrotasks();

      expect(container.read(checkoutControllerProvider).step, CheckoutStep.idle);
      expect(repo.getPaymentIntentCallCount, 0);
    });
  });
}
