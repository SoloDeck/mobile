import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/filter_chip_bar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

/// MÀN 03 — Thông báo đẩy.
///
/// Đối chiếu: khối `MÀN 03` (dòng 412-420) trong
/// `design/solodesk-mobile-ui.html`, gồm cả `<figcaption>`.
///
/// Bốn quyết định trong figcaption, đừng đảo lại khi sửa:
/// - **Lọc theo loại**: ba nguồn thông báo (tiền, lead, task) mức khẩn cấp khác
///   hẳn nhau, nên có dải chip "Tất cả · Tiền · Lead mới · Task" ngay đầu thân
///   màn — `FilterChipBar`.
/// - **Thông báo tiền tô nền hồng, loại duy nhất được nổi bật**: chỉ mục "Quá
///   hạn thanh toán" dùng nền `Tone.money.background` + viền
///   `Tone.money.border`; bốn mục còn lại (lead, báo giá AI, đã nhận tiền, task
///   trễ hạn) đều là `Card` trắng thường — kể cả mục "Đã nhận 15.000.000 ₫"
///   tuy cũng là tiền, vì nó đã xong việc, không còn khẩn cấp.
/// - **Mỗi thông báo viết đủ số liệu để quyết định ngay**: mỗi thẻ có dòng phụ
///   nêu đủ tên khách, số tiền, số ngày trễ — không rút gọn thành "Xem chi
///   tiết".
/// - **Mục đã đọc giảm độ đậm thay vì biến mất**: hai thẻ "Hôm qua" bọc
///   `Opacity(0.62)` thay vì bị lọc khỏi danh sách, để còn tra lại lịch sử.
///
/// Đây là màn mở ra từ nút chuông ở MÀN 02, không phải một trong bốn mục gốc —
/// bản phác thảo không có `.tabbar`/`.fab` ở màn này, nên **không** dựng
/// `SoloNavBar`.
///
/// CHƯA NỐI API — backend chưa có feed thông báo (chỉ `users` router có
/// notification *settings*, không phải danh sách thông báo). Toàn bộ danh
/// sách dưới đây là dữ liệu giả từ bản phác thảo.
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceControllerProvider);
    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      // `const` phải bỏ ở nút `Scaffold` vì `onTap` của nút quay lại là closure
      // — mọi nhánh con còn lại vẫn giữ `const` để không tăng chi phí dựng lại.
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          child: Column(
            children: [
              SoloAppBar(
                title: 'Thông báo',
                titleSize: SoloAppBar.lg,
                leading: IconButtonBox(
                  SoloIcons.back,
                  label: 'Quay lại',
                  ghost: true,
                  onTap: () => context.pop(),
                ),
                actions: const [
                  IconButtonBox(
                    SoloIcons.check,
                    label: 'Đánh dấu tất cả đã đọc',
                    ghost: true,
                    iconColor: AppColors.ink2,
                  ),
                ],
              ),
              const Expanded(
                // SingleChildScrollView chứ không phải ListView: nội dung dựng
                // hết một lượt để test tìm được cả phần "Hôm qua" dưới màn.
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: AppGap.screen),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilterChipBar(
                        labels: _MockData.filters,
                        selectedIndex: 0,
                      ),
                      SizedBox(height: AppGap.xs),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppGap.screen,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SectionLabel('hôm nay'),
                            SizedBox(height: AppGap.sm),
                            _OverdueMoneyNotice(),
                            SizedBox(height: AppGap.betweenCards),
                            _NewLeadNotice(),
                            SizedBox(height: AppGap.betweenCards),
                            _QuoteReadyNotice(),
                            SizedBox(height: AppGap.sectionTop),
                            SectionLabel('hôm qua'),
                            SizedBox(height: AppGap.sm),
                            _PaymentReceivedNotice(),
                            SizedBox(height: AppGap.betweenCards),
                            _TaskDueNotice(),
                          ],
                        ),
                      ),
                    ],
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

/// Một dòng thông báo: icon, tiêu đề, giờ nhận, và đoạn phụ nêu đủ số liệu.
///
/// [tinted] chỉ đúng cho thông báo tiền đang khẩn cấp (`.card` tô nền
/// `momo-soft` trong bản phác thảo) — mọi thông báo khác dùng `Card` trắng
/// thường của `AppTheme`, kể cả thông báo cũng nói về tiền nhưng đã xong việc.
///
/// [read] bọc `Opacity(0.62)` cho mục "Hôm qua", đúng quyết định trong
/// figcaption: mờ đi chứ không biến mất.
class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.icon,
    required this.tone,
    required this.title,
    required this.time,
    required this.sub,
    this.highlightTitle = false,
    this.tinted = false,
    this.read = false,
  });

  final SoloIconData icon;
  final Tone tone;
  final String title;
  final String time;
  final Widget sub;

  /// Chỉ mục tiền khẩn cấp tô cả tiêu đề bằng màu tone.
  final bool highlightTitle;

  /// Chỉ mục tiền khẩn cấp mới tô nền cả thẻ.
  final bool tinted;
  final bool read;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SoloIcon(
              icon,
              label: null,
              size: SoloIcon.sm,
              color: tone.foreground,
            ),
            const SizedBox(width: AppGap.row),
            Expanded(
              child: Text(
                title,
                style: AppText.bodyStrong.copyWith(
                  color: highlightTitle ? tone.foreground : AppColors.ink,
                ),
              ),
            ),
            Text(time, style: AppText.mut),
          ],
        ),
        const SizedBox(height: AppGap.xs),
        sub,
      ],
    );

    final card = tinted
        ? Container(
            padding: const EdgeInsets.all(AppGap.card),
            decoration: BoxDecoration(
              color: tone.background,
              borderRadius: AppRadius.cardAll,
              border: Border.all(color: tone.border),
            ),
            child: body,
          )
        : Card(
            child: Padding(
              padding: const EdgeInsets.all(AppGap.card),
              child: body,
            ),
          );

    return read ? Opacity(opacity: 0.62, child: card) : card;
  }
}

