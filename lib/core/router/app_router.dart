import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/app/app_shell.dart';
import 'package:solodesk_mobile/core/router/route_guards.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/core/security/token_manager.dart';
import 'package:solodesk_mobile/modules/auth/presentation/pages/forgot_password_page.dart';
import 'package:solodesk_mobile/modules/auth/presentation/pages/login_page.dart';
import 'package:solodesk_mobile/modules/auth/presentation/pages/password_reset_confirm_page.dart';
import 'package:solodesk_mobile/modules/auth/presentation/pages/register_page.dart';
import 'package:solodesk_mobile/modules/auth/presentation/providers/auth_state_provider.dart';
import 'package:solodesk_mobile/modules/analytics/presentation/pages/dashboard_page.dart';
import 'package:solodesk_mobile/modules/clients/presentation/pages/client_detail_page.dart';
import 'package:solodesk_mobile/modules/clients/presentation/pages/clients_page.dart';
import 'package:solodesk_mobile/modules/clients/presentation/pages/create_client_page.dart';
import 'package:solodesk_mobile/modules/deals/presentation/pages/deal_detail_page.dart';
import 'package:solodesk_mobile/modules/deals/presentation/pages/pipeline_page.dart';
import 'package:solodesk_mobile/modules/home/presentation/pages/home_page.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/pages/invoice_detail_page.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/pages/invoice_form_page.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/pages/invoices_page.dart';
import 'package:solodesk_mobile/modules/projects/presentation/pages/project_detail_page.dart';
import 'package:solodesk_mobile/modules/tasks/presentation/pages/task_detail_page.dart';
import 'package:solodesk_mobile/modules/settings/presentation/pages/settings_page.dart';
import 'package:solodesk_mobile/modules/voice_lead/presentation/pages/voice_capture_page.dart';
import 'package:solodesk_mobile/shared/widgets/swipe_back_wrapper.dart';

part 'app_router.g.dart';

// Slide-from-right + fade — used for push navigation (detail screens).
// Exit: faster than enter so the UI feels responsive (MD motion principle).
CustomTransitionPage<T> _slidePage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            ),
          );
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return SlideTransition(
        position: slide,
        child: FadeTransition(
          opacity: fade,
          child: SwipeBackWrapper(child: child),
        ),
      );
    },
  );
}

/// Makes GoRouter re-evaluate the redirect when token state changes.
/// Without this, the router's `redirect` only runs on navigation events.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    ref.listen(isAuthenticatedProvider, (_, _) => notifyListeners());
  }
}

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final tokenManager = ref.read(tokenManagerProvider);
  final routerNotifier = RouterNotifier(ref);

  final goRouter = GoRouter(
    initialLocation: RouteNames.home,
    refreshListenable: routerNotifier,
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
        path: RouteNames.voiceCapture,
        pageBuilder: (context, state) => _slidePage(
          context: context,
          state: state,
          child: const VoiceCapturePage(),
        ),
      ),
      GoRoute(
        path: RouteNames.settings,
        pageBuilder: (context, state) => _slidePage(
          context: context,
          state: state,
          child: const SettingsPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.projectDetail,
        pageBuilder: (context, state) => _slidePage(
          context: context,
          state: state,
          child: ProjectDetailPage(projectId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: RouteNames.taskDetail,
        pageBuilder: (context, state) => _slidePage(
          context: context,
          state: state,
          child: TaskDetailPage(taskId: state.pathParameters['id']!),
        ),
      ),
      // navigatorContainerBuilder provides SwipeableTabBody so all branches
      // are available during an interactive swipe without re-mounting them.
      StatefulShellRoute(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        navigatorContainerBuilder: (context, navigationShell, children) =>
            SwipeableTabBody(
              navigationShell: navigationShell,
              children: children,
            ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.deals,
                builder: (context, state) => const PipelinePage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) => _slidePage(
                      context: context,
                      state: state,
                      child: DealDetailPage(
                        dealId: state.pathParameters['id']!,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.clients,
                builder: (context, state) => const ClientsPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    pageBuilder: (context, state) => _slidePage(
                      context: context,
                      state: state,
                      child: const CreateClientPage(),
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) => _slidePage(
                      context: context,
                      state: state,
                      child: ClientDetailPage(
                        clientId: state.pathParameters['id']!,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.analytics,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.invoices,
                builder: (context, state) => const InvoicesPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    pageBuilder: (context, state) => _slidePage(
                      context: context,
                      state: state,
                      child: InvoiceFormPage(
                        preset: state.extra as InvoiceFormArgs?,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) => _slidePage(
                      context: context,
                      state: state,
                      child: InvoiceDetailPage(
                        invoiceId: state.pathParameters['id']!,
                      ),
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        pageBuilder: (context, state) => _slidePage(
                          context: context,
                          state: state,
                          child: InvoiceFormPage(
                            invoiceId: state.pathParameters['id']!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // When LogoutNotifier fires, imperatively navigate to /login (stack reset)
  // and immediately reset the flag so it only fires once.
  ref.listen(logoutProvider, (_, triggered) {
    if (triggered) {
      goRouter.go(RouteNames.login);
      ref.read(logoutProvider.notifier).reset();
    }
  });

  return goRouter;
}
