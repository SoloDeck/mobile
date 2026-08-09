import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/payment_intent.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/plan.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/subscription.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/billing_period.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/subscription_status.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/repository/subscriptions_repository_impl.dart';
import 'package:solodesk_mobile/modules/subscriptions/presentation/providers/plan_selection_provider.dart';
import 'package:solodesk_mobile/modules/subscriptions/presentation/providers/subscriptions_provider.dart';

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

const _free = Plan(
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

const _pro = Plan(
  id: 'plan-pro',
  name: 'Solo Pro',
  slug: 'pro',
  priceMonthly: 149000,
  priceYearly: 1287000,
  currency: 'VND',
  canUseAi: true,
  canExportPdf: true,
  maxClients: null,
  maxDeals: null,
  maxAiGenerationsPerMonth: 80,
);

const _business = Plan(
  id: 'plan-business',
  name: 'Business',
  slug: 'business',
  priceMonthly: 399000,
  priceYearly: 4310000,
  currency: 'VND',
  canUseAi: true,
  canExportPdf: true,
  maxClients: null,
  maxDeals: null,
  maxAiGenerationsPerMonth: 999,
);

Subscription _subscriptionOn(String planId) => Subscription(
  id: 's-1',
  userId: 'u-1',
  planId: planId,
  planName: 'x',
  planSlug: 'x',
  status: SubscriptionStatus.active,
  currentPeriodStart: DateTime(2026, 7, 12),
  currentPeriodEnd: DateTime(2026, 8, 12),
  cancelAtPeriodEnd: false,
);

ProviderContainer _containerOn(String planId) {
  final container = ProviderContainer(
    overrides: [
      subscriptionsRepositoryProvider.overrideWithValue(
        _FakeSubscriptionsRepository(
          // Cố tình đưa vào KHÔNG theo thứ tự giá — provider phải tự sắp.
          plans: const [_business, _free, _pro],
          subscription: _subscriptionOn(planId),
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('sorts plans by priceMonthly and finds the current plan', () async {
    final container = _containerOn('plan-pro');
    final view = await container.read(plansViewProvider.future);

    expect(view.plans.map((p) => p.id), [
      'plan-free',
      'plan-pro',
      'plan-business',
    ]);
    expect(view.currentPlan?.id, 'plan-pro');
  });

  test('unknown planId leaves currentPlan null instead of throwing', () async {
    final container = _containerOn('plan-ghost');
    final view = await container.read(plansViewProvider.future);

    expect(view.currentPlan, isNull);
    // Không xác định được chỗ đứng -> coi như ở đáy: mọi gói trả phí đều là
    // đích nâng cấp, màn vẫn dùng được.
    expect(view.upgradeTargets.map((p) => p.id), ['plan-pro', 'plan-business']);
    expect(view.isOnTopPlan, isFalse);
  });

  test('upgradeTargets are only the plans more expensive than current', () async {
    final container = _containerOn('plan-pro');
    final view = await container.read(plansViewProvider.future);

    expect(view.upgradeTargets.map((p) => p.id), ['plan-business']);
    expect(view.isOnTopPlan, isFalse);
  });

  test('on the Free plan every paid plan is an upgrade target', () async {
    final container = _containerOn('plan-free');
    final view = await container.read(plansViewProvider.future);

    expect(view.upgradeTargets.map((p) => p.id), ['plan-pro', 'plan-business']);
    expect(view.isOnTopPlan, isFalse);
  });

  test('on the top plan there is nothing left to upgrade to', () async {
    final container = _containerOn('plan-business');
    final view = await container.read(plansViewProvider.future);

    expect(view.upgradeTargets, isEmpty);
    expect(view.isOnTopPlan, isTrue);
  });

  group('SelectedPlanController', () {
    test('defaults to the most expensive upgrade target', () async {
      final container = _containerOn('plan-pro');
      final selected = await container.read(
        selectedPlanControllerProvider.future,
      );

      expect(selected, 'plan-business');
    });

    test('is null when the user is already on the top plan', () async {
      final container = _containerOn('plan-business');
      final selected = await container.read(
        selectedPlanControllerProvider.future,
      );

      expect(selected, isNull);
    });

    test('select() overrides the default', () async {
      final container = _containerOn('plan-free');
      await container.read(selectedPlanControllerProvider.future);

      container
          .read(selectedPlanControllerProvider.notifier)
          .select('plan-pro');

      expect(
        container.read(selectedPlanControllerProvider).value,
        'plan-pro',
      );
    });
  });

  group('PlanX.yearlyDiscountPercent', () {
    test('is 28 for the Pro fixture', () {
      expect(_pro.yearlyDiscountPercent, 28);
    });

    test('guards against division by zero on the free plan', () {
      expect(_free.yearlyDiscountPercent, 0);
    });

    test('priceFor returns the price of the requested period', () {
      expect(_pro.priceFor(BillingPeriod.monthly), 149000);
      expect(_pro.priceFor(BillingPeriod.yearly), 1287000);
    });
  });
}
