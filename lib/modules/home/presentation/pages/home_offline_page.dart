import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/modules/home/presentation/widgets/dashed_card.dart';
import 'package:solodesk_mobile/modules/home/presentation/widgets/offline_banner.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
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
import 'package:solodesk_mobile/ui/solo_nav_bar.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// MÀN 15 — Chế độ ngoại tuyến.
///
/// Không còn là một mục điều hướng riêng — đây là trạng thái ngoại tuyến của
/// MÀN 02 (`HomeTodayPage`), sống cùng module `home`. Ba mảnh dùng lại được
/// (`OfflineBanner`, `PendingChip` bên trong nó, `DashedCard`) đã tách sang
/// `presentation/widgets/` để dùng chung; phần còn lại của bố cục là riêng
/// của màn này.
///
/// Đối chiếu: khối `MÀN 15` (dòng 1155–1218, gồm cả `<figcaption>`) trong
/// `design/solodesk-mobile-ui.html`.
///
/// Bốn quyết định trong figcaption, đừng đảo lại khi sửa:
/// - App **không chặn thao tác**: vẫn ghi lead bằng giọng nói, vẫn tick task —
///   ba dòng trong "Hàng chờ đồng bộ" chứng minh điều đó, chỉ khác là chúng
///   xếp hàng chờ thay vì gửi ngay.
/// - Số liệu cũ (tờ phiếu công nợ) chuyển sang **xám và ghi rõ giờ chụp**:
///   `SlipCard.stale` xám hoá + làm mờ con số, còn dải báo ngoại tuyến ghi rõ
///   "dữ liệu lúc 08:14" — tránh người dùng ra quyết định trên số cũ.
/// - Hàng chờ hiện rõ **từng mục và điều kiện gửi** ("Chờ AI", "Đã lưu máy",
///   "Chờ Wi-Fi"), không phải một vòng xoay vô hạn.
/// - Nút ＋ ở thanh tab đổi xám (`SoloNavBar.offline`) để báo trước: tạo được,
///   nhưng AI phải đợi có mạng mới chạy.
///
/// CHƯA NỐI API — chưa có provider trạng thái kết nối mạng hay hàng chờ đồng
/// bộ ngoại tuyến (Drift pending-sync queue) trong repo; toàn bộ nội dung màn
/// vẫn là dữ liệu giả, xem `_MockData`. Khi có provider thật, màn này nên
/// được ghép vào `HomeTodayPage` như một nhánh hiển thị theo trạng thái mạng
/// thay vì một page độc lập.
/// Đích của bốn mục trên `SoloNavBar`, đúng thứ tự `SoloNavBar.destinations`.
///
/// Chép giá trị chứ không dùng lại `AppShell`: shell điều hướng bằng
/// `goBranch` trên `StatefulNavigationShell`, thứ mà màn này không có.
const _tabRoutes = [
  RouteNames.home,
  RouteNames.deals,
  RouteNames.projects,
  RouteNames.me,
];

class HomeOfflinePage extends ConsumerWidget {
  const HomeOfflinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceControllerProvider);
    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      // Không còn `const` được từ đây xuống: thanh tab và nút chuông giữ
      // closure điều hướng. Các nhánh con vẫn `const` để phần thân màn không
      // dựng lại theo.
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  const OfflineBanner(
                    message: _MockData.offlineBanner,
                    pendingLabel: _MockData.pendingCount,
                  ),
                  SoloAppBar(
                    title: _MockData.title,
                    overline: _MockData.date,
                    titleSize: SoloAppBar.md,
                    leading: const Avatar.initials(
                      _MockData.userInitials,
                      tone: Tone.money,
                    ),
                    actions: [
                      IconButtonBox(
                        SoloIcons.bell,
                        label: 'Thông báo',
                        onTap: () => context.push(RouteNames.notifications),
                      ),
                    ],
                  ),
                  const Expanded(
                    // SingleChildScrollView chứ không phải ListView: nội dung
                    // dựng hết một lượt để test tìm được cả thẻ rỗng cuối màn.
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        AppGap.screen,
                        0,
                        AppGap.screen,
                        AppGap.navBarInset,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _StaleOutstandingSlip(),
                          SectionHeader(
                            'Hàng chờ đồng bộ',
                            actionLabel: 'Thử lại',
                          ),
                          _VoiceLeadQueuedCard(),
                          SizedBox(height: AppGap.betweenCards),
                          _TasksDoneQueuedCard(),
                          SizedBox(height: AppGap.betweenCards),
                          _PhotoQueuedCard(),
                          _EmptyOutboxCard(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SoloNavBar(
                  index: 0,
                  offline: true,
                  // `go` chứ không phải `goBranch`: màn này nằm *ngoài*
                  // `StatefulShellRoute` nên không có `StatefulNavigationShell`
                  // để đổi nhánh. Chọn một mục là rời hẳn chế độ xem ngoại
                  // tuyến, đúng nghĩa người dùng mong đợi.
                  onSelect: (slot) => context.go(_tabRoutes[slot]),
                  onQuickCapture: () => context.push(RouteNames.voiceCapture),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tờ phiếu công nợ cũ — con số chụp từ lúc còn mạng, xám hoá qua
/// `SlipCard.stale` đúng như figcaption "số liệu cũ chuyển sang xám".
class _StaleOutstandingSlip extends StatelessWidget {
  const _StaleOutstandingSlip();

  @override
  Widget build(BuildContext context) {
    return const SlipCard(
      notch: 80,
      stale: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: SectionLabel('Đang chờ thu · tháng 7')),
              StatusChip('Số cũ'),
            ],
          ),
          SizedBox(height: AppGap.sm),
          Money.hero(_MockData.outstanding),
          PerforatedDivider(),
          Text('Sẽ cập nhật lại khi có mạng', style: AppText.mut),
        ],
      ),
    );
  }
}

