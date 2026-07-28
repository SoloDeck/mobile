import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/modules/analytics/domain/entities/dashboard_summary.dart';
import 'package:solodesk_mobile/modules/analytics/presentation/providers/analytics_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/mono_text.dart';
import 'package:solodesk_mobile/ui/money.dart';
import 'package:solodesk_mobile/ui/perforated_divider.dart';
import 'package:solodesk_mobile/ui/progress_bar.dart';
import 'package:solodesk_mobile/ui/section_header.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// MÀN 11 — Doanh thu.
///
/// Đối chiếu: khối `<figure class="unit">` chứa `MÀN 11` trong
/// `design/solodesk-mobile-ui.html` (dòng 907–962), gồm cả `<figcaption>`.
///
/// Bốn quyết định trong figcaption, đừng đảo lại khi sửa:
/// - Tấm phiếu lớn nhất màn hình dành cho **số tiền đã thu thật**, không phải
///   doanh thu ghi nhận. HTML dòng 915 `.num` **không khai màu** nên nó thừa
///   hưởng `--ink` — đúng là `Tone.neutral` (mực), không phải `Tone.ok` (ngọc).
///   Doc comment của `Money` gọi đích danh MÀN 11 ở mục "tổng doanh thu đã thu"
///   cho `Tone.neutral`. Câu "số tiền đã thu thật" trong figcaption nói về
///   *nguồn dữ liệu*, không phải chỉ dẫn màu.
/// - Biểu đồ cột chỉ tô đậm **tháng hiện tại** (tháng 07, `AppColors.momo` đặc,
///   nhãn in đậm cùng màu); sáu tháng trước dùng `AppColors.momoSoft` — họ
///   hồng, vì tím (`aiSoft`/`ai`) theo quy tắc 2 chỉ dành cho nội dung AI chờ
///   duyệt, và MÀN 11 không có mảnh AI nào.
/// - Công nợ chia theo **tuổi nợ**, không theo khách: càng để lâu màu càng gắt
///   — trung tính (trong hạn) → hổ phách (quá 1–7 ngày) → hồng (quá trên 30
///   ngày).
/// - Chỉ hai chỉ số phụ (tỉ lệ chốt, deal trung bình) — không thêm chỉ số nào
///   khác để màn này không biến thành một bản báo cáo.
///
/// Đường xé `.perf` ở HTML dòng 917 ngăn khối số tiền với biểu đồ cột — thêm
/// bằng `PerforatedDivider()`, đúng như sáu `SlipCard` khác trong repo.
///
/// ## Dữ liệu
///
/// `ref.watch(dashboardSummaryProvider)` chỉ cấp bốn field (`totalClients`,
/// `activeDeals`, `totalRevenue`, `pendingInvoices`). Duy nhất `totalRevenue`
/// khớp trực tiếp — dùng cho "Đã thu · 7 tháng đầu năm", và **không đổi theo
/// năm chọn** vì backend chưa có bộ lọc năm cho endpoint này. Mọi số liệu
/// khác của màn này (biểu đồ 7 cột, so sánh cùng kỳ, số hợp đồng, tỉ lệ chốt,
/// deal trung bình, công nợ theo tuổi nợ) không có field nào cấp — xem
/// `_MockData` để biết chi tiết còn thiếu, và `_YearlyMockData` cho biến thể
/// theo năm của chỗ dữ liệu giả đó.
///
/// ## Chip chọn năm
///
/// `StatusChip` tự nó không có vùng chạm 44pt (xem doc comment của nó) nên
/// không đội `onTap` lên thẳng nó — bọc riêng bằng `_YearChip`, cùng khuôn
/// `Semantics(button: true)` + `GestureDetector` mà `IconButtonBox` dùng.
/// Chọn năm mở `_showYearPickerSheet`, cùng kiểu `showModalBottomSheet` với
/// `_showDealMenu` ở MÀN 05 (`useSafeArea: true`, bo góc trên `AppRadius.card`).
class RevenuePage extends ConsumerStatefulWidget {
  const RevenuePage({super.key});

