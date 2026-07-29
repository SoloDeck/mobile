import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/presentation/controllers/deals_controller.dart';
import 'package:solodesk_mobile/modules/deals/presentation/providers/deals_provider.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/pages/invoice_form_page.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/providers/invoices_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/modules/deals/presentation/widgets/deal_activity_tab.dart';
import 'package:solodesk_mobile/modules/deals/presentation/widgets/deal_attachments_tab.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/presentation/pages/widgets/task_list_widget.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/avatar.dart';
import 'package:solodesk_mobile/ui/filter_chip_bar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/money.dart';
import 'package:solodesk_mobile/ui/mono_text.dart';
import 'package:solodesk_mobile/ui/perforated_divider.dart';
import 'package:solodesk_mobile/ui/section_header.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/stage_bar.dart';
import 'package:solodesk_mobile/ui/stamp_badge.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// MÀN 05 — Chi tiết thương vụ.
///
/// Đối chiếu: khối `MÀN 05` (dòng 513–571, gồm cả `<figcaption>`) trong
/// `design/solodesk-mobile-ui.html`.
///
/// Bốn quyết định trong figcaption, đừng đảo lại khi sửa:
/// - Nút **nhắn Zalo** đặt cạnh tên khách (`_CustomerCard`), không gộp vào menu
///   ba chấm ở appbar, vì đó là hành động hay dùng nhất trong màn này.
/// - Thanh 6 vạch (`StageBar.steps`) nhắc đúng sáu giai đoạn của bản web — hai
///   nền tảng nói cùng một ngôn ngữ, không rút gọn còn ba hay bốn bước.
/// - Lịch thanh toán dựng bằng `SlipCard` vì đúng là tiền (quy tắc 3
///   `AGENTS.md`): đợt đã thu tô ngọc, đợt đến hạn tô hồng kèm con dấu quá hạn,
///   đợt chưa tới tô xám.
/// - Tab con (Dự án / Tài liệu / Lịch sử) gom bằng `FilterChipBar` cuộn ngang
///   thay vì dựng ba màn con riêng, để không làm nặng màn hình đầu.
///
/// Đổi giai đoạn qua chip "Đổi giai đoạn" — mở menu chọn, không kéo thả (quy
/// tắc 4 `AGENTS.md`).
///
/// Bản chuyển từ `lib/features/deal_detail/deal_detail_screen.dart`, nối dữ
/// liệu thật qua `dealDetailProvider(dealId)` (giá trị hợp đồng, tên khách,
/// giai đoạn) và `dealInvoicesProvider(dealId)` (lịch thanh toán). Số điện
/// thoại và ghi chú trao đổi gần nhất không có trên `Deal`, vẫn giữ dữ liệu
/// giả — xem `_MockData`.
///
/// `DealStage` có **7** giá trị, không phải 6: `lost` đứng ngoài chuỗi sáu bước
/// hướng-tiến của pipeline (xem `_pipelineStages` bên dưới, lặp lại đúng thứ tự
/// riêng của `DealStageX.canTransitionTo` vì thứ tự đó không được export ra
/// ngoài entity). Thanh vạch coi `lost` là "đã dừng", không cố ép vào một vị trí
/// 1–6.
class DealDetailPage extends ConsumerStatefulWidget {
  const DealDetailPage({super.key, required this.dealId});

  final String dealId;

  @override
  ConsumerState<DealDetailPage> createState() => _DealDetailPageState();
}

class _DealDetailPageState extends ConsumerState<DealDetailPage> {
  // Tab con đang được chọn trên `FilterChipBar` — mặc định tab đầu ("Tổng
  // quan") để giữ nguyên hành vi lần mở màn đầu tiên.
  int _selectedSubTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final dealId = widget.dealId;
    final dealAsync = ref.watch(dealDetailProvider(dealId));

