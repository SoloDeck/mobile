import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/billing_period.dart';
import 'package:solodesk_mobile/modules/subscriptions/presentation/providers/subscriptions_provider.dart';

part 'plan_selection_provider.g.dart';

/// Kỳ thanh toán người dùng đang chọn trên MÀN 13. Mặc định theo tháng —
/// khớp default `billing_period='monthly'` của backend.
@riverpod
class BillingPeriodController extends _$BillingPeriodController {
  @override
  BillingPeriod build() => BillingPeriod.monthly;

  void select(BillingPeriod period) => state = period;
}

/// Gói đích người dùng đang chọn để nâng cấp (planId).
///
/// Mặc định là upgrade target ĐẮT NHẤT — giữ hành vi cũ của màn (nút luôn trỏ
/// gói cao nhất) cho tới khi người dùng chạm một thẻ khác. Null khi đang đứng
/// gói cao nhất: không còn gì để nâng, nút bị ẩn.
///
/// `watch` plansView chứ không `read`: đổi tài khoản / refresh gói làm
/// selection cũ vô nghĩa, để nó tự tính lại từ dữ liệu mới.
@riverpod
class SelectedPlanController extends _$SelectedPlanController {
  @override
  Future<String?> build() async {
    final view = await ref.watch(plansViewProvider.future);
    final targets = view.upgradeTargets;
    // plans đã sắp theo giá tăng dần nên phần tử cuối là gói đắt nhất.
    return targets.isEmpty ? null : targets.last.id;
  }

  void select(String planId) => state = AsyncData(planId);
}
