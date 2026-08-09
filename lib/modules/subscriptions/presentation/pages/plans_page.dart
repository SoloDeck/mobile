import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/plan.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/subscription.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/billing_period.dart';
import 'package:solodesk_mobile/modules/subscriptions/presentation/controllers/checkout_controller.dart';
import 'package:solodesk_mobile/modules/subscriptions/presentation/providers/plan_selection_provider.dart';
import 'package:solodesk_mobile/modules/subscriptions/presentation/providers/subscriptions_provider.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/bottom_action_bar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/money.dart';
import 'package:solodesk_mobile/ui/mono_text.dart';
import 'package:solodesk_mobile/ui/notice_card.dart';
import 'package:solodesk_mobile/ui/perforated_divider.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/stamp_badge.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// MÀN 13 — Gói và thanh toán MoMo.
///
/// Đối chiếu: khối `MÀN 13` (dòng 1035-1092) trong
/// `design/solodesk-mobile-ui.html`, gồm cả `<figcaption>`.
///
/// Các quyết định hiện hành, đừng đảo lại khi sửa:
/// - Mọi gói render từ MỘT danh sách ([_PlanCard]) — KHÔNG hardcode 3 slot
///   Free/Pro/Business như bản đầu. Gói người dùng ĐANG DÙNG (bất kể là gói
///   nào, kể cả Free) mới là tấm phiếu hero có chrome tím "Đang dùng" và mức
///   hạn mức thật; hai bản đầu từng hero cứng gói Pro làm người dùng Free
///   thấy Free hiện hai lần.
/// - Gói RẺ HƠN gói hiện tại để **mờ** (`opacity: .72`) và không chạm được —
///   không hỗ trợ hạ gói, không nhắc lại lựa chọn đã bỏ qua. Gói ĐẮT HƠN
///   chạm được để chọn làm đích nâng cấp; gói đích đang chọn mang chip
///   "Đã chọn" (không đổi viền `Card` — quy tắc `AppTheme`).
/// - Hàng chip "Theo tháng / Theo năm" chạm được và đổi giá mọi thẻ theo kỳ;
///   phần trăm giảm trên chip năm tính từ dữ liệu gói, không hardcode −28%.
/// - Nói trước cách thanh toán (banner MoMo) và cách huỷ (dòng chú thích cạnh
///   nút) ngay trước bước cuối, giảm do dự — cả hai đặt sát nút nâng cấp ở
///   dải hành động đáy màn. Đứng gói cao nhất thì không còn gì để nâng: ẩn
///   nút, chỉ ghi "Bạn đang dùng gói cao nhất".
///
/// ## Vì sao KHÔNG có thanh tiến độ "18/80 lượt AI"
///
/// Bản phác thảo gốc vẽ một thanh tiến độ hạn mức AI đã dùng. Backend KHÔNG
/// có endpoint usage/quota — bảng `usage_records` tồn tại nhưng không lộ ra
/// REST (xem `ApiEndpoints`, mục Subscriptions) — nên client không có cách
/// nào biết số ĐÃ DÙNG thật. Vẽ một thanh tiến độ luôn rỗng hoặc luôn đầy giả
/// là nói dối người dùng, nên quyết định đã chốt là BỎ HẲN `ProgressBar` và
/// chỉ hiện hạn mức ("80 lượt / tháng"), không hiện tỉ lệ đã dùng.
class PlansPage extends ConsumerWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewAsync = ref.watch(plansViewProvider);
    final appearance = ref.watch(appearanceControllerProvider);

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          child: AsyncValueWidget<PlansViewData>(
            value: viewAsync,
            onRetry: () => ref.invalidate(plansViewProvider),
            data: (data) => _PlansBody(data: data),
          ),
        ),
      ),
    );
  }
}

/// Thân màn sau khi đã tải xong danh sách gói và gói đang dùng. `Stack` chứ
/// không `Column` đơn: cột cuộn ở dưới, dải hành động nổi ở đáy.
///
/// Là `ConsumerWidget` vì cần `ref` cho ba thứ: kỳ thanh toán đang chọn, gói
/// đích đang chọn, và mở `_MomoCheckoutSheet` (đọc/ghi
/// `checkoutControllerProvider`).
class _PlansBody extends ConsumerWidget {
  const _PlansBody({required this.data});