  @override
  ConsumerState<RevenuePage> createState() => _RevenuePageState();
}

class _RevenuePageState extends ConsumerState<RevenuePage> {
  int _selectedYear = 2026;

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(dashboardSummaryProvider);
    final appearance = ref.watch(appearanceControllerProvider);
    final yearData = _MockData.forYear(_selectedYear);

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        // Bốn tab của `SoloNavBar` không đủ chỗ cho màn này, nên Doanh thu mở
        // ra từ tab "Tôi" và mang nút quay lại thay cho thanh tab.
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SoloAppBar(
                title: _MockData.title,
                titleSize: SoloAppBar.lg,
                leading: IconButtonBox(
                  SoloIcons.back,
                  label: 'Quay lại',
                  onTap: () => context.pop(),
                ),
                actions: [
                  _YearChip(
                    selectedYear: _selectedYear,
                    onYearSelected: (year) =>
                        setState(() => _selectedYear = year),
                  ),
                ],
              ),
              Expanded(
                child: AsyncValueWidget<DashboardSummary>(
                  value: summary,
                  onRetry: () => ref.invalidate(dashboardSummaryProvider),
                  data: (s) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppGap.screen,
                      0,
                      AppGap.screen,
                      AppGap.navBarInset,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CollectedSlip(
                          collectedAmount: s.totalRevenue,
                          yoyChip: yearData.yoyChip,
                          contractsChip: yearData.contractsChip,
                          monthHeights: yearData.monthHeights,
                        ),
                        const SizedBox(height: AppGap.row),
                        // IntrinsicHeight: `crossAxisAlignment.stretch` cần
                        // Row có chiều cao xác định để kéo giãn hai thẻ
                        // bằng nhau. Không có nó, Row nằm trong Column cao
                        // vô hạn của SingleChildScrollView và `hasSize`
                        // assert lúc dựng — đây là chỗ Row thật sự đổ,
                        // không phải biểu đồ cột (biểu đồ cũng được bọc
                        // SizedBox height cố định để không lặp lại lỗi
                        // tương tự).
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: _MockData.closeRateLabel,
                                  value: yearData.closeRateValue,
                                  caption: yearData.closeRateCaption,
                                ),
                              ),
                              const SizedBox(width: AppGap.row),
                              Expanded(
                                child: _StatCard(
                                  label: _MockData.avgDealLabel,
                                  value: yearData.avgDealValue,
                                  caption: yearData.avgDealCaption,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SectionHeader(
                          _MockData.agingSectionLabel,
                          actionLabel: _MockData.agingActionLabel,
                        ),
                        _DebtAgingCard(
                          onTimeAmount: yearData.onTimeAmount,
                          onTimeRatio: yearData.onTimeRatio,
                          overdueShortAmount: yearData.overdueShortAmount,
                          overdueShortRatio: yearData.overdueShortRatio,
                          overdueLongAmount: yearData.overdueLongAmount,
                          overdueLongRatio: yearData.overdueLongRatio,
                        ),
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

/// Vùng chạm bọc quanh `StatusChip` chọn năm ở góc phải `SoloAppBar`.
/// `StatusChip` không được thêm `onTap` (xem doc comment của nó — dùng chung
/// toàn app, không có vùng chạm 44pt) nên hành động bấm sống ở đây, cùng
/// khuôn `Semantics(button: true)` + `GestureDetector` mà `IconButtonBox`
/// dùng: hình vẽ giữ nguyên kích thước của chip, còn hộp bố cục nới ra tối
/// thiểu 44 × 44 bằng `ConstrainedBox`.
class _YearChip extends StatelessWidget {
  const _YearChip({required this.selectedYear, required this.onYearSelected});

  final int selectedYear;
  final ValueChanged<int> onYearSelected;

  /// Cạnh vùng chạm tối thiểu theo quy tắc tiếp cận — cùng giá trị với
  /// `IconButtonBox.tapTarget`.
  static const double _tapTarget = 44;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Chọn năm',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            _showYearPickerSheet(context, selectedYear, onYearSelected),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: _tapTarget,
            minHeight: _tapTarget,
          ),
          child: Center(
            child: StatusChip(
              '$selectedYear',
              trailingIcon: SoloIcons.chevron,
            ),
          ),
        ),
      ),
    );
  }
}