    // Báo lỗi đổi giai đoạn ở cấp màn, không đặt trong bảng chọn: bảng đã đóng
    // trước khi lệnh gửi đi (xem `_applyStage`), nên đây là chỗ duy nhất còn
    // sống để hiện SnackBar. `ref.listen` không thêm widget nào vào cây nên ảnh
    // vàng của màn giữ nguyên.
    ref.listen(dealStageControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        final error = next.error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // `AppException` đã mang sẵn câu tiếng Việt cho người dùng đọc.
            // Lỗi khác (`DioException`…) thì `toString()` ra một khối kỹ thuật
            // dài, không đưa lên màn được — dùng câu dự phòng.
            content: Text(
              error is AppException
                  ? error.message
                  : 'Không đổi được giai đoạn. Thử lại sau.',
            ),
          ),
        );
      }
    });

    // Nút ba chấm cần `deal` để dựng đường dẫn tạo hoá đơn; lúc đang tải thì
    // chưa có, nút đứng im chứ cây widget không đổi.
    final deal = dealAsync.value;
    final appearance = ref.watch(appearanceControllerProvider);

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          child: Column(
            children: [
              SoloAppBar(
                // Tiêu đề chỉ có sau khi tải xong; trống trong lúc chờ thay vì
                // hiện tên tạm bợ, vì `AsyncValueWidget` bên dưới đã lo trạng
                // thái chờ/lỗi cho phần thân màn.
                title: dealAsync.value?.title ?? '',
                titleSize: SoloAppBar.xxs,
                leading: IconButtonBox(
                  SoloIcons.back,
                  label: 'Quay lại',
                  ghost: true,
                  onTap: () => context.pop(),
                ),
                // Không `const` được nữa: nút ba chấm mang closure mở bảng
                // tuỳ chọn.
                actions: [
                  IconButtonBox(
                    SoloIcons.dots,
                    label: 'Tuỳ chọn khác',
                    ghost: true,
                    onTap: deal == null
                        ? null
                        : () => _showDealMenu(context, deal),
                  ),
                ],
              ),
              Expanded(
                // SingleChildScrollView chứ không phải ListView: nội dung dưới
                // màn vẫn phải tìm được bằng test.
                child: AsyncValueWidget<Deal>(
                  value: dealAsync,
                  onRetry: () => ref.invalidate(dealDetailProvider(dealId)),
                  data: (deal) => SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: AppGap.screen),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppGap.screen,
                          ),
                          child: _CustomerCard(deal: deal),
                        ),
                        const SizedBox(height: AppGap.betweenCards),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppGap.screen,
                          ),
                          child: _StageCard(deal: deal),
                        ),
                        const SizedBox(height: AppGap.xl),
                        // Không đệm ngang: dải tab con phải cuộn tràn hết bề
                        // ngang máy, đúng FilterChipBar.padding mặc định.
                        FilterChipBar(
                          labels: _MockData.subTabs,
                          selectedIndex: _selectedSubTabIndex,
                          onSelected: (i) =>
                              setState(() => _selectedSubTabIndex = i),
                        ),
                        const SizedBox(height: AppGap.betweenCards),
                        if (_selectedSubTabIndex == 0) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppGap.screen,
                            ),
                            child: _PaymentSlip(dealId: deal.id),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppGap.screen,
                            ),
                            child: SectionHeader(
                              'Trao đổi gần nhất',
                              actionLabel: 'Thêm ghi chú',
                              onAction: () {},
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppGap.screen,
                            ),
                            child: _RecentNoteCard(),
                          ),
                        ] else if (_selectedSubTabIndex == 1)
                          TaskListWidget(
                            entityType: TaskOwner.deal,
                            entityId: deal.id,
                            shrinkWrap: true,
                            // Same unbounded-height guard as `_PaymentSlip`
                            // above — see doc comment on
                            // `TaskListWidget.loadingWidget`.
                            loadingWidget: const SizedBox(
                              height: 160,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          )
                        else if (_selectedSubTabIndex == 2)
                          DealAttachmentsTab(dealId: deal.id)
                        else
                          DealActivityTab(dealId: deal.id),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bảng tuỳ chọn của thương vụ, mở từ nút ba chấm trên thanh tiêu đề. Hiện chỉ
/// có một lối đi: tạo hoá đơn với thương vụ và khách đã điền sẵn.
///
/// Dùng `showModalBottomSheet` chứ **không** `PopupMenuButton` hay `MenuAnchor`:
/// hai thứ đó tự dựng lấy nút bấm của chúng, làm đổi hình dáng thanh tiêu đề và
/// kéo theo style Material lệch bản phác thảo. Sheet chỉ dựng nội dung *khi mở*
/// nên cây widget mặc định của màn không đổi một widget nào — ảnh vàng MÀN 05
/// và phép đếm "đúng 3 `IconButtonBox`" giữ nguyên.
Future<void> _showDealMenu(BuildContext context, Deal deal) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
    ),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppGap.screen,
        AppGap.sectionTop,
        AppGap.screen,
        AppGap.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SectionLabel('Tuỳ chọn thương vụ'),
          const SizedBox(height: AppGap.sectionBottom),
          _SheetOption(
            icon: SoloIcons.cash,
            label: 'Tạo hóa đơn',
            // Đóng bảng trước rồi mới đẩy màn mới, để nút quay lại của màn tạo
            // hoá đơn trả người dùng về đúng chi tiết thương vụ chứ không về
            // một bảng đang mở dở.
            onTap: () {
              Navigator.pop(sheetContext);
              context.push(
                '${RouteNames.invoices}/new',
                extra: InvoiceFormArgs(
                  dealId: deal.id,
                  clientId: deal.clientId,
                  clientName: deal.clientName,
                  dealTitle: deal.title,
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

/// Bảng chọn giai đoạn kế tiếp, mở từ chip "Đổi giai đoạn". Cùng lý do chọn
/// `showModalBottomSheet` như [_showDealMenu]; cũng không
/// `DraggableScrollableSheet` vì màn này có quy tắc "không thành phần kéo thả
/// nào" và bảng chỉ có một hai dòng, không có gì để kéo.
Future<void> _showStageSheet(BuildContext context, WidgetRef ref, Deal deal) {
  final nextStages = deal.stage.nextStages;
  // `DealStage.lost` nằm trong `nextStages` của *mọi* giai đoạn chưa kết thúc,
  // và nó là bước không quay lại được. Tách khỏi các bước tiến, đẩy xuống dưới
  // đường xé và tô nhạt để không ai bấm nhầm "Đã mất" khi đang tìm bước sau.
  final forward = nextStages.where((stage) => stage != DealStage.lost).toList();
  final canLose = nextStages.contains(DealStage.lost);

  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
    ),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppGap.screen,
        AppGap.sectionTop,
        AppGap.screen,
        AppGap.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (nextStages.isEmpty)
            const Text(
              'Thương vụ đã ở trạng thái kết thúc.',
              style: AppText.sub,
            )
          else ...[
            const SectionLabel('Chuyển sang'),
            const SizedBox(height: AppGap.sectionBottom),
            for (final target in forward)
              _SheetOption(
                icon: SoloIcons.check,
                label: target.label,
                onTap: () => _applyStage(sheetContext, ref, deal, target),
              ),
            if (canLose) ...[
              // `bleed: 0` vì bảng tự có padding ngang riêng, không phải thẻ.
              const PerforatedDivider(bleed: 0),
              _SheetOption(
                icon: SoloIcons.clock,
                label: DealStage.lost.label,
                muted: true,
                onTap: () =>
                    _applyStage(sheetContext, ref, deal, DealStage.lost),
              ),
            ],
          ],
        ],
      ),
    ),
  );
}