  final PlansViewData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = data.subscription;
    final period = ref.watch(billingPeriodControllerProvider);
    final selectedId = ref.watch(selectedPlanControllerProvider).value;
    final selectedPlan = selectedId == null
        ? null
        : data.plans.where((p) => p.id == selectedId).firstOrNull;
    final currentPrice = data.currentPlan?.priceMonthly ?? 0;

    // Mức giảm lớn nhất trong các gói đang bán — chip "Theo năm −x%" là lời
    // mời chung cho cả hàng, lấy con số tốt nhất người dùng có thể đạt được.
    var discountPercent = 0;
    for (final plan in data.plans) {
      if (plan.yearlyDiscountPercent > discountPercent) {
        discountPercent = plan.yearlyDiscountPercent;
      }
    }

    return Stack(
      children: [
        // Nút quay lại mang closure nên `Column` không còn `const` được;
        // nhánh nội dung bên dưới vẫn giữ `const` từng phần không đổi.
        Column(
          children: [
            SoloAppBar(
              title: 'Gói dịch vụ',
              titleSize: SoloAppBar.sm,
              leading: IconButtonBox(
                SoloIcons.back,
                label: 'Quay lại',
                ghost: true,
                onTap: () => context.pop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppGap.screen,
                  0,
                  AppGap.screen,
                  // Không có `SoloNavBar` ở màn này — khoảng chừa này chỉ để
                  // nội dung cuối không bị `BottomActionBar` che. Không có
                  // token riêng cho việc này trong `AppGap`, dùng tạm
                  // `navBarInset` vì cùng là khoảng chừa cho một dải nổi ở
                  // đáy màn.
                  AppGap.navBarInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BillingPeriodRow(discountPercent: discountPercent),
                    for (final (index, plan) in data.plans.indexed) ...[
                      if (index > 0)
                        const SizedBox(height: AppGap.betweenCards),
                      _PlanCard(
                        plan: plan,
                        period: period,
                        isCurrent: plan.id == data.currentPlan?.id,
                        isSelected: plan.id == selectedId,
                        // Gói rẻ hơn gói hiện tại: đã bỏ qua, mờ và không
                        // chạm được (không hỗ trợ hạ gói).
                        isDimmed: plan.id != data.currentPlan?.id &&
                            plan.priceMonthly <= currentPrice,
                        subscription: subscription,
                        onTap: () => ref
                            .read(selectedPlanControllerProvider.notifier)
                            .select(plan.id),
                      ),
                    ],
                    const SizedBox(height: AppGap.card),
                    const NoticeCard(
                      tone: Tone.money,
                      icon: SoloIcons.cash,
                      message:
                          'Thanh toán bằng MoMo, quét mã hoặc mở thẳng ứng dụng. '
                          'Gói kích hoạt trong vài giây.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: data.isOnTopPlan
              // Không còn gì để nâng: không dựng `BottomActionBar` chỉ để
              // chứa một dòng chữ (widget đó tồn tại vì cái nút) — một dòng
              // caption tĩnh là đủ.
              ? const Padding(
                  padding: EdgeInsets.only(bottom: AppGap.xxxl),
                  child: Text(
                    'Bạn đang dùng gói cao nhất',
                    style: AppText.mut,
                    textAlign: TextAlign.center,
                  ),
                )
              : selectedPlan == null
                  ? const SizedBox.shrink()
                  : BottomActionBar(
                      caption: subscription.cancelAtPeriodEnd
                          ? 'Gói sẽ ngừng gia hạn vào ${_fmtDate(subscription.currentPeriodEnd)}'
                          : 'Huỷ tự động gia hạn bất cứ lúc nào',
                      child: FilledButton(
                        onPressed: () => _openCheckoutSheet(
                          context,
                          selectedPlan.id,
                          period,
                        ),
                        style: AppTheme.filled(tone: Tone.money),
                        child: Text(
                          'Nâng lên ${selectedPlan.name} · '
                          '${Money.format(selectedPlan.priceFor(period))}',
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  void _openCheckoutSheet(
    BuildContext context,
    String planId,
    BillingPeriod period,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MomoCheckoutSheet(planId: planId, billingPeriod: period),
    );
  }
}

/// Chọn kỳ thanh toán: hai chip chạm được, chip đang chọn nền mực
/// (`Tone.solid`). Chip năm kèm phần trăm giảm tính từ dữ liệu gói
/// ([PlanX.yearlyDiscountPercent]) — không hardcode "−28%".
///
/// Không dùng `FilterChipBar` vì chip thứ hai cần chữ hai màu trong cùng một
/// nhãn ("Theo năm" mực + "−28%" ngọc) — `FilterChipBar` chỉ nhận một chuỗi
/// thuần cho mỗi chip.
class _BillingPeriodRow extends ConsumerWidget {
  const _BillingPeriodRow({required this.discountPercent});

  /// Mức giảm lớn nhất trong các gói đang bán, đơn vị %.
  final int discountPercent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(billingPeriodControllerProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppGap.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => ref
                .read(billingPeriodControllerProvider.notifier)
                .select(BillingPeriod.monthly),
            child: StatusChip(
              'Theo tháng',
              tone: period == BillingPeriod.monthly
                  ? Tone.solid
                  : Tone.neutral,
            ),
          ),
          const SizedBox(width: AppGap.sm),
          GestureDetector(
            onTap: () => ref
                .read(billingPeriodControllerProvider.notifier)
                .select(BillingPeriod.yearly),
            child: _YearlyDiscountChip(
              selected: period == BillingPeriod.yearly,
              discountPercent: discountPercent,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip "Theo năm −x%" — cùng khung viền/nền như `StatusChip` (`Tone.neutral`
/// khi chưa chọn, `Tone.solid` khi đang chọn), nhưng phần giảm giá tô màu
/// ngọc và tách khỏi phần chữ còn lại.
class _YearlyDiscountChip extends StatelessWidget {
  const _YearlyDiscountChip({
    required this.selected,
    required this.discountPercent,
  });

  final bool selected;
  final int discountPercent;

  @override
  Widget build(BuildContext context) {
    final tone = selected ? Tone.solid : Tone.neutral;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppGap.md,
        vertical: AppGap.chipVertical,
      ),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: AppRadius.chipAll,
        border: Border.all(color: tone.border),
      ),
      child: Text.rich(
        TextSpan(
          style: AppText.chip.copyWith(color: tone.foreground),
          children: [
            const TextSpan(text: 'Theo năm '),
            if (discountPercent > 0)
              TextSpan(
                text: '−$discountPercent%',
                style: const TextStyle(color: AppColors.jade),
              ),
          ],
        ),
        softWrap: false,
      ),
    );
  }
}

/// Một gói trong danh sách — ba biến thể theo vị trí của nó so với gói người
/// dùng đang đứng:
///
/// - [isCurrent]: tấm phiếu hero `SlipCard` chrome tím "Đang dùng" + hạn mức
///   thật (xem [_CurrentPlanSlip]).
/// - [isDimmed] (rẻ hơn gói hiện tại): `Card` mờ 0.72, không chạm được —
///   không hỗ trợ hạ gói.
/// - còn lại (đích nâng cấp): `Card` chạm được để chọn; gói đang chọn mang
///   chip "Đã chọn" `Tone.solid`. KHÔNG đổi viền `Card` theo trạng thái chọn
///   — `AppTheme` đã cấu hình sẵn viền và màn không được đổi theo từng thẻ
///   (xem quy tắc ở `AppTheme`).
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.period,
    required this.isCurrent,
    required this.isSelected,
    required this.isDimmed,
    required this.subscription,
    required this.onTap,
  });

  final Plan plan;
  final BillingPeriod period;
  final bool isCurrent;
  final bool isSelected;
  final bool isDimmed;
  final Subscription subscription;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isCurrent) {
      return _CurrentPlanSlip(
        plan: plan,
        period: period,
        subscription: subscription,
      );
    }

    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(AppGap.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppGap.sm,
                    runSpacing: AppGap.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(plan.name, style: AppText.bodyStrongLg),
                      if (isSelected)
                        const StatusChip('Đã chọn', tone: Tone.solid),
                    ],
                  ),
                ),
                const SizedBox(width: AppGap.sm),
                _PlanPrice(plan: plan, period: period),
              ],
            ),
            const SizedBox(height: AppGap.xxs),
            Text(
              '${plan.clientsLabel} · ${plan.dealsLabel} · ${plan.aiQuotaLabel} · ${plan.pdfLabel}',
              style: AppText.mut,
            ),
            // Hai chip cũ "Logo riêng trên PDF" / "Hỗ trợ trong 2h" không còn
            // — không có trường nào ở `Plan` cho hai quyền lợi đó. Chỉ hiện
            // quyền lợi thật sự đọc được từ backend.
            if (plan.canExportPdf || plan.canUseAi) ...[
              const SizedBox(height: AppGap.md),
              Wrap(
                spacing: AppGap.xs,
                runSpacing: AppGap.xs,
                children: [
                  if (plan.canExportPdf)
                    const StatusChip('Xuất PDF không đóng dấu'),
                  if (plan.canUseAi) const StatusChip('AI không giới hạn'),
                ],
              ),
            ],
          ],
        ),
      ),
    );

    if (isDimmed) return Opacity(opacity: 0.72, child: card);
    return GestureDetector(onTap: onTap, child: card);
  }
}

