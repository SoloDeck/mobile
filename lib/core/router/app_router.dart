import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/router/route_guards.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/core/security/token_manager.dart';
import 'package:solodesk_mobile/modules/auth/presentation/pages/forgot_password_page.dart';
import 'package:solodesk_mobile/modules/auth/presentation/pages/login_page.dart';
import 'package:solodesk_mobile/modules/auth/presentation/pages/password_reset_confirm_page.dart';
import 'package:solodesk_mobile/modules/auth/presentation/pages/register_page.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final tokenManager = ref.read(tokenManagerProvider);

  return GoRouter(
    initialLocation: RouteNames.home,
    redirect: (context, state) => authGuard(state, tokenManager),
    routes: [
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (context, state) => PasswordResetConfirmPage(
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const _AuthPlaceholderPage(label: 'Home'),
      ),
    ],
  );
}

// Temporary placeholder — replace with actual screen widgets from modules.
class _AuthPlaceholderPage extends StatelessWidget {
  const _AuthPlaceholderPage({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}