/// Đóng bảng **trước**, rồi mới gửi lệnh chuyển giai đoạn: SnackBar báo lỗi do
/// `ref.listen` ở [DealDetailPage] dựng lên sẽ bị bảng che nếu bảng còn mở.
///
/// Không cần `await`: `DealStageController` tự `invalidate`
/// `dealDetailProvider`, nên màn tự vẽ lại khi có kết quả.
void _applyStage(
  BuildContext sheetContext,
  WidgetRef ref,
  Deal deal,
  DealStage target,
) {
  Navigator.pop(sheetContext);
  ref
      .read(dealStageControllerProvider.notifier)
      .transition(
        dealId: deal.id,
        currentStage: deal.stage,
        targetStage: target,
      );
}

/// Một dòng chạm được trong bảng chọn: icon, nhãn, mũi chevron.
///
/// `InkWell` được ở đây (khác với dòng lịch thanh toán) vì bảng do
/// `showModalBottomSheet` dựng luôn có `Material` tổ tiên, và nội dung bảng
/// không nằm trong ảnh vàng nên thêm một lớp vẽ cũng không lệch pixel nào.
class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.muted = false,
  });

  final SoloIconData icon;
  final String label;
  final VoidCallback onTap;

  /// Tô nhạt cho lựa chọn không quay lại được ("Đã mất").
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final color = muted ? AppColors.ink3 : AppColors.ink;

    return InkWell(
      borderRadius: AppRadius.cardAll,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppGap.card,
          vertical: AppGap.lg,
        ),
        child: Row(
          children: [
            SoloIcon(icon, label: null, size: SoloIcon.sm, color: color),
            const SizedBox(width: AppGap.row),
            Expanded(
              child: Text(
                label,
                style: AppText.bodyStrong.copyWith(color: color),
              ),
            ),
            const SoloIcon(
              SoloIcons.chevron,
              label: null,
              size: SoloIcon.xs,
              color: AppColors.ink3,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sáu giai đoạn hướng-tiến của pipeline, đúng thứ tự bản web. Lặp lại thủ công
/// vì `DealStageX.canTransitionTo` trong domain giữ danh sách này ở biến cục bộ
/// (`order`), không expose ra thành API công khai để tái dùng ở đây.
/// `DealStage.lost` cố ý không có mặt: nó là điểm dừng của thương vụ, không
/// phải bước thứ bảy của pipeline.
const List<DealStage> _pipelineStages = [
  DealStage.newLead,
  DealStage.qualified,
  DealStage.proposalSent,
  DealStage.inNegotiation,
  DealStage.active,
  DealStage.completedAndBilled,
];

/// Chữ cái đầu để vẽ avatar từ tên khách thật, bỏ qua vài tiền tố loại hình
/// doanh nghiệp Việt Nam hay gặp (để "Cty TNHH Minh An" ra "MA" thay vì "CT").
const List<String> _kCompanyPrefixes = ['CTY', 'CÔNG', 'TY', 'TNHH', 'DNTN'];

String _initialsOf(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => !_kCompanyPrefixes.contains(word.toUpperCase()))
      .toList();
  if (words.isEmpty) return '?';
  final picked = words.length == 1
      ? [words.first]
      : words.sublist(words.length - 2);
  return picked.map((word) => word[0].toUpperCase()).join();
}

/// Thẻ khách hàng đầu màn: avatar, tên công ty, người liên hệ, nút nhắn Zalo,
/// rồi giá trị hợp đồng. Giá trị hợp đồng dùng `Tone.neutral` vì đây là số
/// *tham chiếu*, không phải công nợ đang phải đòi (quy tắc 3 `AGENTS.md`).
class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context) {
    final customerName = deal.clientName ?? _MockData.fallbackCustomerName;
    final contractValue = deal.actualValue ?? deal.estimatedValue ?? 0;

    return Card(
      child: Padding(
        // Bản phác thảo ghi đè padding thẻ này thành 15px thay vì 14 mặc định
        // của `.card`. Dùng lại AppGap.slip (đúng giá trị 15) thay vì viết
        // cứng — token này vốn đặt tên theo SlipCard nhưng con số khớp.
        padding: const EdgeInsets.all(AppGap.slip),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Avatar.initials(
                  _initialsOf(customerName),
                  tone: Tone.money,
                  size: Avatar.md,
                ),
                const SizedBox(width: AppGap.row),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(customerName, style: AppText.bodyStrongLg),
                      // CHƯA NỐI API — `Deal` không có tên người liên hệ hay số
                      // điện thoại; giữ dữ liệu giả đúng bản phác thảo.
                      const Text(_MockData.contactInfo, style: AppText.mut),
                    ],
                  ),
                ),
                const SizedBox(width: AppGap.row),
                const IconButtonBox(
                  SoloIcons.send,
                  label: 'Nhắn Zalo',
                  tone: Tone.ok,
                  visualSize: 34,
                ),
              ],
            ),
            const PerforatedDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(child: SectionLabel('Giá trị hợp đồng')),
                Money.card(contractValue, tone: Tone.neutral),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Card giai đoạn: sáu vạch tiến độ, dòng trạng thái hiện tại, và chip đổi