/// "Quá hạn thanh toán" — loại thông báo duy nhất được phép tô nền hồng.
class _OverdueMoneyNotice extends StatelessWidget {
  const _OverdueMoneyNotice();

  @override
  Widget build(BuildContext context) {
    return const _NotificationCard(
      icon: SoloIcons.cash,
      tone: Tone.money,
      title: 'Quá hạn thanh toán',
      time: '07:00',
      highlightTitle: true,
      tinted: true,
      sub: Text.rich(
        TextSpan(
          style: AppText.sub,
          children: [
            TextSpan(text: 'Minh An chưa thanh toán đợt 2 — '),
            TextSpan(text: '12.500.000 ₫', style: AppText.numSm),
            TextSpan(text: ', trễ 6 ngày. Bản nhắc đã soạn sẵn.'),
          ],
        ),
      ),
    );
  }
}

/// "Có lead mới từ form" — thông tin, không tô nền, giữ độ đậm bình thường.
class _NewLeadNotice extends StatelessWidget {
  const _NewLeadNotice();

  @override
  Widget build(BuildContext context) {
    return const _NotificationCard(
      icon: SoloIcons.file,
      tone: Tone.ok,
      title: 'Có lead mới từ form',
      time: '09:19',
      sub: Text(
        'Trần Nam gửi yêu cầu chụp 40 sản phẩm, ngân sách khoảng 15 triệu.',
        style: AppText.sub,
      ),
    );
  }
}

/// "Báo giá soạn xong" — bản nháp do AI soạn, chờ người dùng tự mở màn xem
/// trước để duyệt (quy tắc 5); thông báo chỉ báo tin, không có nút gửi tắt.
class _QuoteReadyNotice extends StatelessWidget {
  const _QuoteReadyNotice();

  @override
  Widget build(BuildContext context) {
    return const _NotificationCard(
      icon: SoloIcons.ai,
      tone: Tone.ai,
      title: 'Báo giá soạn xong',
      time: '08:42',
      sub: Text(
        'Bản nháp cho Việt Phát đã sẵn sàng, còn 2 biến chưa điền.',
        style: AppText.sub,
      ),
    );
  }
}

/// "Đã nhận 15.000.000 ₫" — cũng là tiền, nhưng đã xong việc nên **không** tô
/// nền hồng, chỉ mờ đi vì thuộc mục Hôm qua đã đọc.
class _PaymentReceivedNotice extends StatelessWidget {
  const _PaymentReceivedNotice();

  @override
  Widget build(BuildContext context) {
    return const _NotificationCard(
      icon: SoloIcons.check,
      tone: Tone.ok,
      title: 'Đã nhận 15.000.000 ₫',
      time: '16:03',
      read: true,
      sub: Text(
        'Việt Phát chuyển khoản đợt 1. Hợp đồng chuyển sang Đang chạy.',
        style: AppText.sub,
      ),
    );
  }
}

/// "Task đến hạn hôm nay" — mờ đi vì thuộc mục Hôm qua đã đọc.
class _TaskDueNotice extends StatelessWidget {
  const _TaskDueNotice();

  @override
  Widget build(BuildContext context) {
    return const _NotificationCard(
      icon: SoloIcons.clock,
      tone: Tone.warn,
      title: 'Task đến hạn hôm nay',
      time: '08:00',
      read: true,
      sub: Text(
        '“Gửi bản nháp logo vòng 2” — dự án Minh An.',
        style: AppText.sub,
      ),
    );
  }
}

/// CHƯA NỐI API — không có endpoint danh sách thông báo trên backend. Dữ liệu
/// giả lấy đúng từ bản phác thảo; ghép API thật chỉ cần thay ở đây.
///
/// Là class chứ không phải record vì Dart không cho đọc field của record trong
/// biểu thức `const`, mà widget của màn này phải const được. Tên viết hoa theo
/// lint `camel_case_types` của repo.
abstract final class _MockData {
  static const List<String> filters = ['Tất cả', 'Tiền', 'Lead mới', 'Task'];
}
