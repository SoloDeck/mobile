import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/modules/analytics/presentation/providers/analytics_provider.dart';
import 'package:solodesk_mobile/modules/auth/presentation/providers/auth_state_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/modules/subscriptions/presentation/providers/subscriptions_provider.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/avatar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/section_header.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// Tab "Tôi" — thẻ hồ sơ + ba nhóm menu (Tài chính, Công việc, Tài khoản).
///
/// Đối chiếu: `design/solodesk_toi_tab_redesign.html`. Bản phác thảo còn vẽ một
/// hàng hai ô số liệu "Doanh thu tháng"/"Chờ thu" ngay dưới thẻ hồ sơ — cố ý bỏ
/// hẳn theo quyết định đã chốt với người dùng, vì "Chờ thu" không có field số
/// tiền sẵn trong API và việc thêm một khối số liệu thứ hai (sau MÀN 02) là
/// trùng lặp. Thẻ hồ sơ nối thẳng xuống ba nhóm menu.
///
/// Field/hành động nào chưa nối API thật (badge số hoá đơn quá hạn, badge số
/// báo giá chờ duyệt, "Trợ giúp và phản hồi", số phiên bản) đều ghi trong
/// `docs/superpowers/specs/2026-07-28-me-profile-settings-checklist.md`.
///
/// MÀN 15 (ngoại tuyến) **không** có mặt trong danh sách — đó là một *trạng
/// thái* của trang chủ chứ không phải một đích đến. Route
/// [RouteNames.offline] vẫn đăng ký để mở tay khi cần xem, cho tới khi có bộ dò
/// mạng tự chuyển sang nó.
class MePage extends ConsumerWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceControllerProvider);
    final dashboard = ref.watch(dashboardSummaryProvider).value;
    final planName = ref.watch(mySubscriptionProvider).value?.planName;

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SoloAppBar(
                title: 'Tôi',
                titleSize: SoloAppBar.lg,
                actions: [
                  IconButtonBox(
                    SoloIcons.settings,
                    label: 'Cài đặt',
                    onTap: () => context.push(RouteNames.settings),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppGap.screen,
                    0,
                    AppGap.screen,
                    AppGap.navBarInset,
                  ),
                  children: [
                    const _ProfileCard(),
                    const SectionHeader('Tài chính'),
                    const _MenuCard([
                      _MenuEntry(
                        icon: SoloIcons.cash,
                        label: 'Doanh thu',
                        route: RouteNames.revenue,
                      ),
                      _MenuEntry(
                        icon: SoloIcons.file,
                        label: 'Hoá đơn',
                        route: RouteNames.invoices,
                      ),
                      _MenuEntry(
                        icon: SoloIcons.send,
                        label: 'Nhắc thu tiền',
                        route: RouteNames.reminders,
                      ),
                    ]),
                    const SectionHeader('Công việc'),
                    _MenuCard([
                      _MenuEntry(
                        icon: SoloIcons.user,
                        label: 'Khách hàng',
                        route: RouteNames.clients,
                        trailing: dashboard != null
                            ? _TrailingCount('${dashboard.totalClients}')
                            : null,
                      ),
                      const _MenuEntry(
                        icon: SoloIcons.ai,
                        label: 'Báo giá',
                        route: RouteNames.proposals,
                      ),
                      const _MenuEntry(
                        icon: SoloIcons.folder,
                        label: 'Thư viện mẫu',
                        route: RouteNames.templates,
                      ),
                    ]),
                    const SectionHeader('Tài khoản'),
                    _MenuCard([
                      _MenuEntry(
                        icon: SoloIcons.tag,
                        label: 'Gói và thanh toán',
                        route: RouteNames.plans,
                        trailing: planName != null
                            ? _TrailingCount(planName)
                            : null,
                      ),
                      const _MenuEntry(
                        icon: SoloIcons.settings,
                        label: 'Cài đặt',
                        route: RouteNames.settings,
                      ),
                    ]),
                    const _FooterLinks(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Thẻ hồ sơ: avatar, tên, badge tên gói, email, chevron. Cả thẻ bấm được, mở
/// MÀN 05 ("Hồ sơ").
///
/// Đọc `currentUserProvider` — controller nạp nó sau mỗi lần đăng nhập thành
/// công. Lần `/me` hỏng thì provider vẫn rỗng mà phiên vẫn hợp lệ (xem
/// `AuthController._loadCurrentUser`), nên chỗ này phải chịu được `null` chứ
/// không được coi đó là chưa đăng nhập. Badge tên gói đọc
/// `mySubscriptionProvider` (`GET /subscriptions/me`) — ẩn hẳn khi đang tải
/// hoặc lỗi thay vì đoán mò.
class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final planName = ref.watch(mySubscriptionProvider).value?.planName;
    final fullName = user?.fullName ?? 'Chưa đăng nhập';
    final email = user?.email ?? '';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(RouteNames.profile),
        child: Padding(
          padding: const EdgeInsets.all(AppGap.card),
          child: Row(
            children: [
              _ProfileAvatar(
                initials: _initials(fullName),
                avatarUrl: user?.avatarUrl,
              ),
              const SizedBox(width: AppGap.row),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            fullName,
                            style: AppText.bodyStrong,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (planName != null) ...[
                          const SizedBox(width: AppGap.xs),
                          StatusChip(planName, tone: Tone.ai),
                        ],
                      ],
                    ),
                    if (email.isNotEmpty) Text(email, style: AppText.mut),
                  ],
                ),
              ),
              const SizedBox(width: AppGap.row),
              const SoloIcon(SoloIcons.chevron, label: null, size: SoloIcon.sm),
            ],
          ),
        ),
      ),
    );
  }

  /// Hai chữ cái đầu của tên. Tên một chữ thì lấy một chữ; rỗng thì trả về "?"
  /// để `_ProfileAvatar` luôn có gì đó để vẽ.
  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

