import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/modules/analytics/domain/entities/dashboard_summary.dart';
import 'package:solodesk_mobile/modules/analytics/presentation/providers/analytics_provider.dart';
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
/// khớp trực tiếp — dùng cho "Đã thu · 7 tháng đầu năm". Mọi số liệu khác của
/// màn này (biểu đồ 7 cột, so sánh cùng kỳ, số hợp đồng, tỉ lệ chốt, deal
/// trung bình, công nợ theo tuổi nợ) không có field nào cấp — xem
/// `_MockData` để biết chi tiết còn thiếu.
class RevenuePage extends ConsumerWidget {
  const RevenuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);

    return Theme(
      data: AppTheme.light(),
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
                actions: const [
                  StatusChip(
                    _MockData.yearChipLabel,
                    trailingIcon: SoloIcons.chevron,
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
                        _CollectedSlip(collectedAmount: s.totalRevenue),
                        const SizedBox(height: AppGap.row),
                        // IntrinsicHeight: `crossAxisAlignment.stretch` cần
                        // Row có chiều cao xác định để kéo giãn hai thẻ
                        // bằng nhau. Không có nó, Row nằm trong Column cao
                        // vô hạn của SingleChildScrollView và `hasSize`
                        // assert lúc dựng — đây là chỗ Row thật sự đổ,
                        // không phải biểu đồ cột (biểu đồ cũng được bọc
                        // SizedBox height cố định để không lặp lại lỗi
                        // tương tự).
                        const IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: _MockData.closeRateLabel,
                                  value: _MockData.closeRateValue,
                                  caption: _MockData.closeRateCaption,
                                ),
                              ),
                              SizedBox(width: AppGap.row),
                              Expanded(
                                child: _StatCard(
                                  label: _MockData.avgDealLabel,
                                  value: _MockData.avgDealValue,
                                  caption: _MockData.avgDealCaption,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SectionHeader(
                          _MockData.agingSectionLabel,
                          actionLabel: _MockData.agingActionLabel,
                        ),
                        const _DebtAgingCard(),
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

/// Tấm phiếu tiền đã thu. Là `SlipCard` vì đúng là tiền — nhưng `Tone.neutral`
/// chứ không phải `Tone.ok`: đây là số **tham chiếu** tổng doanh thu đã thu,
/// không phải trạng thái "vừa được đánh dấu đã thu" của một khoản cụ thể như
/// MÀN 02. HTML không khai màu cho `.num` này nên nó thừa hưởng `--ink`.
///
/// [collectedAmount] đến từ `DashboardSummary.totalRevenue` — field duy nhất
/// của `dashboardSummaryProvider` khớp trực tiếp với dữ liệu màn này.
class _CollectedSlip extends StatelessWidget {
  const _CollectedSlip({required this.collectedAmount});

  final double collectedAmount;

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
          const Wrap(
            spacing: AppGap.xs,
            runSpacing: AppGap.xs,
            children: [
              StatusChip(_MockData.yoyChip, tone: Tone.ok),
              StatusChip(_MockData.contractsChip),
            ],
          ),
          const PerforatedDivider(),
          const _MonthlyBarChart(),
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
/// cao dữ liệu (`monthHeights[i] / monthHeights.max`), không phải chép thẳng
/// pixel HTML làm chiều cao cứng cho thanh cột: chưa có font thật nên nhãn
/// tháng (`AppText.mut`) đo bằng font thay thế cao hơn ước tính của bản phác
/// thảo, ghép với chiều cao cột cứng 60px sẽ tràn đáy khung 78px. Chia theo
/// tỉ lệ trong phần `Expanded` còn lại sau khi trừ nhãn giữ đúng hình dạng
/// biểu đồ mà luôn vừa khung, bất kể font nào đang được dùng để đo.
class _MonthlyBarChart extends StatelessWidget {
  const _MonthlyBarChart();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Biểu đồ doanh thu 7 tháng đầu năm, tháng 07 là tháng hiện tại',
      child: SizedBox(
        height: _MockData.chartHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _MockData.monthLabels.length; i++) ...[
              if (i > 0) const SizedBox(width: AppGap.sm),
              Expanded(child: _MonthBar(index: i)),
            ],
          ],
        ),
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  const _MonthBar({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final isCurrent = index == _MockData.monthLabels.length - 1;
    // Tháng hiện tại: momo đặc. Sáu tháng trước: momoSoft — nền so sánh nhạt,
    // cố ý không tranh sự chú ý. Không dùng aiSoft (tím dành riêng cho AI chờ
    // duyệt) và không dùng momoLine (token viền, không phải token nền).
    final barColor = isCurrent ? AppColors.momo : AppColors.momoSoft;
    final heightFactor =
        _MockData.monthHeights[index] / _MockData.tallestMonthHeight;

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
/// figcaption "càng để lâu càng khó đòi".
class _DebtAgingCard extends StatelessWidget {
  const _DebtAgingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppGap.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _DebtAgingRow(
              label: _MockData.onTimeLabel,
              amount: _MockData.onTimeAmount,
              ratio: _MockData.onTimeRatio,
              tone: Tone.neutral,
            ),
            SizedBox(height: AppGap.lg),
            _DebtAgingRow(
              label: _MockData.overdueShortLabel,
              amount: _MockData.overdueShortAmount,
              ratio: _MockData.overdueShortRatio,
              tone: Tone.warn,
            ),
            SizedBox(height: AppGap.lg),
            _DebtAgingRow(
              label: _MockData.overdueLongLabel,
              amount: _MockData.overdueLongAmount,
              ratio: _MockData.overdueLongRatio,
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

/// Dữ liệu giả lấy đúng từ bản phác thảo.
///
/// CHƯA NỐI API — biểu đồ 7 cột theo tháng (`monthHeights`/`monthLabels`),
/// "↑ 22% so với 2025" (`yoyChip`), "17 hợp đồng" (`contractsChip`), tỉ lệ
/// chốt, deal trung bình, và công nợ theo ba nhóm tuổi nợ. Backend có
/// `/analytics/revenue` và `/analytics/win-rate` nhưng mobile chưa dựng client
/// cho hai endpoint này — đợt sau. `collectedAmount` không còn ở đây: nó đã
/// nối vào `DashboardSummary.totalRevenue` qua `dashboardSummaryProvider`
/// (xem `_CollectedSlip`).
///
/// Là class chứ không phải record vì Dart không cho đọc field của record
/// trong biểu thức `const`, mà phần lớn widget của màn này phải const được.
/// Tên viết hoa theo lint `camel_case_types` của repo.
abstract final class _MockData {
  static const String title = 'Doanh thu';
  static const String yearChipLabel = '2026';

  static const String collectedLabel = 'Đã thu · 7 tháng đầu năm';
  static const String yoyChip = '↑ 22% so với 2025';
  static const String contractsChip = '17 hợp đồng';

  /// Khung cao của biểu đồ — đúng `height:78px` ở HTML dòng 918.
  static const double chartHeight = 78;

  /// Chiều cao cột theo đúng pixel trong bản phác thảo — đây là dữ liệu doanh
  /// thu từng tháng, không phải khoảng cách bố cục, nên không lấy từ `AppGap`.
  /// Dùng làm tỉ lệ tương đối giữa các cột (xem `_MonthBar`), không phải
  /// chiều cao tuyệt đối.
  static const List<double> monthHeights = [32, 44, 26, 52, 38, 60, 48];

  /// Cột cao nhất — tháng 06 trong bản phác thảo, dùng làm mẫu số quy đổi
  /// [monthHeights] thành tỉ lệ 0–1.
  static const double tallestMonthHeight = 60;
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
  static const String closeRateValue = '41%';
  static const String closeRateCaption = '17/41 báo giá';

  static const String avgDealLabel = 'Deal trung bình';
  static const String avgDealValue = '16,7 tr';
  static const String avgDealCaption = '↑ 1,9 tr';

  static const String agingSectionLabel = 'Công nợ theo tuổi nợ';
  static const String agingActionLabel = 'Chi tiết';

  static const String onTimeLabel = 'Trong hạn';
  static const int onTimeAmount = 19000000;
  static const double onTimeRatio = 0.60;

  static const String overdueShortLabel = 'Quá 1–7 ngày';
  static const int overdueShortAmount = 7500000;
  static const double overdueShortRatio = 0.24;

  static const String overdueLongLabel = 'Quá trên 30 ngày';
  static const int overdueLongAmount = 5000000;
  static const double overdueLongRatio = 0.16;
}
