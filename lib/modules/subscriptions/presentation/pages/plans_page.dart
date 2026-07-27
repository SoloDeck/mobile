import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/plan.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/subscription.dart';
import 'package:solodesk_mobile/modules/subscriptions/presentation/controllers/checkout_controller.dart';
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
/// Bốn quyết định trong figcaption, đừng đảo lại khi sửa:
/// - Gói đang dùng (gói hiện tại của người dùng) là tấm phiếu ở **giữa** —
///   [_ProPlanSlip] nằm giữa [_FreePlanCard] và [_BusinessPlanCard] trong cây
///   widget, kèm mức tiêu thụ thật (khách hàng, lượt AI, thương vụ) thay vì
///   lời quảng cáo.
/// - Gói Free để **mờ** (`opacity: .72`) vì người này đã trả tiền — không
///   nhắc lại lựa chọn đã bỏ qua. [_FreePlanCard] bọc `Card` trong
///   `Opacity(0.72)`.
/// - Nói trước cách thanh toán (banner MoMo) và cách huỷ (dòng chú thích cạnh
///   nút) ngay trước bước cuối, giảm do dự — cả hai đặt sát nút "Nâng lên
///   Business" ở dải hành động đáy màn.
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

    return Theme(
      data: AppTheme.light(),
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

/// Thân màn sau khi đã tải xong cả ba gói và gói đang dùng. `Stack` chứ
/// không `Column` đơn: cột cuộn ở dưới, dải hành động nổi ở đáy.
///
/// Là `ConsumerWidget` (không phải `StatelessWidget`) vì nút "Nâng lên
/// Business" cần `ref` để mở `_MomoCheckoutSheet` (đọc/ghi
/// `checkoutControllerProvider`).
class _PlansBody extends ConsumerWidget {
  const _PlansBody({required this.data});

  final PlansViewData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = data.subscription;

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
                    const _BillingPeriodRow(),
                    _FreePlanCard(plan: data.free),
                    const SizedBox(height: AppGap.betweenCards),
                    _ProPlanSlip(
                      plan: data.current,
                      subscription: subscription,
                    ),
                    const SizedBox(height: AppGap.betweenCards),
                    _BusinessPlanCard(plan: data.business),
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
          child: BottomActionBar(
            caption: subscription.cancelAtPeriodEnd
                ? 'Gói sẽ ngừng gia hạn vào ${_fmtDate(subscription.currentPeriodEnd)}'
                : 'Huỷ tự động gia hạn bất cứ lúc nào',
            child: FilledButton(
              onPressed: () => _openCheckoutSheet(context, data.business.id),
              style: AppTheme.filled(tone: Tone.money),
              child: Text(
                'Nâng lên ${data.business.name} · ${Money.format(data.business.priceMonthly)}',
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openCheckoutSheet(BuildContext context, String planId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MomoCheckoutSheet(planId: planId),
    );
  }
}

/// Chọn kỳ thanh toán: "Theo tháng" (đang chọn) và "Theo năm" (kèm mức giảm).
///
/// TĨNH — chưa nối API: `POST /subscriptions/checkout` không nhận tham số kỳ
/// hạn (tháng/năm), backend chỉ tính giá theo tháng. Đổi kỳ hạn ở hàng này
/// chưa có tác dụng, giữ nguyên như bản phác thảo tới khi backend có tham số
/// tương ứng.
///
/// Không dùng `FilterChipBar` vì chip thứ hai cần chữ hai màu trong cùng một
/// nhãn ("Theo năm" mực + "−28%" ngọc) — `FilterChipBar` chỉ nhận một chuỗi
/// thuần cho mỗi chip.
class _BillingPeriodRow extends StatelessWidget {
  const _BillingPeriodRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: AppGap.lg),
      child: Row(
        children: [
          StatusChip('Theo tháng', tone: Tone.solid),
          SizedBox(width: AppGap.sm),
          _YearlyDiscountChip(),
        ],
      ),
    );
  }
}