/// Bảng chọn năm, mở từ `_YearChip`. Cùng khuôn `showModalBottomSheet` với
/// `_showDealMenu` ở MÀN 05: `useSafeArea: true`, nền `AppColors.surface`,
/// bo góc trên `AppRadius.card`. Ba năm liệt kê cứng vì `_MockData.forYear`
/// hiện chỉ có dữ liệu giả cho 2024–2026 — thêm năm nào thì thêm dữ liệu giả
/// tương ứng ở đó trước.
Future<void> _showYearPickerSheet(
  BuildContext context,
  int selectedYear,
  ValueChanged<int> onYearSelected,
) {
  const years = [2024, 2025, 2026];

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
          const SectionLabel('Chọn năm'),
          const SizedBox(height: AppGap.sectionBottom),
          for (final year in years)
            _YearOption(
              year: year,
              selected: year == selectedYear,
              onTap: () {
                Navigator.pop(sheetContext);
                onYearSelected(year);
              },
            ),
        ],
      ),
    ),
  );
}

/// Một dòng năm trong bảng chọn năm. Năm đang chọn in đậm và có dấu tích —
/// trạng thái không truyền tải chỉ bằng màu.
class _YearOption extends StatelessWidget {
  const _YearOption({
    required this.year,
    required this.selected,
    required this.onTap,
  });

  final int year;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            Expanded(
              child: Text(
                '$year',
                style: AppText.bodyStrong.copyWith(
                  fontWeight: selected ? FontWeight.w700 : null,
                ),
              ),
            ),
            if (selected)
              const SoloIcon(
                SoloIcons.check,
                label: null,
                size: SoloIcon.xs,
                color: AppColors.momo,
              ),
          ],
        ),
      ),
    );
  }
}

/// Tấm phiếu tiền đã thu. Là `SlipCard` vì đúng là tiền — nhưng `Tone.neutral`
/// chứ không phải `Tone.ok`: đây là số **tham chiếu** tổng doanh thu đã thu,
/// không phải trạng thái "vừa được đánh dấu đã thu" của một khoản cụ thể như
/// MÀN 02. HTML không khai màu cho `.num` này nên nó thừa hưởng `--ink`.
///
/// [collectedAmount] đến từ `DashboardSummary.totalRevenue` — field duy nhất
/// của `dashboardSummaryProvider` khớp trực tiếp với dữ liệu màn này, và
/// **không đổi theo năm chọn** (xem doc comment của `RevenuePage`).
/// [yoyChip], [contractsChip] và [monthHeights] là dữ liệu giả, đổi theo năm
/// — xem `_YearlyMockData`.
class _CollectedSlip extends StatelessWidget {
  const _CollectedSlip({
    required this.collectedAmount,
    required this.yoyChip,
    required this.contractsChip,
    required this.monthHeights,
  });

  final double collectedAmount;
  final String yoyChip;
  final String contractsChip;
  final List<double> monthHeights;

  @override
  Widget build(BuildContext context) {
    return SlipCard(
      notch: 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SectionLabel(_MockData.collectedLabel),
          const SizedBox(height: AppGap.xs),
          Money.hero(collectedAmount, tone: Tone.neutral),
          const SizedBox(height: AppGap.md),
          Wrap(
            spacing: AppGap.xs,
            runSpacing: AppGap.xs,
            children: [
              StatusChip(yoyChip, tone: Tone.ok),
              StatusChip(contractsChip),
            ],
          ),
          const PerforatedDivider(),
          _MonthlyBarChart(monthHeights: monthHeights),
        ],
      ),
    );
  }
}

