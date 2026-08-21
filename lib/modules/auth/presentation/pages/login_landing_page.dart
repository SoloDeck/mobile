import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/modules/auth/presentation/controllers/auth_controller.dart';
import 'package:solodesk_mobile/modules/auth/presentation/providers/last_login_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/avatar.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

/// MÀN 01 — Đăng nhập.
///
/// Đối chiếu: khối `<figure class="unit">` "01 Đăng nhập" (dòng 278-310 của
/// `design/solodesk-mobile-ui.html`), gồm cả `<figcaption>` "MÀN 01".
///
/// Ba quyết định trong figcaption, đừng đảo lại khi sửa:
/// - **Nhớ tài khoản gần nhất để một chạm.** Thẻ "Lần đăng nhập gần nhất" hiện
///   sẵn chủ máy và có thể bấm thẳng vào — freelancer hiếm khi đổi máy nên
///   không bắt gõ lại email/mật khẩu.
/// - **Google OAuth 2.0 đứng trên cùng, email là lối phụ.** Nút Google dùng
///   nút đặc (`Tone.solid`, hành động chính), nút email dùng nút viền và nằm
///   *dưới* nút Google — đúng thứ tự trong bản phác thảo.
/// - **Câu chào nói về việc, không nói về sản phẩm.** Tiêu đề là "Chào bạn.
///   Việc hôm nay đợi sẵn rồi." — không nhắc tên app hay tính năng.
///
/// Thẻ "Lần đăng nhập gần nhất" cố ý dựng bằng `Card`, không phải `SlipCard`,
/// dù bản phác thảo dùng `.slip` — nội dung không phải tiền. Đây là ngoại lệ
/// đã chốt ở quy tắc 3 (`AGENTS.md`), xem thêm doc comment của `SlipCard` và
/// `docs/adr/solodesk-ui-config-conflicts.md`.
///
/// Màn này **không** bọc `SingleChildScrollView`: nội dung có độ cao cố định,
/// vừa khít khung 390 × 844 (phần trên `flex:1; justify-content:center`, phần
/// dưới đứng yên ở đáy) và không có `SoloNavBar`. `BottomActionBar` cũng ghi rõ
/// đây là một trong hai trường hợp không dùng dải nổi ở đáy — không có gì trôi
/// qua bên dưới nút để cần gradient báo hiệu.
///
/// `authControllerProvider` (`lib/modules/auth/presentation/controllers/`) là
/// controller *lệnh* — `AsyncValue<bool> build()` không giữ dữ liệu để đọc,
/// chỉ có các phương thức `login`/`loginWithGoogle`/... Màn này chỉ dùng nó để
/// gọi lệnh và đọc `isLoading`. Tên và email trong thẻ "Lần đăng nhập gần
/// nhất" đến từ `lastLoginAccountProvider` — dữ liệu thật đã lưu trên máy sau
/// lần đăng nhập trước, không phải dữ liệu mẫu.
class LoginLandingPage extends ConsumerWidget {
  const LoginLandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lỗi đăng nhập nổi lên bằng snackbar chứ không đổi bố cục màn: bản phác
    // thảo không chừa chỗ nào cho một dải báo lỗi, và chèn vào thì hai nút
    // dưới đáy bị đẩy khỏi vị trí cố định của chúng.
    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        final error = next.error;
        final message = error is AppException
            ? error.message
            : 'Đăng nhập không thành công';
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.momoDeep,
            ),
          );
      }
    });

    final appearance = ref.watch(appearanceControllerProvider);

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: const Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppGap.screen,
              0,
              AppGap.screen,
              // Bản phác thảo: `padding-bottom:24px` ghi đè phần đệm 96px dành
              // cho tab bar — màn này không có tab bar. 24 không có token đúng
              // khớp, lấy AppGap.xxxl (26) là số gần nhất trong thang số trần.
              AppGap.xxxl,
            ),
            child: Column(
              children: [
                Expanded(child: Center(child: _Greeting())),
                _SignInActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chạy đăng nhập Google rồi vào thẳng trang chủ.
///
/// Người dùng bấm huỷ ở hộp chọn tài khoản thì `loginWithGoogle` trả `false` —
/// không phải lỗi, nên không báo gì và cũng không điều hướng.
Future<void> _signInWithGoogle(BuildContext context, WidgetRef ref) async {
  final success = await ref
      .read(authControllerProvider.notifier)
      .loginWithGoogle();
  if (!context.mounted) return;
  if (success) context.go(RouteNames.home);
}

/// Logo, câu chào, đoạn giải thích, và tấm thẻ nhớ tài khoản gần nhất.
class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Avatar.initials('S', tone: Tone.ai, size: Avatar.lg),
        // Bản phác thảo: margin-top 24px. Không có token 24 khớp, dùng
        // AppGap.xxl (22) — số gần nhất trong thang số trần.
        const SizedBox(height: AppGap.xxl),
        const Text(
          'Chào bạn.\nViệc hôm nay\nđợi sẵn rồi.',
          style: AppText.hero,
        ),
        const SizedBox(height: AppGap.card),
        Text(
          _Copy.subtitle,
          // `.sub` mặc định 12.5px màu ink2, nhưng bản phác thảo ghi đè cỡ chữ
          // thành 14px cho riêng đoạn này — đúng khớp AppText.body. Giữ màu
          // mờ (ink2) của `.sub` bằng copyWith, không viết cứng màu mới.
          style: AppText.body.copyWith(color: AppColors.ink2),
        ),
        // Khoảng trống trên thẻ nằm *trong* `_LastLoginCard`: máy chưa từng
        // đăng nhập thì cả thẻ lẫn khoảng trống phải biến mất, nếu để
        // `SizedBox` ở đây thì câu chào bị đẩy lên vô cớ.
        const _LastLoginCard(),
      ],
    );
  }
}