/// Việc 1 trong hàng chờ — lead ghi bằng giọng nói, chờ AI xử lý khi có mạng.
/// `AccentCard` vạch tím vì đây là nội dung sẽ do AI đọc, cùng ngữ nghĩa với
/// vạch tím ở MÀN 02.
class _VoiceLeadQueuedCard extends StatelessWidget {
  const _VoiceLeadQueuedCard();

  @override
  Widget build(BuildContext context) {
    return const AccentCard(
      tone: Tone.ai,
      child: _QueueRow(
        icon: SoloIcons.mic,
        iconColor: AppColors.ai,
        title: 'Lead ghi bằng giọng nói',
        subtitle: '“Anh Nam Studio Cỏ, 40 sản phẩm…”',
        chip: StatusChip('Chờ AI', tone: Tone.ai),
      ),
    );
  }
}

/// Việc 2 — hai task đã tick xong khi mất mạng, đã ghi nhận trên máy.
class _TasksDoneQueuedCard extends StatelessWidget {
  const _TasksDoneQueuedCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppGap.card),
        child: _QueueRow(
          icon: SoloIcons.check,
          iconColor: AppColors.ink2,
          title: 'Đánh dấu 2 task đã xong',
          subtitle: 'Dự án Minh An',
          chip: StatusChip('Đã lưu máy'),
        ),
      ),
    );
  }
}

/// Việc 3 — ảnh bàn giao chờ Wi-Fi vì dung lượng lớn, không gửi qua mạng di
/// động ngầm.
class _PhotoQueuedCard extends StatelessWidget {
  const _PhotoQueuedCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppGap.card),
        child: _QueueRow(
          icon: SoloIcons.image,
          iconColor: AppColors.ink2,
          title: '1 ảnh bàn giao',
          subtitle: '2,1 MB · tải lên khi có Wi-Fi',
          chip: StatusChip('Chờ Wi-Fi'),
        ),
      ),
    );
  }
}

/// Hàng "icon + tiêu đề/đoạn phụ + chip điều kiện gửi", lặp lại ba lần trong
/// hàng chờ đồng bộ. Để private vì mới chỉ dùng trong MÀN 15.
class _QueueRow extends StatelessWidget {
  const _QueueRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.chip,
  });

  final SoloIconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget chip;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SoloIcon(icon, label: null, size: SoloIcon.sm, color: iconColor),
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
        const SizedBox(width: AppGap.row),
        chip,
      ],
    );
  }
}

/// Trạng thái rỗng của hộp thư đi — chưa có gì gửi được vì đang mất mạng.
/// Dùng [DashedCard] (`presentation/widgets/dashed_card.dart`) cho viền đứt
/// nét báo đây là **hàng chờ**, không phải một thẻ nội dung bình thường.
class _EmptyOutboxCard extends StatelessWidget {
  const _EmptyOutboxCard();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: AppGap.card),
      child: DashedCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SoloIcon(
              SoloIcons.send,
              label: null,
              size: 26,
              color: AppColors.ink3,
            ),
            SizedBox(height: AppGap.sm),
            Text(
              'Chưa gửi được tin nhắn nào',
              style: AppText.bodyStrong,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppGap.xs),
            Text(
              'Nhắc thanh toán và báo giá chỉ gửi đi\n'
              'sau khi máy kết nối lại mạng.',
              style: AppText.mut,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dữ liệu giả lấy đúng từ bản phác thảo. Ghép API thật chỉ cần thay ở đây —
/// xem doc comment `CHƯA NỐI API` trên lớp [HomeOfflinePage].
///
/// Là class chứ không phải record vì Dart không cho đọc field của record trong
/// biểu thức `const`, mà widget của màn này phải const được. Tên viết hoa theo
/// lint `camel_case_types` của repo.
abstract final class _MockData {
  static const String title = 'Hôm nay';
  static const String date = 'Thứ Bảy, 25/07';
  static const String userInitials = 'HL';
  static const String offlineBanner = 'Đang ngoại tuyến · dữ liệu lúc 08:14';
  static const String pendingCount = '3 chờ gửi';
  static const int outstanding = 31500000;
}