/// Biểu đồ cột 7 tháng đầu năm. Chỉ tháng hiện tại (tháng 07) tô đậm
/// `AppColors.momo` và nhãn in đậm cùng màu; sáu tháng trước dùng
/// `AppColors.momoSoft` làm nền so sánh, cố ý không tranh sự chú ý — đúng ý
/// figcaption. Cả bảy cột đều thuộc họ hồng (tiền), không dùng tím: tím theo
/// quy tắc 2 chỉ dành cho nội dung AI chờ duyệt, và biểu đồ này không phải AI.
///
/// Bọc `SizedBox(height:)` đúng bằng khung 78px của bản phác thảo
/// (`style="...height:78px..."` ở HTML dòng 918) để `Row` có chiều cao xác
/// định — không có nó, `Row` rơi vào ràng buộc cao vô hạn của
/// `SingleChildScrollView` phía ngoài và `hasSize` assert khi dựng.
///
/// Mỗi cột dựng bằng `Expanded` + `FractionallySizedBox` theo *tỉ lệ* chiều
/// cao dữ liệu ([monthHeights] chia cho cột cao nhất trong chính năm đang
/// chọn), không phải chép thẳng pixel HTML làm chiều cao cứng cho thanh cột:
/// chưa có font thật nên nhãn tháng (`AppText.mut`) đo bằng font thay thế cao
/// hơn ước tính của bản phác thảo, ghép với chiều cao cột cứng 60px sẽ tràn
/// đáy khung 78px. Chia theo tỉ lệ trong phần `Expanded` còn lại sau khi trừ
/// nhãn giữ đúng hình dạng biểu đồ mà luôn vừa khung, bất kể font nào đang
/// được dùng để đo. [monthHeights] là dữ liệu giả, đổi theo năm — xem
/// `_YearlyMockData`; nhãn tháng (`_MockData.monthLabels`) thì không đổi.
class _MonthlyBarChart extends StatelessWidget {
  const _MonthlyBarChart({required this.monthHeights});

  final List<double> monthHeights;

  @override
  Widget build(BuildContext context) {
    final tallest = monthHeights.reduce((a, b) => a > b ? a : b);

    return Semantics(
      label: 'Biểu đồ doanh thu 7 tháng đầu năm, tháng 07 là tháng hiện tại',
      child: SizedBox(
        height: _MockData.chartHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _MockData.monthLabels.length; i++) ...[
              if (i > 0) const SizedBox(width: AppGap.sm),
              Expanded(
                child: _MonthBar(
                  index: i,
                  height: monthHeights[i],
                  tallestHeight: tallest,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  const _MonthBar({
    required this.index,
    required this.height,
    required this.tallestHeight,
  });

  final int index;
  final double height;
  final double tallestHeight;

  @override
  Widget build(BuildContext context) {
    final isCurrent = index == _MockData.monthLabels.length - 1;
    // Tháng hiện tại: momo đặc. Sáu tháng trước: momoSoft — nền so sánh nhạt,
    // cố ý không tranh sự chú ý. Không dùng aiSoft (tím dành riêng cho AI chờ
    // duyệt) và không dùng momoLine (token viền, không phải token nền).
    final barColor = isCurrent ? AppColors.momo : AppColors.momoSoft;
    final heightFactor = height / tallestHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: heightFactor,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(AppRadius.checkbox),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppGap.xs),
        Text(
          _MockData.monthLabels[index],
          style: isCurrent
              ? AppText.mut.copyWith(
                  color: AppColors.momo,
                  fontWeight: FontWeight.w700,
                )
              : AppText.mut,
        ),
      ],
    );
  }
}

/// Một trong hai chỉ số phụ (`.card` thường). "41%" và "16,7 tr" là `.num`
/// trong HTML nhưng không phải tiền chính xác (tỉ lệ và số rút gọn) —
/// `MonoText`, không `Money`, và không phải `Text` trần.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppGap.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SectionLabel(label),
            const SizedBox(height: AppGap.xs),
            MonoText(value, style: AppText.numLg),
            Text(caption, style: AppText.mut),
          ],
        ),
      ),
    );
  }
}

