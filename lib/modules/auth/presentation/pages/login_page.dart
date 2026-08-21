import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/modules/auth/presentation/controllers/auth_controller.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/ui/brand_mark.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

/// Form email + mật khẩu — lối phụ của MÀN 01, mở ra từ nút "Đăng nhập bằng
/// email" ở `LoginLandingPage`.
///
/// Bản phác thảo không vẽ riêng màn này (MÀN 01 chỉ có hai nút), nên nó mượn
/// đúng ngôn ngữ của MÀN 01 để hai màn không lệch nhau: nền giấy, khối nhận
/// diện ở đầu màn, tiêu đề `AppText.hero`, nút đặc cho hành động chính và nút
/// viền cho lối phụ. Không dùng `lib/core/theme/` như bản cũ — hai theme cố ý
/// tách nhau, xem `docs/adr/solodesk-ui-config-conflicts.md`.
///
/// Ba điểm cố ý, đừng đảo lại khi sửa:
/// - **Tiêu đề là "Đăng nhập", không phải một câu chào.** Người bấm vào đây là
///   người *chọn* gõ email; câu chào đã nói ở MÀN 01 rồi, nhắc lại chỉ tốn một
///   phần ba màn hình.
/// - **Google vẫn còn ở đây, nhưng là nút viền.** Vào nhầm màn thì vẫn quay ra
///   được bằng một chạm, mà không tranh chỗ với hành động chính của màn này.
/// - **Nút hiện/ẩn mật khẩu là chữ, không phải icon con mắt.** `SoloIcons`
///   không có con mắt, và lấy tạm `Icons.*` của Material thì nét dày hơn hẳn,
///   đặt cạnh bộ icon của bản phác thảo là lộ ngay.
///
/// Màn này bọc `SingleChildScrollView` — khác MÀN 01 — vì bàn phím ăn mất gần
/// nửa chiều cao khi đang gõ mật khẩu.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    if (success) context.go(RouteNames.home);
  }

  Future<void> _submitGoogle() async {
    FocusScope.of(context).unfocus();
    final success = await ref
        .read(authControllerProvider.notifier)
        .loginWithGoogle();

    if (!mounted) return;
    if (success) context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    // Cùng cách báo lỗi với MÀN 01: snackbar hồng, không chèn dải lỗi vào thân
    // màn — chèn vào thì mọi thứ dưới nó tụt xuống ngay giữa lúc đang gõ.
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
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          child: Column(
            children: [
              // `IconButtonBox` rộng hơn hình vẽ 3pt mỗi bên để đủ vùng chạm
              // 44; trừ đúng phần đó để mép ô thẳng hàng với lề 18 của nội dung
              // bên dưới — giống cách `SoloAppBar` làm.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppGap.screen - IconButtonBox.overhang,
                  4,
                  AppGap.screen,
                  0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButtonBox(
                    SoloIcons.back,
                    label: 'Quay lại',
                    ghost: true,
                    // `/login/email` là route con được *push*, nên bình thường
                    // luôn pop được. Mở thẳng bằng deep link thì ngăn xếp
                    // rỗng — khi ấy quay về MÀN 01 thay vì kẹt lại đây.
                    onTap: isLoading
                        ? null
                        : () => context.canPop()
                              ? context.pop()
                              : context.go(RouteNames.login),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppGap.screen,
                    0,
                    AppGap.screen,
                    AppGap.xxxl,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: BrandMark(),
                        ),
                        // Bản phác thảo: margin-top 24px sau khối nhận diện.
                        // Không có token 24, dùng AppGap.xxl (22) — số gần nhất
                        // trong thang số trần.
                        const SizedBox(height: AppGap.xxl),
                        const Text('Đăng nhập', style: AppText.hero),
                        const SizedBox(height: AppGap.card),
                        Text(
                          'Dùng email và mật khẩu của tài khoản SoloDesk. '
                          'Chưa đặt mật khẩu thì quay lại và tiếp tục với '
                          'Google.',
                          style: AppText.body.copyWith(color: AppColors.ink2),
                        ),
                        const SizedBox(height: AppGap.xxxl),

                        const SectionLabel('Email'),
                        const SizedBox(height: AppGap.sectionBottom),
                        TextFormField(
                          controller: _emailController,
                          enabled: !isLoading,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          style: AppText.body,
                          decoration: _fieldDecoration(hint: 'ban@congty.vn'),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty) return 'Chưa nhập email';
                            if (!email.contains('@') || !email.contains('.')) {
                              return 'Email chưa đúng định dạng';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppGap.sectionTop),

                        const SectionLabel('Mật khẩu'),
                        const SizedBox(height: AppGap.sectionBottom),
                        TextFormField(
                          controller: _passwordController,
                          enabled: !isLoading,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _submit(),
                          style: AppText.body,
                          decoration: _fieldDecoration(
                            hint: 'Mật khẩu của bạn',
                            suffix: _RevealButton(
                              revealed: !_obscurePassword,
                              onTap: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (value) =>
                              (value ?? '').isEmpty ? 'Chưa nhập mật khẩu' : null,
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () => context.go(RouteNames.forgotPassword),
                            child: const Text(
                              'Quên mật khẩu?',
                              style: AppText.link,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppGap.lg),

                        FilledButton(
                          onPressed: isLoading ? null : _submit,
                          style: AppTheme.filled(),
                          child: isLoading
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors.surface,
                                  ),
                                )
                              : const Text('Đăng nhập'),
                        ),
                        const SizedBox(height: AppGap.betweenButtons),
                        OutlinedButton.icon(
                          onPressed: isLoading ? null : _submitGoogle,
                          style: AppTheme.outlined(),
                          icon: const _GoogleLogo(),
                          label: const Text('Tiếp tục với Google'),
                        ),
                        const SizedBox(height: AppGap.xl),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Chưa có tài khoản? ',
                              style: AppText.mut,
                            ),
                            GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () => context.go(RouteNames.register),
                              child: const Text(
                                'Đăng ký',
                                style: AppText.link,
                              ),
                            ),
                          ],
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

/// Ô nhập của màn này: nền trắng, viền `AppColors.line`, bo đúng bán kính nút
/// (14) như mọi khối bấm được khác của bản phác thảo.
///
/// `AppTheme.light` cố ý không cấu hình `inputDecorationTheme` — bản phác thảo
/// không vẽ màn nào toàn form, nên hình dáng ô nhập được quyết định tại chỗ.
/// Màn thứ hai cần đúng hình này thì chuyển nó sang `lib/ui/`.
InputDecoration _fieldDecoration({required String hint, Widget? suffix}) {
  OutlineInputBorder border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    hintText: hint,
    hintStyle: AppText.body.copyWith(color: AppColors.ink3),
    filled: true,
    fillColor: AppColors.surface,
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppGap.card,
      vertical: AppGap.lg,
    ),
    border: border(AppColors.line),
    enabledBorder: border(AppColors.line),
    disabledBorder: border(AppColors.line),
    focusedBorder: border(AppColors.ink, width: 1.5),
    errorBorder: border(AppColors.momo),
    focusedErrorBorder: border(AppColors.momo, width: 1.5),
    errorStyle: AppText.mut.copyWith(color: AppColors.momoDeep),
  );
}