/// giai đoạn.
class _StageCard extends StatelessWidget {
  const _StageCard({required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context) {
    final isLost = deal.stage == DealStage.lost;
    // 0 nếu giai đoạn không nằm trong sáu bước hướng-tiến (tức `lost`).
    final step = _pipelineStages.indexOf(deal.stage) + 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppGap.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SectionLabel('Giai đoạn'),
            const SizedBox(height: AppGap.lg),
            StageBar.steps(filledSteps: isLost ? 0 : step),
            const SizedBox(height: AppGap.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isLost
                        ? deal.stage.label
                        : '${deal.stage.label} · bước $step/6',
                    style: AppText.bodyStrong.copyWith(
                      color: isLost ? AppColors.ink3 : AppColors.jade,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppGap.sm),
                _ChangeStageChip(deal: deal),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip "Đổi giai đoạn". Bấm sẽ mở bảng chọn giai đoạn ([_showStageSheet]) —
/// không kéo thả (quy tắc 4 `AGENTS.md`).
///
/// Chip vẫn là `StatusChip` trung tính không tham số: nó chỉ là *nhãn* của một
/// lối đi, phần bấm được nằm ở `GestureDetector` bọc ngoài. Đổi tone theo trạng
/// thái gửi sẽ biến nó thành nút, sai với quy ước màu của bản phác thảo — nên
/// lúc đang gửi thì khoá bằng `onTap: null` chứ không đổi màu.
class _ChangeStageChip extends ConsumerWidget {
  const _ChangeStageChip({required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = ref.watch(dealStageControllerProvider).isLoading;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isBusy ? null : () => _showStageSheet(context, ref, deal),
      child: Semantics(
        button: true,
        label: 'Đổi giai đoạn',
        child: const StatusChip('Đổi giai đoạn'),
      ),
    );
  }
}

/// Nạp danh sách hoá đơn của thương vụ (`dealInvoicesProvider`) rồi vẽ tờ
/// phiếu lịch thanh toán.
class _PaymentSlip extends ConsumerWidget {
  const _PaymentSlip({required this.dealId});

  final String dealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(dealInvoicesProvider(dealId));

    return AsyncValueWidget<List<Invoice>>(
      value: invoicesAsync,
      onRetry: () => ref.invalidate(dealInvoicesProvider(dealId)),
      // `LoadingShimmer` mặc định dựng `ListView`, cần chiều cao giới hạn —
      // khối này lại nằm trong `SingleChildScrollView` không giới hạn chiều
      // cao con, nên phải tự cấp một khung chờ có chiều cao cố định thay vì
      // dùng mặc định của `AsyncValueWidget`.
      loadingWidget: const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      ),
      data: (invoices) => _PaymentSlipContent(invoices: invoices),
    );
  }
}

/// Tờ phiếu lịch thanh toán. `SlipCard` vì đây đúng là tiền (quy tắc 3): đợt
/// đã thu tô ngọc, đợt quá hạn tô hồng kèm con dấu, đợt chưa tới tô xám —
/// đúng ba trạng thái figcaption nêu. Mỗi dòng ứng với một hoá đơn thật của
/// thương vụ thay vì ba đợt cố định như bản phác thảo tĩnh.
class _PaymentSlipContent extends StatelessWidget {
  const _PaymentSlipContent({required this.invoices});

  final List<Invoice> invoices;

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return const SlipCard(
        notch: 76,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SectionLabel('Lịch thanh toán'),
            SizedBox(height: AppGap.lg),
            Text('Chưa có hóa đơn nào cho thương vụ này.', style: AppText.sub),
          ],
        ),
      );
    }

    final overdue = invoices.where((invoice) => invoice.isOverdue).toList();
    final allPaid = invoices.every(
      (invoice) => invoice.status == InvoiceStatus.paid,
    );

    return SlipCard(
      notch: 76,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: SectionLabel('Lịch thanh toán')),
              if (overdue.isNotEmpty) ...[
                const SizedBox(width: AppGap.sm),
                StampBadge.due(
                  overdue.length == 1
                      ? '${overdue.first.invoiceNumber} quá hạn'
                      : '${overdue.length} hóa đơn quá hạn',
                ),
              ] else if (allPaid) ...[
                const SizedBox(width: AppGap.sm),
                const StampBadge.paid('Đã thu đủ'),
              ],
            ],
          ),
          const SizedBox(height: AppGap.lg),
          for (var i = 0; i < invoices.length; i++) ...[
            _paymentRowFor(
              invoices[i],
              () => context.push('${RouteNames.invoices}/${invoices[i].id}'),
            ),
            if (i < invoices.length - 1) const SizedBox(height: AppGap.sm),
          ],
          if (overdue.isNotEmpty) ...[
            const PerforatedDivider(),
            SizedBox(
              width: double.infinity,
              child: _MoMoLinkButton(
                invoiceNumber: overdue.first.invoiceNumber,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Suy ra icon/màu/nhãn của một dòng lịch thanh toán từ trạng thái hoá đơn
/// thật: đã thanh toán → ngọc, quá hạn → hồng đậm, còn lại (nháp/đã gửi/thanh
/// toán một phần chưa tới hạn) → xám, giữ đúng ba tông màu figcaption nêu.
///
/// [onTap] mở chi tiết hoá đơn — mỗi dòng ở đây là một hoá đơn thật, nên chạm
/// vào nó phải đi được tới nó.
Widget _paymentRowFor(Invoice invoice, VoidCallback onTap) {
  if (invoice.status == InvoiceStatus.paid) {
    return _PaymentRow(
      icon: SoloIcons.check,
      iconColor: AppColors.jade,
      label: 'Hóa đơn ${invoice.invoiceNumber} · Đã thanh toán',
      labelStyle: AppText.sub.copyWith(color: AppColors.ink),
      amount: Money.inline(invoice.total, tone: Tone.ok),
      onTap: onTap,
    );
  }

  if (invoice.isOverdue) {
    return _PaymentRow(
      icon: SoloIcons.clock,
      iconColor: AppColors.momo,
      label: 'Hóa đơn ${invoice.invoiceNumber} · Quá hạn',
      labelStyle: AppText.sub.copyWith(
        color: AppColors.momo,
        fontWeight: FontWeight.w600,
      ),
      amount: Money.inline(invoice.total, tone: Tone.money),
      onTap: onTap,
    );
  }

  return _PaymentRow(
    icon: null,
    iconColor: null,
    label: 'Hóa đơn ${invoice.invoiceNumber} · ${invoice.status.label}',
    labelStyle: AppText.sub.copyWith(color: AppColors.ink3),
    onTap: onTap,
    // Đợt chưa tới hạn: `Money` ép số trung tính về màu mực chính để dễ đọc,
    // nhưng figcaption đòi màu xám cho đợt "chưa tới". Dùng `Money.format` để
    // giữ đúng định dạng tiền Việt, rồi vẽ bằng `MonoText` với màu ink3 mà
    // `Money` không cung cấp được.
    amount: MonoText(Money.format(invoice.total), color: AppColors.ink3),
  );
}

/// Một dòng trong lịch thanh toán: icon trạng thái, nhãn đợt, và số tiền.
///
/// Vùng chạm dựng bằng `GestureDetector` chứ **không** `InkWell`: dòng này nằm
/// trong `SlipCard`, không chắc có `Material` tổ tiên phù hợp, và `InkWell` còn
/// chèn thêm một lớp vẽ gợn nước — đủ để ảnh vàng lệch pixel.
/// `GestureDetector` không vẽ gì.
class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.labelStyle,
    required this.amount,
    this.onTap,
  });

  final SoloIconData? icon;
  final Color? iconColor;
  final String label;
  final TextStyle labelStyle;
  final Widget amount;

  /// Mở chi tiết hoá đơn của dòng này.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (icon != null)
                  SoloIcon(
                    icon!,
                    label: null,
                    size: SoloIcon.xs,
                    color: iconColor!,
                  )
                else
                  const SizedBox(width: SoloIcon.xs),
                const SizedBox(width: AppGap.sm),
                Expanded(
                  child: Text(
                    label,
                    style: labelStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          amount,
        ],
      ),
    );
  }
}

