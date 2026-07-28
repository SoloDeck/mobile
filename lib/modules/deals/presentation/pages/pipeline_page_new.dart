import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/value_objects/pipeline_summary.dart';
import 'package:solodesk_mobile/modules/deals/presentation/providers/deals_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/avatar.dart';
import 'package:solodesk_mobile/ui/filter_chip_bar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/mono_text.dart';
import 'package:solodesk_mobile/ui/money.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/stage_bar.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// MÀN 04 — Pipeline theo giai đoạn.
///
/// Chuyển từ `lib/features/pipeline/pipeline_screen.dart` sang module `deals`,
/// nối dữ liệu thật thay cho dữ liệu giả cố định. Đối chiếu: khối `MÀN 04`
/// (dòng 435-510) trong `design/solodesk-mobile-ui.html`, gồm cả
/// `<figcaption>`.
///
/// Bốn quyết định gốc trong figcaption, đừng đảo lại khi sửa:
/// - Sáu giai đoạn Kanban đổi thành **thanh chip cuộn ngang** (`FilterChipBar`)
///   — đổi giai đoạn bằng cách chạm chip, không kéo thả thẻ giữa các cột (quy
///   tắc 4).
/// - Thanh vạch màu dưới dải chip (`StageBar.proportional`) là **hình dáng cả
///   pipeline**: bề rộng mỗi vạch tỉ lệ với số deal đang đứng ở giai đoạn đó.
/// - Deal nguội mờ dần theo mức độ nguội (`Opacity` giảm dần).
/// - Giá trị ước tính hiện **ngay trên mỗi thẻ**, không ẩn sau một lượt chạm.
///
/// Nối dữ liệu thật:
/// - `dealPipelineProvider` → số đếm mỗi giai đoạn, dùng cho nhãn
///   `FilterChipBar` và bề rộng từng vạch của `StageBar.proportional`.
///   `StageBar` chỉ vẽ đúng sáu vạch (`StageBar.stageCount`), còn `DealStage`
///   có bảy giá trị (gồm cả `lost`) — giai đoạn `lost` bị loại khỏi dải trước
///   khi truyền vào, vì deal đã mất coi như đã ra khỏi pipeline đang chạy chứ
///   không phải một bước tiến của nó.
/// - `dealListProvider` → danh sách thẻ deal bên dưới. Tiêu đề thẻ ← `title`,
///   dòng phụ ← `clientName`, số tiền ← `estimatedValue` (rơi về `actualValue`
///   nếu thiếu), "Vào N ngày trước" ← `createdAt`.
///
/// CHƯA NỐI API — `Deal` không có field độ nóng ("🔥 Hot" / "Ấm" / "Nguội")
/// hay lý do đứng yên ("Trả giá gắt"). Phần đó vẫn lấy từ `_heatFor`, lặp lại
/// bốn kiểu mock theo thứ tự danh sách chỉ để giữ đúng hình dáng bản phác
/// thảo; khi backend có điểm số độ nóng deal thật, thay bằng dữ liệu đó.
class PipelinePage extends ConsumerStatefulWidget {
  const PipelinePage({super.key});

  @override
  ConsumerState<PipelinePage> createState() => _PipelinePageState();
}