/// Giá của một gói theo kỳ đang chọn, kèm đuôi "/ tháng" | "/ năm". Giá ở đây
/// là tham chiếu, không phải công nợ — luôn `Tone.neutral`.
class _PlanPrice extends StatelessWidget {
  const _PlanPrice({required this.plan, required this.period});

  final Plan plan;
  final BillingPeriod period;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Money(
          plan.priceFor(period),
          tone: Tone.neutral,
          style: AppText.numMd,
        ),
        const SizedBox(width: AppGap.xs),
        Text(period.priceSuffix, style: AppText.mut),
      ],
    );
  }
}

/// Gói đang dùng — tấm phiếu hero, kèm hạn mức thật theo đúng backend trả về
/// (không phải số đã dùng — xem doc comment ở [PlansPage]).
class _CurrentPlanSlip extends StatelessWidget {
  const _CurrentPlanSlip({
    required this.plan,
    required this.period,
    required this.subscription,
  });

  final Plan plan;
  final BillingPeriod period;
  final Subscription subscription;

  @override
  Widget build(BuildContext context) {
    return SlipCard(
      notch: 150,
      borderColor: AppColors.ai,
      borderWidth: 2,
      // Bản phác thảo dùng nền chuyển sắc `#F7F2FE → #fff`, một giá trị không
      // nằm trong bảng token màu tự sinh. Lấy cặp gần nhất trong bảng: tím rất
      // nhạt `aiSoft` chuyển sang `surface`.
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.aiSoft, AppColors.surface],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // `Wrap` chứ không phải `Row`: cả `StatusChip` lẫn `StampBadge`
          // không tự co chữ (softWrap: false trong hai widget dùng chung),
          // nên nếu font thay thế đo chữ rộng hơn font thật, một `Row` ép
          // chúng chung một hàng sẽ tràn ngang. `Wrap` cho badge rơi xuống
          // dòng dưới thay vì tràn, và với `WrapAlignment.spaceBetween` khi
          // đủ chỗ nó vẫn lên đúng một hàng dàn hai đầu như bản phác thảo.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppGap.sm,
            runSpacing: AppGap.xs,
            children: [
              // KHÔNG có "· phổ biến nhất" như bản mock cũ — API không có
              // trường nào xác nhận một gói là "phổ biến nhất".
              const StatusChip('Đang dùng', tone: Tone.ai),
              StampBadge.draft(plan.name),
            ],
          ),
          const SizedBox(height: AppGap.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // Money.hero gắn liền ký hiệu ₫ vào số nên "₫" hiện ra cùng cỡ
              // lớn với số tiền, thay vì cỡ nhỏ tách riêng như bản phác thảo —
              // chấp nhận để không phải tách chuỗi định dạng khỏi `Money`.
              Money.hero(plan.priceFor(period), tone: Tone.neutral),
              const SizedBox(width: AppGap.xs),
              // `Flexible` chứ không auto: phần đuôi "/ tháng" là chữ ít quan
              // trọng hơn con số, nên khi font thay thế làm cả dòng quá rộng,
              // nó là phần được co lại (xuống dòng) trước, giữ cho số tiền
              // luôn nguyên vẹn một dòng.
              Flexible(child: Text(period.priceSuffix, style: AppText.num)),
            ],
          ),
          // Gói Free có period 100 năm phía backend — "Gia hạn ngày
          // 12/07/2126" trông như lỗi hiển thị, và Free cũng chẳng có gì để
          // "gia hạn". Chỉ gói trả phí mới có dòng ngày.
          if (plan.priceMonthly > 0)
            Text(
              'Gia hạn ngày ${_fmtDate(subscription.currentPeriodEnd)}',
              style: AppText.mut,
            ),
          const PerforatedDivider(),
          _SlipEntitlementRow(
            label: 'Khách hàng & thương vụ',
            value: plan.clientsLabel,
          ),
          _SlipEntitlementRow(
            label: 'Lượt AI trong tháng',
            value: '${plan.maxAiGenerationsPerMonth} lượt / tháng',
          ),
          _SlipEntitlementRow(label: 'Thương vụ', value: plan.dealsLabel),
        ],
      ),
    );
  }
}