/// Công nợ chia theo tuổi nợ. Ba hàng, màu càng gắt khi càng để lâu — đúng ý
/// figcaption "càng để lâu càng khó đòi". Toàn bộ số liệu là dữ liệu giả, đổi
/// theo năm — xem `_YearlyMockData`.
class _DebtAgingCard extends StatelessWidget {
  const _DebtAgingCard({
    required this.onTimeAmount,
    required this.onTimeRatio,
    required this.overdueShortAmount,
    required this.overdueShortRatio,
    required this.overdueLongAmount,
    required this.overdueLongRatio,
  });

  final int onTimeAmount;
  final double onTimeRatio;
  final int overdueShortAmount;
  final double overdueShortRatio;
  final int overdueLongAmount;
  final double overdueLongRatio;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppGap.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _DebtAgingRow(
              label: _MockData.onTimeLabel,
              amount: onTimeAmount,
              ratio: onTimeRatio,
              tone: Tone.neutral,
            ),
            const SizedBox(height: AppGap.lg),
            _DebtAgingRow(
              label: _MockData.overdueShortLabel,
              amount: overdueShortAmount,
              ratio: overdueShortRatio,
              tone: Tone.warn,
            ),
            const SizedBox(height: AppGap.lg),
            _DebtAgingRow(
              label: _MockData.overdueLongLabel,
              amount: overdueLongAmount,
              ratio: overdueLongRatio,
              tone: Tone.money,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtAgingRow extends StatelessWidget {
  const _DebtAgingRow({
    required this.label,
    required this.amount,
    required this.ratio,
    required this.tone,
    this.bold = false,
  });

  final String label;
  final int amount;
  final double ratio;
  final Tone tone;

  /// Chỉ nhóm "quá trên 30 ngày" in đậm nhãn — đúng bản phác thảo.
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final labelColor = tone == Tone.neutral ? null : tone.foreground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppText.sub.copyWith(
                  color: labelColor,
                  fontWeight: bold ? FontWeight.w600 : null,
                ),
              ),
            ),
            Money(amount, tone: tone, style: AppText.num),
          ],
        ),
        const SizedBox(height: AppGap.md),
        ProgressBar(value: ratio, color: tone.accent),
      ],
    );
  }
}

/// Nhóm số liệu giả biến theo năm chọn ở `_YearChip` — mọi field ở đây CHƯA
/// NỐI API, xem doc comment của `_MockData`. `monthHeights` dùng đơn vị tỉ lệ
/// tương đối như bản gốc, không phải tiền thật; `onTimeAmount`/
/// `overdueShortAmount`/`overdueLongAmount` là VNĐ nguyên; `onTimeRatio`/
/// `overdueShortRatio`/`overdueLongRatio` trong khoảng 0–1. Ba năm trong
/// `_MockData._byYear` chỉ để việc đổi năm có gì đó đổi theo — số nhỏ dần về
/// 2024, lớn dần về 2026, không có ý nghĩa tài chính thật.
class _YearlyMockData {
  const _YearlyMockData({
    required this.yoyChip,
    required this.contractsChip,
    required this.monthHeights,
    required this.closeRateValue,
    required this.closeRateCaption,
    required this.avgDealValue,
    required this.avgDealCaption,
    required this.onTimeAmount,
    required this.onTimeRatio,
    required this.overdueShortAmount,
    required this.overdueShortRatio,
    required this.overdueLongAmount,
    required this.overdueLongRatio,
  });

  final String yoyChip;
  final String contractsChip;
  final List<double> monthHeights;
  final String closeRateValue;
  final String closeRateCaption;
  final String avgDealValue;
  final String avgDealCaption;
  final int onTimeAmount;
  final double onTimeRatio;
  final int overdueShortAmount;
  final double overdueShortRatio;
  final int overdueLongAmount;
  final double overdueLongRatio;
}