/// Nút tạo link MoMo cho hoá đơn đang quá hạn.
///
/// CHƯA NỐI API — chỉ tạo link thanh toán thật khi có usecase riêng; nút hiện
/// chưa gọi hành động nào (`onPressed` rỗng), ngoài phạm vi "Dữ liệu" của
/// màn này.
class _MoMoLinkButton extends StatelessWidget {
  const _MoMoLinkButton({required this.invoiceNumber});

  final String invoiceNumber;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {},
      style: AppTheme.filled(tone: Tone.money, small: true),
      icon: const SoloIcon(
        SoloIcons.cash,
        label: null,
        size: SoloIcon.xs,
        color: AppColors.surface,
      ),
      label: Text('Tạo link MoMo cho hóa đơn $invoiceNumber'),
    );
  }
}

/// Ghi chú gần nhất — `Card` thường vì nội dung không liên quan tiền.
///
/// CHƯA NỐI API — `Deal` không có lịch sử trao đổi/ghi chú giọng nói; giữ dữ
/// liệu giả đúng bản phác thảo.
class _RecentNoteCard extends StatelessWidget {
  const _RecentNoteCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppGap.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_MockData.noteText, style: AppText.sub),
            SizedBox(height: AppGap.sm),
            Text(_MockData.noteMeta, style: AppText.mut),
          ],
        ),
      ),
    );
  }
}