/// Một dòng entitlement bên trong tấm phiếu gói đang dùng: nhãn mờ bên trái,
/// số liệu đậm bên phải — `.between` + `b.num` trong bản phác thảo.
class _SlipEntitlementRow extends StatelessWidget {
  const _SlipEntitlementRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: AppText.sub)),
        const SizedBox(width: AppGap.sm),
        MonoText(value),
      ],
    );
  }
}

/// Sheet thanh toán MoMo mở ra khi bấm nút nâng cấp. KHÔNG có trong bản phác
/// thảo gốc (`design/solodesk-mobile-ui.html` chỉ vẽ tới nút bấm) — dựng đơn
/// giản để luồng checkout có chỗ chạy, không cần đẹp; golden test của MÀN 13
/// không kiểm hình dạng của sheet này.
class _MomoCheckoutSheet extends ConsumerStatefulWidget {
  const _MomoCheckoutSheet({required this.planId, required this.billingPeriod});

  final String planId;
  final BillingPeriod billingPeriod;

  @override
  ConsumerState<_MomoCheckoutSheet> createState() => _MomoCheckoutSheetState();
}

class _MomoCheckoutSheetState extends ConsumerState<_MomoCheckoutSheet> {
  @override
  void initState() {
    super.initState();
    // Hoãn sang sau khung hình đầu vì `startCheckout` đổi state ngay lập tức
    // — gọi thẳng trong `initState` (trước khi khung hình đầu dựng xong) sẽ
    // ném lỗi "setState() or markNeedsBuild() called during build". Cùng mẫu
    // với `voice_capture_page_new.dart`.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref
          .read(checkoutControllerProvider.notifier)
          .startCheckout(widget.planId, billingPeriod: widget.billingPeriod),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutControllerProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppGap.card),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thanh toán MoMo', style: AppText.bodyStrongLg),
            const SizedBox(height: AppGap.md),
            _CheckoutStatusView(state: state),
            const SizedBox(height: AppGap.lg),
          ],
        ),
      ),
    );
  }
}

