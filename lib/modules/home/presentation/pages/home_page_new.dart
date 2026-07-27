import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/modules/analytics/domain/entities/dashboard_summary.dart';
import 'package:solodesk_mobile/modules/analytics/presentation/providers/analytics_provider.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/accent_card.dart';
import 'package:solodesk_mobile/ui/avatar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/money.dart';
import 'package:solodesk_mobile/ui/perforated_divider.dart';
import 'package:solodesk_mobile/ui/section_header.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/stamp_badge.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// MÀN 02 — Hôm nay, trang chủ.
///
/// Đối chiếu: khối `MÀN 02` trong `design/solodesk-mobile-ui.html`.
///
/// Bốn quyết định trong figcaption, đừng đảo lại khi sửa:
/// - Tờ phiếu công nợ nằm **trên cùng** vì đó là con số người dùng mở app để xem.
/// - Mỗi việc kèm sẵn nút hành động **ngay trên thẻ**, không bắt vào chi tiết.
/// - Viền trái đổi màu theo loại việc: hồng = tiền, tím = AI chờ duyệt, hổ phách
///   = trễ hạn.
/// - Thứ tự thẻ do **mức thiệt hại** quyết định, không phải thời gian tạo.
///
/// Nối một phần: `dashboardSummaryProvider` cấp `pendingInvoices` cho con dấu
/// "N hoá đơn" trên tờ phiếu công nợ. Phần còn lại của màn — số tiền công nợ,
/// hai chip sắp đến hạn/quá hạn, số đã thu tháng này, ba thẻ việc và thẻ lead
/// mới — chưa có provider tương ứng nên vẫn là dữ liệu giả, xem `_MockData` và
/// các doc comment `CHƯA NỐI API` bên dưới.
class HomeTodayPage extends ConsumerWidget {
  const HomeTodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);

    return Theme(
      data: AppTheme.light(),
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
                overline: _MockData.date,
                titleSize: SoloAppBar.md,
                leading: Avatar.initials(
                  _MockData.userInitials,
                  tone: Tone.money,
                ),
                actions: [
                  IconButtonBox(
                    SoloIcons.bell,
                    label: 'Thông báo',
                    showDot: true,
                  ),
                ],
              ),
              Expanded(
                // SingleChildScrollView chứ không phải ListView: màn này
                // chỉ có vài thẻ, và dựng hết một lượt thì nội dung dưới
                // màn vẫn kiểm tra được bằng test.
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
                        _OutstandingSlip(pendingInvoices: s.pendingInvoices),
                        const SectionHeader(
                          'Cần bạn xử lý',
                          actionLabel: '3 việc',
                        ),
                        const _PaymentReminderTask(),
                        const SizedBox(height: AppGap.betweenCards),
                        const _QuoteDraftTask(),
                        const SizedBox(height: AppGap.betweenCards),
                        const _OverdueTasksTask(),
                        const SectionHeader(
                          'Lead mới từ form',
                          actionLabel: 'Tất cả',
                        ),
                        const _NewLeadCard(),
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

/// Tấm phiếu công nợ. Là `SlipCard` vì nội dung đúng là tiền phải đòi.
///
/// Con dấu "N hoá đơn" nối thật với `DashboardSummary.pendingInvoices`. Số
/// tiền, hai chip sắp đến hạn/quá hạn và số đã thu tháng này vẫn là dữ liệu
/// giả — xem các doc comment `CHƯA NỐI API` bên trong.
class _OutstandingSlip extends StatelessWidget {
  const _OutstandingSlip({required this.pendingInvoices});

  final int pendingInvoices;

  @override
  Widget build(BuildContext context) {
    return SlipCard(
      notch: 88,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Flexible(child: SectionLabel('Đang chờ thu · tháng 7')),
              StampBadge.due('$pendingInvoices hoá đơn'),
            ],
          ),
          const SizedBox(height: AppGap.sm),
          // CHƯA NỐI API — `DashboardSummary.totalRevenue` là tổng doanh thu,
          // không rõ có đúng nghĩa "công nợ đang chờ thu" (số tiền chưa thu
          // được) hay không; giữ mock cho tới khi xác nhận với backend.
          const Money.hero(_MockData.outstanding),
          const SizedBox(height: AppGap.md),
          // CHƯA NỐI API — không có field nào cấp số hoá đơn sắp đến hạn /
          // đã quá hạn theo từng loại; hai chip dưới đây vẫn là dữ liệu giả.
          const Row(
            children: [
              StatusChip('1 sắp đến hạn', tone: Tone.warn),
              SizedBox(width: AppGap.xs),
              StatusChip('2 quá hạn', tone: Tone.money),
            ],
          ),
          const PerforatedDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Đã thu tháng này '),
                      TextSpan(
                        // CHƯA NỐI API — không có field nào cấp số tiền đã
                        // thu trong tháng; giữ mock.
                        text: Money.format(_MockData.collectedThisMonth),
                        style: AppText.numSm.copyWith(color: AppColors.jade),
                      ),
                    ],
                  ),
                  style: AppText.mut,
                ),
              ),
              const SoloIcon(SoloIcons.chevron, label: null, size: SoloIcon.sm),
            ],
          ),
        ],
      ),
    );
  }
}