/// Dữ liệu giả cho những chỗ `Deal`/`Invoice` chưa có trường tương ứng. Là
/// class chứ không phải record vì Dart không cho đọc field của record trong
/// biểu thức `const`, mà widget của màn này phải const được. Tên viết hoa theo
/// lint `camel_case_types` của repo.
abstract final class _MockData {
  /// CHƯA NỐI API — `Deal.clientName` có thể null; đây là tên hiển thị dự
  /// phòng khi backend chưa gán khách hàng cho deal.
  static const String fallbackCustomerName = 'Khách hàng chưa đặt tên';

  /// CHƯA NỐI API — `Deal` không có tên người liên hệ hay số điện thoại.
  static const String contactInfo = 'Chị Hạnh · 0903 xxx 118';

  /// Bốn tab con, mỗi tab (trừ Tổng quan) nối provider thật của riêng nó:
  /// `TaskListWidget` (Dự án), `DealAttachmentsTab`, `DealActivityTab`. Gộp
  /// "Tài liệu"/"File" của bản phác thảo gốc thành một tab duy nhất vì backend
  /// chỉ có một cơ chế đính kèm nhiều-file (`/deals/{id}/attachments`) — cơ chế
  /// một-file cũ (`/deals/{id}/document`) không có UI riêng ở đây.
  static const List<String> subTabs = ['Tổng quan', 'Dự án', 'Tài liệu', 'Lịch sử'];

  /// CHƯA NỐI API — `Deal` không lưu lịch sử trao đổi/ghi chú giọng nói.
  static const String noteText =
      'Chị Hạnh xin lùi duyệt nháp sang tuần sau, sẽ chuyển cọc đợt 2 vào '
      'thứ Hai.';
  static const String noteMeta = 'Ghi qua giọng nói · 19/07';
}
