import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/payment_intent.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/plan.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/subscription.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/billing_period.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/subscription_status.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/repository/subscriptions_repository_impl.dart';
import 'package:solodesk_mobile/modules/subscriptions/presentation/pages/plans_page.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/bottom_action_bar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/money.dart';
import 'package:solodesk_mobile/ui/notice_card.dart';
import 'package:solodesk_mobile/ui/progress_bar.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';
import 'package:solodesk_mobile/ui/stamp_badge.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

import '../flutter_test_config.dart';
import '../support/fake_settings_repository.dart';

/// Chỉ `listPlans`/`getMySubscription` được MÀN 13 dùng (qua `plansProvider`
/// và `mySubscriptionProvider`) — bốn method còn lại của
/// `SubscriptionsRepository` thuộc luồng checkout MoMo, không nằm trong ảnh
/// vàng của màn này nên `throw UnimplementedError()`.
class _FakeSubscriptionsRepository implements SubscriptionsRepository {
  const _FakeSubscriptionsRepository({
    required this.plans,
    required this.subscription,
  });

  final List<Plan> plans;
  final Subscription subscription;

  @override
  Future<List<Plan>> listPlans() async => plans;

  @override
  Future<Subscription> getMySubscription() async => subscription;

  @override
  Future<PaymentIntent> createCheckout({
    required String planId,
    BillingPeriod billingPeriod = BillingPeriod.monthly,
    String? returnUrl,
  }) => throw UnimplementedError();

  @override
  Future<Subscription> cancelSubscription() => throw UnimplementedError();

  @override
  Future<PaymentIntent> getPaymentIntent(String id) =>
      throw UnimplementedError();

  @override
  Future<PaymentIntent> cancelPaymentIntent(String id) =>
      throw UnimplementedError();
}

const free = Plan(
  id: 'plan-free',
  name: 'Free',
  slug: 'free',
  priceMonthly: 0,
  priceYearly: 0,
  currency: 'VND',
  canUseAi: false,
  canExportPdf: false,
  maxClients: 5,
  maxDeals: null,
  maxAiGenerationsPerMonth: 3,
);

const pro = Plan(
  id: 'plan-pro',
  name: 'Solo Pro',
  slug: 'pro',
  priceMonthly: 149000,
  // 149.000 × 12 × 0.72, làm tròn nghìn — khớp công thức backfill backend,
  // cho ra đúng −28% trên chip năm.
  priceYearly: 1287000,
  currency: 'VND',
  canUseAi: true,
  canExportPdf: true,
  maxClients: null,
  maxDeals: null,
  maxAiGenerationsPerMonth: 80,
);

const business = Plan(
  id: 'plan-business',
  name: 'Business',
  slug: 'business',
  priceMonthly: 399000,
  // Chiết khấu năm của gói này nông hơn Pro (≈10%) — chip "Theo năm −28%"
  // phải lấy mức giảm TỐT NHẤT trong các gói, không phải của gói đắt nhất.
  priceYearly: 4310000,
  currency: 'VND',
  canUseAi: true,
  canExportPdf: true,
  maxClients: null,
  maxDeals: null,
  maxAiGenerationsPerMonth: 999,
);

// `DateTime(...)` không phải const constructor nên fixture này không thể
// khai `const` như ba gói ở trên.
final subscription = Subscription(
  id: 's-1',
  userId: 'u-1',
  planId: 'plan-pro',
  planName: 'Solo Pro',
  planSlug: 'pro',
  status: SubscriptionStatus.active,
  currentPeriodStart: DateTime(2026, 7, 12),
  currentPeriodEnd: DateTime(2026, 8, 12),
  cancelAtPeriodEnd: false,
);

