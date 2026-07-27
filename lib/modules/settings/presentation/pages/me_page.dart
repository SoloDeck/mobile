import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/modules/auth/presentation/controllers/auth_controller.dart';
import 'package:solodesk_mobile/modules/auth/presentation/providers/auth_state_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/avatar.dart';
import 'package:solodesk_mobile/ui/section_header.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

/// Tab "Tôi" — cửa vào của mọi màn không có tab riêng.
///
/// **KHÔNG có trong `design/solodesk-mobile-ui.html`.** `SoloNavBar` chỉ có bốn
/// chỗ (Hôm nay, Pipeline, Dự án, Tôi) trong khi bộ 15 màn còn Doanh thu, Thông
/// báo, Báo giá, Nhắc thu tiền, Gói, Mẫu — cộng thêm Khách hàng và Hoá đơn của
/// hai module đã chạy API thật. Không có màn nào trong bản phác thảo nhận vai
/// "Tôi", nên màn này dựng ra để chúng có lối vào thay vì bị bỏ rơi.
///
/// Cố ý chỉ là một danh sách liên kết: mọi nội dung thật đều nằm ở màn đích, và
/// khi bản phác thảo bổ sung màn "Tôi" thật thì thay nội dung ở đây theo nó.
///
/// MÀN 15 (ngoại tuyến) **không** có mặt trong danh sách — đó là một *trạng
/// thái* của trang chủ chứ không phải một đích đến. Route
/// [RouteNames.offline] vẫn đăng ký để mở tay khi cần xem, cho tới khi có bộ dò
/// mạng tự chuyển sang nó.
class MePage extends ConsumerWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final appearance = ref.watch(appearanceControllerProvider);

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SoloAppBar(title: 'Tôi'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppGap.screen,
                    0,
                    AppGap.screen,
                    AppGap.navBarInset,
                  ),
                  children: [
                    _AccountCard(
                      fullName: user?.fullName ?? 'Chưa đăng nhập',
                      email: user?.email ?? '',
                    ),
                    const SectionHeader('Tiền'),
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
                        route: RouteNames.reminderCompose,
                      ),
                    ]),
                    const SectionHeader('Công việc'),
                    const _MenuCard([
                      _MenuEntry(
                        icon: SoloIcons.user,
                        label: 'Khách hàng',
                        route: RouteNames.clients,
                      ),
                      _MenuEntry(
                        icon: SoloIcons.ai,
                        label: 'Báo giá chờ duyệt',
                        route: RouteNames.proposalReview,
                      ),
                      _MenuEntry(
                        icon: SoloIcons.folder,
                        label: 'Thư viện mẫu',
                        route: RouteNames.templates,
                      ),
                    ]),
                    const SectionHeader('Tài khoản'),
                    const _MenuCard([
                      _MenuEntry(
                        icon: SoloIcons.bell,
                        label: 'Thông báo',
                        route: RouteNames.notifications,
                      ),
                      _MenuEntry(
                        icon: SoloIcons.tag,
                        label: 'Gói và thanh toán',
                        route: RouteNames.plans,
                      ),
                      _MenuEntry(
                        icon: SoloIcons.dots,
                        label: 'Cài đặt',
                        route: RouteNames.settings,
                      ),
                    ]),
                    const SizedBox(height: AppGap.sectionTop),
                    const _LogOutButton(),
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

/// Tên và email của người đang đăng nhập.
///
/// Đọc `currentUserProvider` — controller nạp nó sau mỗi lần đăng nhập thành
/// công. Lần `/me` hỏng thì provider vẫn rỗng mà phiên vẫn hợp lệ (xem
/// `AuthController._loadCurrentUser`), nên chỗ này phải chịu được `null` chứ
/// không được coi đó là chưa đăng nhập.
class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.fullName, required this.email});

  final String fullName;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppGap.card),
        child: Row(
          children: [
            Avatar.initials(_initials(fullName), tone: Tone.money),
            const SizedBox(width: AppGap.row),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(fullName, style: AppText.bodyStrong),
                  if (email.isNotEmpty) Text(email, style: AppText.mut),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hai chữ cái đầu của tên. Tên một chữ thì lấy một chữ; rỗng thì trả về "?"
  /// để `Avatar.initials` luôn có gì đó để vẽ.
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
  });

  final SoloIconData icon;
  final String label;
  final String route;

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
            const SoloIcon(SoloIcons.chevron, label: null, size: SoloIcon.sm),
          ],
        ),
      ),
    );
  }
}

/// Đăng xuất. `AuthController.logout` tự xoá token và bắn `logoutProvider`,
/// router bắt tín hiệu đó rồi đưa về `/login` — màn này không tự điều hướng.
class _LogOutButton extends ConsumerWidget {
  const _LogOutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(authControllerProvider).isLoading;

    return OutlinedButton(
      onPressed: busy
          ? null
          : () => ref.read(authControllerProvider.notifier).logout(),
      style: AppTheme.outlined(),
      child: const Text('Đăng xuất'),
    );
  }
}