class _PipelinePageState extends ConsumerState<PipelinePage> {
  // Giai đoạn đang được chọn trên `FilterChipBar` — mặc định giai đoạn đầu
  // ("Khách mới") để giữ nguyên hành vi lần mở màn đầu tiên.
  int _selectedStageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pipeline = ref.watch(dealPipelineProvider);
    final deals = ref.watch(dealListProvider);
    final combined = _combine(pipeline, deals);
    final appearance = ref.watch(appearanceControllerProvider);

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        // Thanh tab do `AppShell` dựng một lần cho cả bốn màn gốc — màn này
        // không tự đặt `SoloNavBar` nữa, nếu không sẽ có hai thanh chồng nhau.
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SoloAppBar(
                title: _MockData.title,
                actions: [
                  IconButtonBox(SoloIcons.search, label: 'Tìm kiếm'),
                  IconButtonBox(SoloIcons.tag, label: 'Lọc theo thẻ'),
                ],
              ),
              Expanded(
                child: AsyncValueWidget<(List<StageSummary>, List<Deal>)>(
                  value: combined,
                  onRetry: () {
                    ref.invalidate(dealPipelineProvider);
                    ref.invalidate(dealListProvider);
                  },
                  data: (data) => _PipelineBody(
                    summaries: data.$1,
                    deals: data.$2,
                    selectedIndex: _selectedStageIndex,
                    onStageSelected: (index) =>
                        setState(() => _selectedStageIndex = index),
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

/// Gộp hai `AsyncValue` độc lập thành một, để cả phần chip lọc/thanh vạch và
/// phần danh sách thẻ deal cùng chờ/lỗi/hiện theo một nhịp duy nhất thay vì
/// hai vùng loading riêng lẻ nhấp nháy lệch nhau.
AsyncValue<(List<StageSummary>, List<Deal>)> _combine(
  AsyncValue<List<StageSummary>> pipeline,
  AsyncValue<List<Deal>> deals,
) {
  if (pipeline.hasError) {
    return AsyncValue.error(pipeline.error!, pipeline.stackTrace!);
  }
  if (deals.hasError) {
    return AsyncValue.error(deals.error!, deals.stackTrace!);
  }
  if (pipeline.hasValue && deals.hasValue) {
    return AsyncValue.data((pipeline.value!, deals.value!));
  }
  return const AsyncValue.loading();
}

/// Thân màn sau khi cả hai provider đã có dữ liệu: dải chip lọc, thanh vạch
/// tỉ trọng, và danh sách thẻ deal cuộn dọc.
class _PipelineBody extends StatelessWidget {
  const _PipelineBody({
    required this.summaries,
    required this.deals,
    required this.selectedIndex,
    required this.onStageSelected,
  });

  final List<StageSummary> summaries;
  final List<Deal> deals;

  /// Vị trí chip giai đoạn đang chọn — chỉ số này khớp 1:1 với `activeStages`
  /// bên dưới (thứ tự `DealStage.values` sau khi loại `lost`), vì cả hai đều
  /// dựng từ cùng danh sách `summaries`.
  final int selectedIndex;
  final ValueChanged<int> onStageSelected;

  @override
  Widget build(BuildContext context) {
    final activeStages = summaries
        .where((summary) => summary.stage != DealStage.lost)
        .toList();
    final stageLabels = [
      for (final summary in activeStages)
        '${summary.stage.label} · ${summary.count}',
    ];
    final stageWeights = [for (final summary in activeStages) summary.count];

    // `selectedIndex` chọn giai đoạn đang lọc; kẹp lại phòng khi
    // `activeStages` đổi độ dài giữa hai lần build (ví dụ dữ liệu tải lại).
    final clampedIndex = activeStages.isEmpty
        ? 0
        : selectedIndex.clamp(0, activeStages.length - 1);
    final selectedStage = activeStages.isEmpty
        ? null
        : activeStages[clampedIndex].stage;
    final filteredDeals = selectedStage == null
        ? deals
        : deals.where((deal) => deal.stage == selectedStage).toList();

    final totalEstimate = filteredDeals.fold<double>(
      0,
      (sum, deal) => sum + (deal.estimatedValue ?? deal.actualValue ?? 0),
    );

    return Column(
      children: [
        FilterChipBar(
          labels: stageLabels,
          selectedIndex: clampedIndex,
          onSelected: onStageSelected,
        ),
        const SizedBox(height: AppGap.xs),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppGap.screen,
            0,
            AppGap.screen,
            AppGap.lg,
          ),
          child: StageBar.proportional(weights: stageWeights),
        ),
        Expanded(
          child: filteredDeals.isEmpty
              ? const _EmptyPipeline()
              // SingleChildScrollView chứ không phải ListView: nội dung dưới
              // màn (deal nguội cuối danh sách) vẫn phải kiểm tra được bằng
              // test.
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppGap.screen,
                    0,
                    AppGap.screen,
                    AppGap.navBarInset,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PipelineTotalRow(
                        dealCount: filteredDeals.length,
                        totalEstimate: totalEstimate,
                      ),
                      const SizedBox(height: AppGap.betweenCards),
                      for (var i = 0; i < filteredDeals.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppGap.betweenCards),
                        _LeadCard(deal: filteredDeals[i], heat: _heatFor(i)),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

/// Trạng thái rỗng: chưa có thương vụ nào trong pipeline.
class _EmptyPipeline extends StatelessWidget {
  const _EmptyPipeline();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppGap.screen),
        child: Text(
          'Chưa có thương vụ nào trong pipeline.',
          style: AppText.mut,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Dòng tóm tắt trên đầu danh sách deal: tổng số deal hiện có và tổng giá trị
/// ước tính.
///
/// Cố ý tô hồng (`Tone.money`) dù đây là tổng **ước tính**, không phải công nợ
/// đã chốt — khác quy tắc chung "chỉ tiền đang phải đòi mới hồng". Bản phác
/// thảo gốc (dòng ~460 của khối MÀN 04) khai màu `color:var(--momo)` tường
/// minh cho đúng con số này: với freelancer, tổng giá trị đang đàm phán trong
/// pipeline cũng là tiền họ đang tìm cách chốt về.
class _PipelineTotalRow extends StatelessWidget {
  const _PipelineTotalRow({
    required this.dealCount,
    required this.totalEstimate,
  });

  final int dealCount;
  final double totalEstimate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SectionLabel('$dealCount lead · tổng ước tính')),
        const SizedBox(width: AppGap.row),
        Money.inline(totalEstimate, tone: Tone.money),
      ],
    );
  }
}

/// Một thẻ deal trong danh sách pipeline: avatar + tên việc/khách, chip trạng
/// thái, giá trị ước tính, dòng chú thích.
class _LeadCard extends StatelessWidget {
  const _LeadCard({required this.deal, required this.heat});

  final Deal deal;
  final _HeatMockup heat;

  @override
  Widget build(BuildContext context) {
    final estimate = deal.estimatedValue ?? deal.actualValue;
    final daysAgo = DateTime.now().difference(deal.createdAt).inDays;

    return Opacity(
      opacity: heat.opacity,
      // `clipBehavior` + `InkWell` **bên trong** `Card`: gợn mực phải bị cắt
      // theo góc bo của thẻ, đặt ngoài `Card` thì nó tràn ra bốn góc vuông.
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          // Cả thẻ là một vùng chạm duy nhất mở MÀN 05 — không có nút nhỏ
          // riêng bên trong, nên vùng chạm luôn vượt xa mức tối thiểu 44 × 44
          // pt (quy tắc vùng chạm trong `.claude/rules/flutter-ui.md`).
          onTap: () => context.push('${RouteNames.deals}/${deal.id}'),
          child: Padding(
            padding: const EdgeInsets.all(AppGap.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _LeadHeader(
                  avatar: Avatar.initials(
                    _initialsOf(deal),
                    tone: heat.avatarTone,
                  ),
                  title: deal.title,
                  subtitle: deal.clientName ?? 'Chưa gắn khách hàng',
                  trailing: StatusChip(heat.chipLabel, tone: heat.chipTone),
                ),
                const SizedBox(height: AppGap.lg),
                Row(
                  children: [
                    MonoText(
                      estimate == null ? '—' : '~${Money.format(estimate)}',
                    ),
                    const SizedBox(width: AppGap.row),
                    Expanded(
                      child: Text(
                        'Vào $daysAgo ngày trước',
                        style: AppText.mut,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chữ viết tắt cho avatar: chữ cái đầu của hai từ đầu tiên trong tên khách
/// ("Ngọc Linh Shop" → "NL"), rơi về chữ cái đầu tiêu đề việc nếu deal chưa
/// gắn khách hàng.
String _initialsOf(Deal deal) {
  final client = deal.clientName?.trim();
  if (client == null || client.isEmpty) {
    final title = deal.title.trim();
    return title.isEmpty ? '—' : title.substring(0, 1).toUpperCase();
  }
  final words = client
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
  return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
}

/// Hàng avatar + hai dòng chữ + phần đuôi tuỳ chọn — cùng hình dáng với
/// `_TaskHeader` của MÀN 02 và `_TemplateHeader` của MÀN 14. Để private vì
/// đây đã là lần dựng thứ ba của đúng bố cục này; ghi vào báo cáo cuối để cân
/// nhắc nâng lên `lib/ui/`.
class _LeadHeader extends StatelessWidget {
  const _LeadHeader({
    required this.avatar,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final Widget avatar;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        avatar,
        const SizedBox(width: AppGap.row),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppText.bodyStrong),
              Text(subtitle, style: AppText.mut),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: AppGap.row), trailing!],
      ],
    );
  }
}

/// Một kiểu "độ nóng" deal mock: màu avatar, nhãn + tông chip, và độ mờ của
/// cả thẻ. Xem doc comment của [_heatFor] — `Deal` chưa có field nào cho việc
/// này.
class _HeatMockup {
  const _HeatMockup({
    required this.avatarTone,
    required this.chipLabel,
    required this.chipTone,
    required this.opacity,
  });

  final Tone avatarTone;
  final String chipLabel;
  final Tone chipTone;
  final double opacity;
}

/// CHƯA NỐI API — `Deal` không có field độ nóng lead hay lý do đứng yên. Bốn
/// kiểu dưới đây lặp lại theo thứ tự danh sách (`index % 4`) chỉ để giữ đúng
/// hình dáng bản phác thảo (chip trạng thái + độ mờ giảm dần theo card); khi
/// backend có điểm số độ nóng deal thật, thay hàm này bằng dữ liệu đó.
_HeatMockup _heatFor(int index) => switch (index % 4) {
  0 => const _HeatMockup(
    avatarTone: Tone.ok,
    chipLabel: 'Chưa chấm',
    chipTone: Tone.ai,
    opacity: 1,
  ),
  1 => const _HeatMockup(
    avatarTone: Tone.money,
    chipLabel: '🔥 Hot',
    chipTone: Tone.money,
    opacity: 1,
  ),
  2 => const _HeatMockup(
    avatarTone: Tone.warn,
    chipLabel: 'Ấm',
    chipTone: Tone.warn,
    opacity: 0.94,
  ),
  _ => const _HeatMockup(
    avatarTone: Tone.neutral,
    chipLabel: 'Nguội',
    chipTone: Tone.neutral,
    opacity: 0.72,
  ),
};

/// Phần dữ liệu vẫn còn cố định — chỉ tiêu đề màn, vì backend không có field
/// nào khác cần mock ở đây (số đếm giai đoạn và danh sách deal đều đã nối
/// provider thật).
abstract final class _MockData {
  static const String title = 'Pipeline';
}