/// Hiện / ẩn mật khẩu. Là chữ chứ không phải con mắt, xem doc comment của
/// [LoginPage]; hộp bố cục giữ vùng chạm cao 44 dù chữ chỉ cao 16.
class _RevealButton extends StatelessWidget {
  const _RevealButton({required this.revealed, required this.onTap});

  final bool revealed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: revealed ? 'Ẩn mật khẩu' : 'Hiện mật khẩu',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 64,
          height: IconButtonBox.tapTarget,
          child: Center(
            child: ExcludeSemantics(
              child: Text(revealed ? 'Ẩn' : 'Hiện', style: AppText.link),
            ),
          ),
        ),
      ),
    );
  }
}

/// Vòng tròn bốn màu của Google, vẽ tay: `SoloIcons` chỉ chứa bộ icon của
/// SoloDesk, còn logo của hãng khác thì không được đổi màu theo tone.
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 20,
    height: 20,
    child: CustomPaint(painter: _GoogleLogoPainter()),
  );
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  static const _blue = AppColors.googleBlue;
  static const _red = AppColors.googleRed;
  static const _yellow = AppColors.googleYellow;
  static const _green = AppColors.googleGreen;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.22;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Vòng tròn cắt thành 4 cung màu thương hiệu (radian, 0 = hướng 3 giờ).
    canvas.drawArc(rect, -0.35, 1.20, false, paint..color = _blue);
    canvas.drawArc(rect, 0.90, 1.30, false, paint..color = _green);
    canvas.drawArc(rect, 2.25, 1.45, false, paint..color = _yellow);
    canvas.drawArc(rect, 3.75, 1.75, false, paint..color = _red);

    // Thanh ngang màu xanh của chữ "G".
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawRect(
      Rect.fromLTRB(
        cx,
        cy - stroke / 2,
        size.width - stroke / 2,
        cy + stroke / 2,
      ),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
