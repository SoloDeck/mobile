import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/time/app_clock.dart';
import 'package:solodesk_mobile/modules/subscriptions/application/services/payment_link_launcher.dart';
import 'package:solodesk_mobile/modules/subscriptions/application/services/payment_result_deep_link.dart';
import 'package:solodesk_mobile/modules/subscriptions/application/usecases/cancel_subscription_usecase.dart';
import 'package:solodesk_mobile/modules/subscriptions/application/usecases/poll_payment_intent_usecase.dart';
import 'package:solodesk_mobile/modules/subscriptions/application/usecases/start_checkout_usecase.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/payment_intent.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/payment_intent_status.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/repository/subscriptions_repository_impl.dart';
import 'package:solodesk_mobile/modules/subscriptions/presentation/providers/subscriptions_provider.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

part 'checkout_controller.g.dart';

/// Trạng thái luồng thanh toán — hiện trên tấm sheet "MoMoCheckoutSheet" ở
/// `presentation/pages/plans_page.dart`.
enum CheckoutStep { idle, creatingIntent, awaitingPayment, succeeded, failed }

class CheckoutState {
  const CheckoutState({
    this.step = CheckoutStep.idle,
    this.intent,
    this.error,
    this.needsQr = false,
  });

  final CheckoutStep step;
  final PaymentIntent? intent;
  final String? error;

  /// True khi cả deeplink lẫn `url` đều không mở được — chỉ còn mã QR để
  /// hiển thị ngay trong sheet, xem [PaymentLinkLauncher].
  final bool needsQr;

  CheckoutState copyWith({
    CheckoutStep? step,
    PaymentIntent? intent,
    String? error,
    bool? needsQr,
  }) => CheckoutState(
    step: step ?? this.step,
    intent: intent ?? this.intent,
    error: error,
    needsQr: needsQr ?? this.needsQr,
  );
}

/// Điều khiển toàn bộ luồng nâng cấp gói: tạo payment intent, mở liên kết
/// MoMo, poll trạng thái tới khi thanh toán xong (hoặc hết hạn), và huỷ gia
/// hạn khi người dùng bấm huỷ.
@riverpod
class CheckoutController extends _$CheckoutController {
  @override
  CheckoutState build() {
    ref.listen(paymentResultDeepLinkStreamProvider, (_, next) {
      next.whenData((_) => _onPaymentResultDeepLink());
    });
    return const CheckoutState();
  }

  Future<void> startCheckout(String planId) async {
    state = state.copyWith(step: CheckoutStep.creatingIntent);
    try {
      final intent = await StartCheckoutUseCase(
        ref.read(subscriptionsRepositoryProvider),
      )(planId: planId, returnUrl: paymentResultDeepLink);
      state = state.copyWith(
        step: CheckoutStep.awaitingPayment,
        intent: intent,
      );
      final result = await ref
          .read(paymentLinkLauncherProvider)
          .open(intent.paymentLink);
      if (result == PaymentLinkResult.unavailable) {
        state = state.copyWith(
          step: CheckoutStep.failed,
          error: 'Không lấy được liên kết thanh toán',
        );
        return;
      }
      state = state.copyWith(needsQr: result == PaymentLinkResult.showQr);
      await _poll(intent.id);
    } on AppException catch (e) {
      state = state.copyWith(step: CheckoutStep.failed, error: e.message);
    }
  }

  Future<void> _poll(String intentId) async {
    final clock = ref.read(appClockProvider);
    final useCase = PollPaymentIntentUseCase(
      ref.read(subscriptionsRepositoryProvider),
      clock,
    );
    await for (final intent in useCase(intentId)) {
      // _onPaymentResultDeepLink có thể đã settle state ở giữa hai lượt poll
      // (nó gọi cùng getPaymentIntent, chỉ sớm hơn) — không ghi đè kết quả
      // đó bằng một nhánh khác (vd. "hết hạn" đè lên "đã huỷ").
      if (state.step != CheckoutStep.awaitingPayment) return;
      state = state.copyWith(intent: intent);
      if (intent.status == PaymentIntentStatus.succeeded) {
        state = state.copyWith(step: CheckoutStep.succeeded);
        ref.invalidate(mySubscriptionProvider);
        return;
      }
      if (intent.status.isSettled) {
        state = state.copyWith(
          step: CheckoutStep.failed,
          error: 'Phiên thanh toán đã hết hạn, thử lại',
        );
        return;
      }
    }
    // Stream đóng vì hết 30 lượt kiểm mà chưa settle -> coi như hết hạn.
    if (state.step == CheckoutStep.awaitingPayment) {
      state = state.copyWith(
        step: CheckoutStep.failed,
        error: 'Phiên thanh toán đã hết hạn, thử lại',
      );
    }
  }

  /// Gọi khi deep link solodesk://payment-result bắn về (cả khi thành công
  /// LẪN khi huỷ trên MoMo — MoMo redirect trình duyệt về CÙNG một link cho
  /// cả hai trường hợp). KHÔNG tin bất kỳ query param nào MoMo có thể/không
  /// đính kèm qua custom scheme — chỉ dùng làm tín hiệu "kiểm tra lại ngay",
  /// nguồn sự thật vẫn là backend qua getPaymentIntent (giống hệt [_poll]).
  /// KHÔNG cần huỷ vòng lặp [_poll] đang chạy nền: mỗi lượt lặp của [_poll]
  /// tự kiểm tra `state.step` trước khi ghi state, nên một khi hàm này đã
  /// chuyển sang `succeeded`/`failed` thì lượt poll tiếp theo sẽ thấy vậy và
  /// tự thoát thay vì ghi đè bằng thông báo khác (vd. "hết hạn" đè "đã huỷ").
  Future<void> _onPaymentResultDeepLink() async {
    if (state.step != CheckoutStep.awaitingPayment) return;
    final intentId = state.intent?.id;
    if (intentId == null) return;
    try {
      final intent = await ref
          .read(subscriptionsRepositoryProvider)
          .getPaymentIntent(intentId);
      state = state.copyWith(intent: intent);
      if (intent.status == PaymentIntentStatus.succeeded) {
        state = state.copyWith(step: CheckoutStep.succeeded);
        ref.invalidate(mySubscriptionProvider);
      } else if (intent.status.isSettled) {
        state = state.copyWith(
          step: CheckoutStep.failed,
          error: 'Thanh toán đã bị huỷ hoặc thất bại',
        );
      }
    } on AppException {
      // Bỏ qua — đây là kiểm tra tuỳ chọn, vòng lặp poll nền vẫn là nguồn
      // sự thật chính.
    }
  }

  /// Huỷ tự động gia hạn. MÀN 13 hiện KHÔNG có nút gọi hành động này — dòng
  /// chú thích cạnh `BottomActionBar` ở `plans_page.dart` chỉ là chữ tĩnh,
  /// đúng như bản phác thảo gốc (không có nút huỷ trong figcaption). Để sẵn
  /// đây cho màn quản lý gói/tài khoản sau này gọi tới.
  Future<void> cancelRenewal() async {
    await CancelSubscriptionUseCase(
      ref.read(subscriptionsRepositoryProvider),
    )();
    ref.invalidate(mySubscriptionProvider);
  }
}
