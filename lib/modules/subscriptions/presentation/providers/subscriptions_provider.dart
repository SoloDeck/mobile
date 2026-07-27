import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/subscriptions/application/usecases/get_my_subscription_usecase.dart';
import 'package:solodesk_mobile/modules/subscriptions/application/usecases/list_plans_usecase.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/plan.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/subscription.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/repository/subscriptions_repository_impl.dart';

part 'subscriptions_provider.g.dart';

/// Toàn bộ gói dịch vụ đang bán — `GET /subscriptions/plans`, public, không
/// cần đăng nhập.
@riverpod
Future<List<Plan>> plans(Ref ref) =>
    ListPlansUseCase(ref.watch(subscriptionsRepositoryProvider))();

/// Gói đăng ký hiện tại của người dùng — `GET /subscriptions/me`.
@riverpod
Future<Subscription> mySubscription(Ref ref) =>
    GetMySubscriptionUseCase(ref.watch(subscriptionsRepositoryProvider))();

/// Dữ liệu MÀN 13: 3 gói theo đúng vị trí trên màn (thấp hơn gói hiện tại,
/// gói hiện tại, cao hơn gói hiện tại) — MÀN 13 chỉ có chỗ cho đúng 3 thẻ.
class PlansViewData {
  const PlansViewData({
    required this.free,
    required this.current,
    required this.business,
    required this.subscription,
  });

  final Plan free;
  final Plan current;
  final Plan business;
  final Subscription subscription;
}

@riverpod
Future<PlansViewData> plansView(Ref ref) async {
  final allPlans = await ref.watch(plansProvider.future);
  final subscription = await ref.watch(mySubscriptionProvider.future);
  final current = allPlans.firstWhere((p) => p.id == subscription.planId);
  // Sắp theo giá — free = rẻ nhất, business = đắt nhất; nếu danh sách khác 3
  // gói thì lấy rẻ nhất/đắt nhất làm hai đầu, chấp nhận đơn giản hoá này vì
  // MÀN 13 chỉ có 3 vị trí cố định trên bố cục.
  final sorted = [...allPlans]
    ..sort((a, b) => a.priceMonthly.compareTo(b.priceMonthly));
  final free = sorted.first;
  final business = sorted.last;
  return PlansViewData(
    free: free,
    current: current,
    business: business,
    subscription: subscription,
  );
}