/// Việc số 1 — tiền quá hạn. Vạch hồng, và nút gửi nhắc nằm ngay trên thẻ.
///
/// CHƯA NỐI API — chưa có provider cấp danh sách việc cần xử lý hôm nay; toàn
/// bộ nội dung thẻ (khách hàng, số tiền, số ngày quá hạn) là dữ liệu giả chép
/// từ bản phác thảo.
class _PaymentReminderTask extends StatelessWidget {
  const _PaymentReminderTask();

  @override
  Widget build(BuildContext context) {
    return AccentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _TaskHeader(
            avatar: Avatar.initials('MA', tone: Tone.money),
            title: 'Nhắc thanh toán · Minh An',
            subtitle: 'Đợt 2 quá hạn 6 ngày · 12.500.000 ₫',
          ),
          const SizedBox(height: AppGap.md),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  style: AppTheme.filled(tone: Tone.money, small: true),
                  icon: const SoloIcon(
                    SoloIcons.send,
                    label: null,
                    size: SoloIcon.xs,
                    color: AppColors.surface,
                  ),
                  label: const Text('Gửi nhắc qua Zalo'),
                ),
              ),
              const SizedBox(width: AppGap.betweenButtons),
              OutlinedButton(
                onPressed: () {},
                style: AppTheme.outlined(small: true),
                child: const Text('Hoãn'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Việc số 2 — bản nháp do AI soạn. Vạch tím, và **không** có đường tắt gửi
/// thẳng: nút dẫn sang màn xem trước để người duyệt (quy tắc 5).
///
/// CHƯA NỐI API — chưa có provider cấp bản nháp AI đang chờ duyệt; dữ liệu
/// giả chép từ bản phác thảo.
class _QuoteDraftTask extends StatelessWidget {
  const _QuoteDraftTask();

  @override
  Widget build(BuildContext context) {
    return AccentCard(
      tone: Tone.ai,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _TaskHeader(
            avatar: Avatar.icon(SoloIcons.ai, tone: Tone.ai),
            title: 'Báo giá đã soạn xong',
            subtitle: 'Landing page — Cty Việt Phát · chờ bạn duyệt',
          ),
          const SizedBox(height: AppGap.md),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  style: AppTheme.filled(tone: Tone.ai, small: true),
                  child: const Text('Xem và duyệt'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Việc số 3 — task trễ hạn. Vạch hổ phách, không có nút vì hành động thật nằm
/// trong màn dự án.
///
/// CHƯA NỐI API — chưa có provider cấp số task trễ hạn theo dự án; dữ liệu
/// giả chép từ bản phác thảo.
class _OverdueTasksTask extends StatelessWidget {
  const _OverdueTasksTask();

  @override
  Widget build(BuildContext context) {
    return const AccentCard(
      tone: Tone.warn,
      child: _TaskHeader(
        avatar: Avatar.icon(SoloIcons.clock, tone: Tone.warn),
        title: '2 task trễ hạn',
        subtitle: 'Dự án Nhận diện Minh An',
        trailing: SoloIcon(SoloIcons.chevron, label: null, size: SoloIcon.sm),
      ),
    );
  }
}

/// Lead mới — `Card` thường, không phải `AccentCard`: nó là thông tin, chưa phải
/// việc phải xử lý hôm nay.
///
/// CHƯA NỐI API — chưa có provider cấp lead mới từ form; dữ liệu giả chép từ
/// bản phác thảo.
class _NewLeadCard extends StatelessWidget {
  const _NewLeadCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppGap.card),
        child: _TaskHeader(
          avatar: Avatar.initials('TN', tone: Tone.ok),
          title: 'Trần Nam · Studio Cỏ',
          subtitle: 'Chụp sản phẩm · vừa gửi 22 phút trước',
          trailing: StatusChip('Chấm điểm', tone: Tone.ai),
        ),
      ),
    );
  }
}

/// Hàng avatar + hai dòng chữ, lặp ở cả bốn thẻ của màn này.
///
/// Để private vì mới chỉ dùng trong MÀN 02. Nếu màn khác cũng cần đúng hàng này
/// thì nâng lên `lib/ui/`.
class _TaskHeader extends StatelessWidget {
  const _TaskHeader({
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

/// Dữ liệu giả lấy đúng từ bản phác thảo, cho các phần MÀN 02 chưa có provider
/// cấp dữ liệu thật. Ghép API thật chỉ cần thay ở đây.
///
/// Là class chứ không phải record vì Dart không cho đọc field của record trong
/// biểu thức `const`, mà widget của màn này phải const được. Tên viết hoa theo
/// lint `camel_case_types` của repo.
abstract final class _MockData {
  static const String title = 'Hôm nay';
  static const String date = 'Thứ Bảy, 25/07';
  static const String userInitials = 'HL';

  /// CHƯA NỐI API — không rõ `DashboardSummary.totalRevenue` có đúng nghĩa
  /// "công nợ đang chờ thu" hay không (có thể là tổng doanh thu, không phân
  /// biệt đã thu/chưa thu); giữ mock đến khi xác nhận hợp đồng API.
  static const int outstanding = 31500000;

  /// CHƯA NỐI API — không có field nào trong `DashboardSummary` cấp số tiền
  /// đã thu trong tháng.
  static const int collectedThisMonth = 48000000;
}