/// Thẻ "Lần đăng nhập gần nhất" — bấm thẳng vào là đăng nhập lại bằng tài
/// khoản này, đúng ý "một chạm" trong figcaption. `Card` chứ không phải
/// `SlipCard`: nội dung không phải tiền (xem doc comment của
/// `LoginLandingPage`).
///
/// Máy chưa từng đăng nhập thành công lần nào thì thẻ **không hiện** — thà
/// thiếu một lối tắt còn hơn chào sai tên người đang cầm máy.
class _LastLoginCard extends ConsumerWidget {
  const _LastLoginCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Đọc keychain là việc bất đồng bộ nhưng rất nhanh: trong lúc chờ (và khi
    // đọc lỗi) coi như chưa có tài khoản nào, không dựng chỗ trống chờ sẵn —
    // một ô xám nhấp nháy ở giữa câu chào tệ hơn là không có gì.
    final account = ref.watch(lastLoginAccountProvider).value;
    if (account == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppGap.xxxl),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          // "Một chạm" ở đây vẫn phải qua hộp chọn tài khoản của Google: không
          // có API nào đăng nhập thẳng vào một tài khoản đã biết mà bỏ qua bước
          // xác nhận. Rút ngắn được đúng một bước — không phải gõ lại email.
          onTap: () => _signInWithGoogle(context, ref),
          child: Padding(
            padding: const EdgeInsets.all(AppGap.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SectionLabel('Lần đăng nhập gần nhất'),
                const SizedBox(height: AppGap.md),
                Row(
                  children: [
                    Avatar.initials(account.initials, tone: Tone.money),
                    const SizedBox(width: AppGap.row),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            account.fullName,
                            style: AppText.bodyStrong,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            account.email,
                            style: AppText.mut,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SoloIcon(
                      SoloIcons.chevron,
                      label: null,
                      size: SoloIcon.sm,
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

/// Hai lối đăng nhập — Google trên cùng (nút đặc, hành động chính), email là
/// lối phụ (nút viền) — và dòng điều khoản ở dưới cùng.
class _SignInActions extends ConsumerWidget {
  const _SignInActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Khoá cả hai nút trong lúc chờ Google và chờ backend đổi token, nếu không
    // bấm hai lần sẽ mở hai phiên `authenticate()` chồng nhau.
    final busy = ref.watch(authControllerProvider).isLoading;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: busy ? null : () => _signInWithGoogle(context, ref),
          style: AppTheme.filled(),
          icon: const SoloIcon(
            SoloIcons.check,
            label: null,
            size: SoloIcon.sm,
            color: AppColors.surface,
          ),
          label: const Text('Tiếp tục với Google'),
        ),
        const SizedBox(height: AppGap.betweenButtons),
        OutlinedButton(
          onPressed: busy ? null : () => context.push(RouteNames.loginEmail),
          style: AppTheme.outlined(),
          child: const Text('Đăng nhập bằng email'),
        ),
        const SizedBox(height: AppGap.xl),
        const Text(
          'Tiếp tục nghĩa là bạn đồng ý với Điều khoản\n'
          'và Chính sách bảo mật của SoloDesk.',
          style: AppText.mut,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Chuỗi cố định của màn, chép nguyên văn từ bản phác thảo (MÀN 01).
///
/// Là class chứ không phải record vì Dart không cho đọc field của record trong
/// biểu thức `const`, mà widget của màn này phải const được. Tên viết hoa theo
/// lint `camel_case_types` của repo.
abstract final class _Copy {
  static const String subtitle =
      'Đăng nhập để đồng bộ pipeline, hợp đồng và lịch nhắc thu tiền giữa '
      'máy tính và điện thoại.';
}