/// Chip "Theo năm −28%" — cùng khung viền/nền như `StatusChip` mặc định
/// (`Tone.neutral`), nhưng phần giảm giá tô màu ngọc và đậm hơn phần còn lại.
class _YearlyDiscountChip extends StatelessWidget {
  const _YearlyDiscountChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppGap.md,
        vertical: AppGap.chipVertical,
      ),
      decoration: BoxDecoration(
        color: Tone.neutral.background,
        borderRadius: AppRadius.chipAll,
        border: Border.all(color: Tone.neutral.border),
      ),
      child: Text.rich(
        TextSpan(
          style: AppText.chip.copyWith(color: Tone.neutral.foreground),
          children: const [
            TextSpan(text: 'Theo năm '),
            TextSpan(
              text: '−28%',
              style: TextStyle(color: AppColors.jade),
            ),
          ],
        ),
        softWrap: false,
      ),
    );
  }
}

/// Gói Free — mờ đi vì người dùng đã trả tiền, xem figcaption. `Card` thường,
/// không phải `SlipCard`: giá "0 ₫" chỉ là tham chiếu, không phải công nợ.
class _FreePlanCard extends StatelessWidget {
  const _FreePlanCard({required this.plan});

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.72,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppGap.card),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(plan.name, style: AppText.bodyStrongLg),
                  Money(
                    plan.priceMonthly,
                    tone: Tone.neutral,
                    style: AppText.numMd,
                  ),
                ],
              ),
              const SizedBox(height: AppGap.xxs),
              Text(
                '${plan.clientsLabel} · ${plan.aiQuotaLabel} · ${plan.pdfLabel}',
                style: AppText.mut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gói đang dùng. Tấm phiếu ở giữa, kèm mức tiêu thụ thật theo đúng hạn mức
/// backend trả về (không phải số đã dùng — xem doc comment ở [PlansPage]).
class _ProPlanSlip extends StatelessWidget {
  const _ProPlanSlip({required this.plan, required this.subscription});

  final Plan plan;
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
              Money.hero(plan.priceMonthly, tone: Tone.neutral),
              const SizedBox(width: AppGap.xs),
              // `Flexible` chứ không auto: phần đuôi "/ tháng" là chữ ít quan
              // trọng hơn con số, nên khi font thay thế làm cả dòng quá rộng,
              // nó là phần được co lại (xuống dòng) trước, giữ cho số tiền
              // luôn nguyên vẹn một dòng.
              const Flexible(child: Text('/ tháng', style: AppText.num)),
            ],
          ),
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

/// Gói Business — mục tiêu nâng cấp. `Card` viền xám mặc định: bản phác thảo
/// đổi viền sang màu mực để nổi bật hơn, nhưng `AppTheme` đã cấu hình sẵn viền
/// `Card` và màn hình không được đổi viền theo từng thẻ (xem quy tắc ở
/// `AppTheme`), nên giữ viền mặc định.
class _BusinessPlanCard extends StatelessWidget {
  const _BusinessPlanCard({required this.plan});

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppGap.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(plan.name, style: AppText.bodyStrongLg),
                Money(
                  plan.priceMonthly,
                  tone: Tone.neutral,
                  style: AppText.numMd,
                ),
              ],
            ),
            const SizedBox(height: AppGap.xxs),
            Text(
              '${plan.clientsLabel} · ${plan.dealsLabel} · ${plan.aiQuotaLabel} · ${plan.pdfLabel}',
              style: AppText.mut,
            ),
            const SizedBox(height: AppGap.md),
            // Hai chip cũ "Logo riêng trên PDF" / "Hỗ trợ trong 2h" không còn
            // — không có trường nào ở `Plan` cho hai quyền lợi đó. Thay bằng
            // hai quyền lợi thật sự đọc được từ backend.
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
        ),
      ),
    );
  }
}

/// Sheet thanh toán MoMo mở ra khi bấm "Nâng lên Business". KHÔNG có trong
/// bản phác thảo gốc (`design/solodesk-mobile-ui.html` chỉ vẽ tới nút bấm) —
/// dựng đơn giản để luồng checkout có chỗ chạy, không cần đẹp; golden test
/// của MÀN 13 không kiểm hình dạng của sheet này.
class _MomoCheckoutSheet extends ConsumerStatefulWidget {
  const _MomoCheckoutSheet({required this.planId});

  final String planId;

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
          .startCheckout(widget.planId),
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
