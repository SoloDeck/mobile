import 'package:collection/collection.dart';
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

/// Dữ liệu MÀN 13: TOÀN BỘ gói đang bán (sắp theo giá tháng tăng dần) + gói
/// hiện tại của người dùng. Không còn giả định "đúng 3 gói, gói giữa là gói
/// đang dùng" như bản đầu — màn render theo danh sách, gói nào đang dùng thì
/// thành tấm phiếu hero, bất kể là Free hay gói đắt nhất.
class PlansViewData {
  const PlansViewData({
    required this.plans,
    required this.currentPlan,
    required this.subscription,
  });

  /// Mọi gói đang bán, sắp theo `priceMonthly` tăng dần.
  final List<Plan> plans;

  /// Gói người dùng đang đứng — null khi `subscription.planId` không khớp
  /// gói nào trong [plans] (dữ liệu lệch giữa hai endpoint); màn vẫn phải
  /// render danh sách thay vì crash.
  final Plan? currentPlan;

  final Subscription subscription;

  /// Các gói đắt hơn gói hiện tại — những đích nâng cấp hợp lệ (không hỗ trợ
  /// hạ gói). Khi không xác định được gói hiện tại, coi như đứng ở đáy: mọi
  /// gói trả phí đều là đích nâng cấp.
  List<Plan> get upgradeTargets {
    final floor = currentPlan?.priceMonthly ?? 0;
    return plans.where((p) => p.priceMonthly > floor).toList();
  }

  /// True khi không còn gói nào đắt hơn để nâng — ẩn nút nâng cấp.
  bool get isOnTopPlan => upgradeTargets.isEmpty;
}

@riverpod
Future<PlansViewData> plansView(Ref ref) async {
  final allPlans = await ref.watch(plansProvider.future);
  final subscription = await ref.watch(mySubscriptionProvider.future);
  final sorted = [...allPlans]
    ..sort((a, b) => a.priceMonthly.compareTo(b.priceMonthly));
  // firstWhereOrNull chứ không firstWhere: planId lạ (gói đã gỡ bán, dữ liệu
  // lệch) không được phép ném StateError làm sập cả màn.
  final current = sorted.firstWhereOrNull((p) => p.id == subscription.planId);
  return PlansViewData(
    plans: sorted,
    currentPlan: current,
    subscription: subscription,
  );
}