/// Nội dung sheet theo từng bước của [CheckoutState.step] — đơn giản, chỉ
/// cần đủ chữ để người dùng biết đang ở đâu trong luồng.
class _CheckoutStatusView extends StatelessWidget {
  const _CheckoutStatusView({required this.state});

  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    switch (state.step) {
      case CheckoutStep.idle:
      case CheckoutStep.creatingIntent:
        return const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: AppGap.sm),
            Text('Đang khởi tạo thanh toán…', style: AppText.sub),
          ],
        );
      case CheckoutStep.awaitingPayment:
        final qrUrl = state.intent?.paymentLink.qrCodeUrl;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đang chờ xác nhận thanh toán từ MoMo…',
              style: AppText.sub,
            ),
            if (state.needsQr && qrUrl != null) ...[
              const SizedBox(height: AppGap.md),
              Image.network(qrUrl, height: 200),
            ],
          ],
        );
      case CheckoutStep.succeeded:
        return const Text(
          'Thanh toán thành công, gói đã được kích hoạt.',
          style: AppText.sub,
        );
      case CheckoutStep.failed:
        return Text(
          state.error ?? 'Thanh toán thất bại, vui lòng thử lại.',
          style: AppText.sub,
        );
    }
  }
}

/// Định dạng ngày kiểu "dd/MM/yyyy" — dùng cho ngày gia hạn/ngừng gia hạn.
/// Tự viết thay vì `intl` để ảnh vàng không phụ thuộc dữ liệu locale, cùng lý
/// do với `Money.format`.
String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/'
    '${d.month.toString().padLeft(2, '0')}/${d.year}';