/// Avatar của thẻ hồ sơ: dùng `avatarUrl` khi có, ngược lại vẽ chữ cái viết
/// tắt. Ảnh lỗi (mạng chập chờn, URL hỏng) rơi về chữ cái viết tắt thay vì vỡ
/// hình hoặc crash.
///
/// Chưa có API upload avatar — xem checklist. `avatarUrl` hiện chỉ đọc từ
/// `GET /users/me` khi backend đã có sẵn giá trị.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.initials, required this.avatarUrl});

  final String initials;
  final String? avatarUrl;

  /// Cạnh ô, theo đúng bản phác thảo (42 × 42).
  static const double _size = 42;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    if (url == null || url.isEmpty) {
      return Avatar.initials(initials, tone: Tone.money, size: _size);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.avatar),
      child: Image.network(
        url,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Avatar.initials(initials, tone: Tone.money, size: _size),
      ),
    );
  }
}

/// Số/chữ mờ ở cuối một dòng menu, trước chevron — "24" ở Khách hàng, "Pro" ở
/// Gói và thanh toán.
class _TrailingCount extends StatelessWidget {
  const _TrailingCount(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(value, style: AppText.mut);
  }
}

/// Một nhóm liên kết trong cùng một `Card`, ngăn nhau bằng đường kẻ 1px.
class _MenuCard extends StatelessWidget {
  const _MenuCard(this.entries);

  final List<_MenuEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.line),
            entries[i],
          ],
        ],
      ),
    );
  }
}

class _MenuEntry extends StatelessWidget {
  const _MenuEntry({
    required this.icon,
    required this.label,
    required this.route,
    this.trailing,
  });

  final SoloIconData icon;
  final String label;
  final String route;

  /// Số/chữ mờ trước chevron — ví dụ số khách hàng, tên gói. `null` = không có.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // push chứ không phải go: các màn này là nhánh con của tab "Tôi", quay
      // lại phải về đúng đây chứ không nhảy về trang chủ.
      onTap: () => context.push(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppGap.card,
          vertical: AppGap.lg,
        ),
        child: Row(
          children: [
            SoloIcon(icon, label: null, size: SoloIcon.md),
            const SizedBox(width: AppGap.row),
            Expanded(child: Text(label, style: AppText.body)),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: AppGap.row),
            ],
            const SoloIcon(SoloIcons.chevron, label: null, size: SoloIcon.sm),
          ],
        ),
      ),
    );
  }
}

/// "Trợ giúp và phản hồi" + số phiên bản, cuối màn.
///
/// "Trợ giúp và phản hồi" chưa có đích đến thật (không link, không mailto,
/// không màn FAQ) — `onTap: null` để không crash, xem checklist.
///
/// Số phiên bản: dự án chưa có dependency `package_info_plus` để đọc version
/// runtime, nên đây là chuỗi tĩnh chép tay từ `pubspec.yaml` (`version:`) —
/// nhớ cập nhật lại khi bump version, hoặc thay bằng `package_info_plus` khi
/// được duyệt thêm dependency mới.
class _FooterLinks extends StatelessWidget {
  const _FooterLinks();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppGap.lg),
      child: Column(
        children: [
          const Text('Trợ giúp và phản hồi', style: AppText.link),
          const SizedBox(height: AppGap.xs),
          Text('Phiên bản 1.3.0', style: AppText.mut),
        ],
      ),
    );
  }
}
