import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/router/route_guards.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/core/security/token_manager.dart';
import 'package:solodesk_mobile/modules/auth/presentation/pages/forgot_password_page.dart';
import 'package:solodesk_mobile/modules/auth/presentation/pages/login_page.dart';
import 'package:solodesk_mobile/modules/auth/presentation/pages/password_reset_confirm_page.dart';
import 'package:solodesk_mobile/modules/auth/presentation/pages/register_page.dart';
import 'package:solodesk_mobile/modules/analytics/presentation/pages/dashboard_page.dart';
import 'package:solodesk_mobile/modules/clients/presentation/pages/client_detail_page.dart';
import 'package:solodesk_mobile/modules/clients/presentation/pages/clients_page.dart';
import 'package:solodesk_mobile/modules/clients/presentation/pages/create_client_page.dart';
import 'package:solodesk_mobile/modules/deals/presentation/pages/deal_detail_page.dart';
import 'package:solodesk_mobile/modules/deals/presentation/pages/pipeline_page.dart';
import 'package:solodesk_mobile/modules/home/presentation/pages/home_page.dart';

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
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: RouteNames.clients,
        builder: (context, state) => const ClientsPage(),
      ),
      GoRoute(
        path: '${RouteNames.clients}/new',
        builder: (context, state) => const CreateClientPage(),
      ),
      GoRoute(
        path: RouteNames.clientDetail,
        builder: (context, state) =>
            ClientDetailPage(clientId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RouteNames.deals,
        builder: (context, state) => const PipelinePage(),
      ),
      GoRoute(
        path: RouteNames.dealDetail,
        builder: (context, state) =>
            DealDetailPage(dealId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RouteNames.analytics,
        builder: (context, state) => const DashboardPage(),
      ),
    ],
  );
}