/// Kịch bản Bug 1: người dùng còn đứng gói Free — Free phải là tấm phiếu
/// hero, Pro/Agency là đích nâng cấp chọn được. Backend cho gói Free một
/// period 100 năm, vì thế ngày kết thúc kỳ cố tình đặt ở 2126 để khẳng định
/// màn KHÔNG hiện "Gia hạn ngày 12/07/2126".
final freeSubscription = Subscription(
  id: 's-1',
  userId: 'u-1',
  planId: 'plan-free',
  planName: 'Free',
  planSlug: 'free',
  status: SubscriptionStatus.active,
  currentPeriodStart: DateTime(2026, 7, 12),
  currentPeriodEnd: DateTime(2126, 7, 12),
  cancelAtPeriodEnd: false,
);

Future<void> _pump(WidgetTester tester, {Subscription? currentSubscription}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        subscriptionsRepositoryProvider.overrideWithValue(
          _FakeSubscriptionsRepository(
            plans: [free, pro, business],
            subscription: currentSubscription ?? subscription,
          ),
        ),
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: PlansPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MÀN 13 — cấu trúc theo figcaption', () {
    testWidgets('gói đang dùng (tấm phiếu) nằm giữa hai gói Free và Business', (
      tester,
    ) async {
      await _pump(tester);

      final cardFinder = find.byType(Card);
      expect(
        cardFinder,
        findsNWidgets(2),
        reason: 'chỉ gói Free và Business là Card',
      );

      final freeCardTop = tester.getTopLeft(cardFinder.at(0)).dy;
      final businessCardTop = tester.getTopLeft(cardFinder.at(1)).dy;
      final slipTop = tester.getTopLeft(find.byType(SlipCard)).dy;

      expect(freeCardTop, lessThan(slipTop));
      expect(slipTop, lessThan(businessCardTop));
    });

    testWidgets('hạn mức lượt AI hiện ra bằng số thật, chưa có phần đã dùng', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('80 lượt / tháng'), findsOneWidget);
      expect(find.byType(ProgressBar), findsNothing);
    });

    testWidgets('gói Free để mờ, không nhắc lại lựa chọn đã bỏ qua', (
      tester,
    ) async {
      await _pump(tester);

      final opacity = tester.widget<Opacity>(
        find.ancestor(of: find.text('Free'), matching: find.byType(Opacity)),
      );
      expect(opacity.opacity, closeTo(0.72, 0.0001));
    });

    testWidgets('cách thanh toán MoMo và cách huỷ đứng ngay cạnh nút chính', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.byType(NoticeCard), findsOneWidget);
      expect(find.textContaining('Thanh toán bằng MoMo'), findsOneWidget);

      final actionBar = tester.widget<BottomActionBar>(
        find.byType(BottomActionBar),
      );
      expect(actionBar.caption, 'Huỷ tự động gia hạn bất cứ lúc nào');
      expect(find.text('Nâng lên Business · 399.000 ₫'), findsOneWidget);
    });

    testWidgets('nút quay lại có nối hành động', (tester) async {
      await _pump(tester);
      final back = tester.widget<IconButtonBox>(
        find.byWidgetPredicate(
          (w) => w is IconButtonBox && w.label == 'Quay lại',
        ),
      );
      expect(back.onTap, isNotNull);
    });
  });

  group('MÀN 13 — quy ước màu', () {
    testWidgets('mọi số tiền ở đây là giá tham chiếu, không phải công nợ', (
      tester,
    ) async {
      await _pump(tester);

      final moneyWidgets = tester.widgetList<Money>(find.byType(Money));
      expect(moneyWidgets, isNotEmpty);
      for (final money in moneyWidgets) {
        expect(money.tone, Tone.neutral);
      }
    });

    testWidgets('chip "đang dùng" và con dấu Solo Pro dùng tone AI', (
      tester,
    ) async {
      await _pump(tester);

      final chip = tester.widget<StatusChip>(
        find.widgetWithText(StatusChip, 'Đang dùng'),
      );
      expect(chip.tone, Tone.ai);

      final stamp = tester.widget<StampBadge>(find.byType(StampBadge));
      expect(stamp.tone, Tone.ai);
      expect(stamp.text, 'Solo Pro');
    });

    testWidgets('chip kỳ thanh toán đang chọn dùng tone đặc (nền mực)', (
      tester,
    ) async {
      await _pump(tester);

      final monthly = tester.widget<StatusChip>(
        find.widgetWithText(StatusChip, 'Theo tháng'),
      );
      expect(monthly.tone, Tone.solid);
    });

    testWidgets('gói đích mặc định (đắt nhất) mang chip "Đã chọn" tone đặc', (
      tester,
    ) async {
      await _pump(tester);

      final chosen = tester.widget<StatusChip>(
        find.widgetWithText(StatusChip, 'Đã chọn'),
      );
      expect(chosen.tone, Tone.solid);
    });
  });

  group('MÀN 13 — chọn gói và kỳ thanh toán', () {
    testWidgets('chạm "Theo năm" đổi giá nút nâng cấp sang giá năm', (
      tester,
    ) async {
      await _pump(tester);

      await tester.tap(find.textContaining('Theo năm', findRichText: true));
      await tester.pumpAndSettle();

      expect(find.text('Nâng lên Business · 4.310.000 ₫'), findsOneWidget);
    });

    testWidgets('chạm một gói đắt hơn chuyển lựa chọn sang gói đó', (
      tester,
    ) async {
      await _pump(tester, currentSubscription: freeSubscription);

      await tester.tap(find.text('Solo Pro'));
      await tester.pumpAndSettle();

      expect(find.text('Nâng lên Solo Pro · 149.000 ₫'), findsOneWidget);
    });

    testWidgets('gói rẻ hơn gói hiện tại không chạm được (không hạ gói)', (
      tester,
    ) async {
      await _pump(tester);

      // "Đã chọn" đang đứng ở Business; chạm vào Free không được đổi gì.
      await tester.tap(find.text('Free'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Nâng lên Business · 399.000 ₫'), findsOneWidget);
    });
  });

  group('MÀN 13 — người dùng còn ở gói Free (Bug 1)', () {
    testWidgets('Free là tấm phiếu hero, đứng TRÊN hai gói trả phí', (
      tester,
    ) async {
      await _pump(tester, currentSubscription: freeSubscription);

      // Chỉ một tấm phiếu, và tên trên con dấu là Free chứ không phải Pro.
      final stamp = tester.widget<StampBadge>(find.byType(StampBadge));
      expect(stamp.text, 'Free');

      final slipTop = tester.getTopLeft(find.byType(SlipCard)).dy;
      final cardFinder = find.byType(Card);
      expect(cardFinder, findsNWidgets(2), reason: 'Pro và Business là Card');
      expect(slipTop, lessThan(tester.getTopLeft(cardFinder.at(0)).dy));
      expect(slipTop, lessThan(tester.getTopLeft(cardFinder.at(1)).dy));

      // Free không render lần thứ hai dưới dạng thẻ mờ 0.72 (các widget dùng
      // chung có thể có Opacity riêng với giá trị khác — chỉ 0.72 là dấu hiệu
      // của thẻ "gói đã bỏ qua").
      expect(
        find.byWidgetPredicate((w) => w is Opacity && w.opacity == 0.72),
        findsNothing,
      );
    });

    testWidgets('gói Free không có dòng "Gia hạn ngày…" (period 100 năm)', (
      tester,
    ) async {
      await _pump(tester, currentSubscription: freeSubscription);

      expect(find.textContaining('Gia hạn ngày'), findsNothing);
    });

    testWidgets('nút mặc định vẫn trỏ gói đắt nhất, Pro chọn được', (
      tester,
    ) async {
      await _pump(tester, currentSubscription: freeSubscription);

      expect(find.text('Nâng lên Business · 399.000 ₫'), findsOneWidget);
      expect(find.widgetWithText(StatusChip, 'Đã chọn'), findsOneWidget);
    });
  });

  group('MÀN 13 — người dùng đã ở gói cao nhất', () {
    testWidgets('ẩn nút nâng cấp, chỉ còn dòng "Bạn đang dùng gói cao nhất"', (
      tester,
    ) async {
      final businessSubscription = Subscription(
        id: 's-1',
        userId: 'u-1',
        planId: 'plan-business',
        planName: 'Business',
        planSlug: 'business',
        status: SubscriptionStatus.active,
        currentPeriodStart: DateTime(2026, 7, 12),
        currentPeriodEnd: DateTime(2026, 8, 12),
        cancelAtPeriodEnd: false,
      );
      await _pump(tester, currentSubscription: businessSubscription);

      expect(find.byType(BottomActionBar), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
      expect(find.text('Bạn đang dùng gói cao nhất'), findsOneWidget);
    });
  });

  group('MÀN 13 — chuỗi hiển thị chép từ bản phác thảo', () {
    testWidgets('nguyên văn tiếng Việt, không diễn giải lại', (tester) async {
      await _pump(tester);

      for (final text in [
        'Gói dịch vụ',
        'Theo tháng',
        'Free',
        // Cả ba thẻ dùng chung một dòng tóm tắt 4 phần (khách · thương vụ ·
        // AI · PDF) từ khi gộp về một `_PlanCard` — không còn bản rút gọn
        // riêng cho Free.
        '5 khách · Không giới hạn · 3 lượt AI · không xuất PDF',
        'Đang dùng',
        // `StampBadge` tự in hoa chữ (xem lib/ui/stamp_badge.dart), nên "Solo
        // Pro" hiện ra trên màn là "SOLO PRO".
        'SOLO PRO',
        'Gia hạn ngày 12/08/2026',
        'Khách hàng & thương vụ',
        'Không giới hạn',
        'Lượt AI trong tháng',
        '80 lượt / tháng',
        'Business',
        'Xuất PDF không đóng dấu',
        'AI không giới hạn',
        'Nâng lên Business · 399.000 ₫',
        'Huỷ tự động gia hạn bất cứ lúc nào',
      ]) {
        expect(find.text(text), findsWidgets, reason: 'thiếu chuỗi "$text"');
      }

      // Chữ hai màu trong một chip, kiểm bằng textContaining trên rich text.
      expect(
        find.textContaining('Theo năm', findRichText: true),
        findsOneWidget,
      );
      expect(find.textContaining('−28%', findRichText: true), findsOneWidget);
    });

    testWidgets('số tiền định dạng theo cách người Việt viết', (tester) async {
      await _pump(tester);
      expect(find.text('0 ₫'), findsOneWidget);
      expect(find.text('149.000 ₫'), findsOneWidget);
      expect(find.text('399.000 ₫'), findsOneWidget);
    });
  });

  group('MÀN 13 — quy tắc không được vi phạm', () {
    testWidgets('nền màn là màu giấy, không phải trắng', (tester) async {
      await _pump(tester);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        AppColors.paper,
      );
    });

    testWidgets('không có thành phần kéo thả nào', (tester) async {
      await _pump(tester);
      expect(find.byType(Draggable<Object>), findsNothing);
      expect(find.byType(ReorderableListView), findsNothing);
    });
  });

  testWidgets('ảnh vàng — màn 13 gói và thanh toán MoMo', (tester) async {
    await _pump(tester);
    await expectLater(
      find.byType(PlansPage),
      matchesGoldenFile('goldens/screen_13_plans.png'),
    );
  }, skip: !soloFontsLoaded);

  testWidgets('ảnh vàng — màn 13 khi còn ở gói Free (Bug 1)', (tester) async {
    await _pump(tester, currentSubscription: freeSubscription);
    await expectLater(
      find.byType(PlansPage),
      matchesGoldenFile('goldens/screen_13_plans_free.png'),
    );
  }, skip: !soloFontsLoaded);
}