/// Dữ liệu giả lấy đúng từ bản phác thảo (năm 2026 — năm mặc định khi mở
/// màn), cộng phần biến theo năm ở [_YearlyMockData]/[forYear].
///
/// CHƯA NỐI API — biểu đồ 7 cột theo tháng (`monthHeights`/`monthLabels`),
/// "↑ 22% so với 2025" (`yoyChip`), "17 hợp đồng" (`contractsChip`), tỉ lệ
/// chốt, deal trung bình, và công nợ theo ba nhóm tuổi nợ. Backend có
/// `/analytics/revenue` và `/analytics/win-rate` nhưng mobile chưa dựng client
/// cho hai endpoint này — đợt sau, khi đó `forYear` sẽ gọi API thật theo năm
/// thay vì tra map cứng. `collectedAmount` không còn ở đây: nó đã nối vào
/// `DashboardSummary.totalRevenue` qua `dashboardSummaryProvider` (xem
/// `_CollectedSlip`), và **không** đổi theo năm chọn.
///
/// Là class chứ không phải record vì Dart không cho đọc field của record
/// trong biểu thức `const`, mà phần lớn widget của màn này phải const được.
/// Tên viết hoa theo lint `camel_case_types` của repo.
abstract final class _MockData {
  static const String title = 'Doanh thu';

  static const String collectedLabel = 'Đã thu · 7 tháng đầu năm';

  /// Khung cao của biểu đồ — đúng `height:78px` ở HTML dòng 918.
  static const double chartHeight = 78;

  static const List<String> monthLabels = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
  ];

  static const String closeRateLabel = 'Tỉ lệ chốt';
  static const String avgDealLabel = 'Deal trung bình';

  static const String agingSectionLabel = 'Công nợ theo tuổi nợ';
  static const String agingActionLabel = 'Chi tiết';

  static const String onTimeLabel = 'Trong hạn';
  static const String overdueShortLabel = 'Quá 1–7 ngày';
  static const String overdueLongLabel = 'Quá trên 30 ngày';

  /// Dữ liệu giả theo từng năm, khớp bản phác thảo ở 2026. `_showYearPickerSheet`
  /// chỉ liệt kê ba năm này — thêm năm nào vào bảng chọn thì thêm dữ liệu giả
  /// tương ứng ở đây trước.
  static const Map<int, _YearlyMockData> _byYear = {
    2024: _YearlyMockData(
      yoyChip: '↑ 9% so với 2023',
      contractsChip: '9 hợp đồng',
      monthHeights: [16, 22, 14, 28, 20, 32, 26],
      closeRateValue: '30%',
      closeRateCaption: '9/30 báo giá',
      avgDealValue: '11,5 tr',
      avgDealCaption: '↑ 0,6 tr',
      onTimeAmount: 11000000,
      onTimeRatio: 0.55,
      overdueShortAmount: 5200000,
      overdueShortRatio: 0.28,
      overdueLongAmount: 4300000,
      overdueLongRatio: 0.17,
    ),
    2025: _YearlyMockData(
      yoyChip: '↑ 15% so với 2024',
      contractsChip: '13 hợp đồng',
      monthHeights: [24, 34, 20, 40, 30, 46, 38],
      closeRateValue: '36%',
      closeRateCaption: '13/36 báo giá',
      avgDealValue: '14,2 tr',
      avgDealCaption: '↑ 1,1 tr',
      onTimeAmount: 15000000,
      onTimeRatio: 0.58,
      overdueShortAmount: 6200000,
      overdueShortRatio: 0.26,
      overdueLongAmount: 4600000,
      overdueLongRatio: 0.16,
    ),
    2026: _YearlyMockData(
      yoyChip: '↑ 22% so với 2025',
      contractsChip: '17 hợp đồng',
      monthHeights: [32, 44, 26, 52, 38, 60, 48],
      closeRateValue: '41%',
      closeRateCaption: '17/41 báo giá',
      avgDealValue: '16,7 tr',
      avgDealCaption: '↑ 1,9 tr',
      onTimeAmount: 19000000,
      onTimeRatio: 0.60,
      overdueShortAmount: 7500000,
      overdueShortRatio: 0.24,
      overdueLongAmount: 5000000,
      overdueLongRatio: 0.16,
    ),
  };

  /// Năm không có trong [_byYear] (chưa nên xảy ra vì bảng chọn chỉ đưa ra ba
  /// năm ở trên) rơi về 2026 thay vì ném lỗi.
  static _YearlyMockData forYear(int year) => _byYear[year] ?? _byYear[2026]!;
}
