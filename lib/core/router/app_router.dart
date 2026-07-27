import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/app/app_shell.dart';
import 'package:solodesk_mobile/core/router/route_guards.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/core/security/token_manager.dart';
import 'package:solodesk_mobile/modules/analytics/presentation/pages/revenue_page.dart';
import 'package:solodesk_mobile/modules/auth/presentation/pages/forgot_password_page.dart';
import 'package:solodesk_mobile/modules/auth/presentation/pages/login_landing_page.dart';
import 'package:solodesk_mobile/modules/auth/presentation/pages/login_page.dart';
import 'package:solodesk_mobile/modules/auth/presentation/pages/password_reset_confirm_page.dart';
import 'package:solodesk_mobile/modules/auth/presentation/pages/register_page.dart';
import 'package:solodesk_mobile/modules/auth/presentation/providers/auth_state_provider.dart';
import 'package:solodesk_mobile/modules/clients/presentation/pages/client_detail_page.dart';
import 'package:solodesk_mobile/modules/clients/presentation/pages/clients_page.dart';
import 'package:solodesk_mobile/modules/clients/presentation/pages/create_client_page.dart';
import 'package:solodesk_mobile/modules/deals/presentation/pages/deal_detail_page_new.dart';
import 'package:solodesk_mobile/modules/deals/presentation/pages/pipeline_page_new.dart';
import 'package:solodesk_mobile/modules/home/presentation/pages/home_offline_page.dart';
import 'package:solodesk_mobile/modules/home/presentation/pages/home_page_new.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/pages/invoice_detail_page.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/pages/invoice_form_page.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/pages/invoices_page.dart';
import 'package:solodesk_mobile/modules/notifications/presentation/pages/notifications_page.dart';
import 'package:solodesk_mobile/modules/projects/presentation/pages/evidence_page.dart';
import 'package:solodesk_mobile/modules/projects/presentation/pages/project_detail_page.dart';
import 'package:solodesk_mobile/modules/projects/presentation/pages/project_tasks_page.dart';
import 'package:solodesk_mobile/modules/projects/presentation/pages/projects_page.dart';
import 'package:solodesk_mobile/modules/proposals/presentation/pages/proposal_review_page.dart';
import 'package:solodesk_mobile/modules/reminders/presentation/pages/reminder_compose_page.dart';
import 'package:solodesk_mobile/modules/settings/presentation/pages/me_page.dart';
import 'package:solodesk_mobile/modules/settings/presentation/pages/settings_page.dart';
import 'package:solodesk_mobile/modules/subscriptions/presentation/pages/plans_page.dart';
import 'package:solodesk_mobile/modules/tasks/presentation/pages/task_detail_page.dart';
import 'package:solodesk_mobile/modules/templates/presentation/pages/templates_page.dart';
import 'package:solodesk_mobile/modules/voice_lead/presentation/pages/lead_score_page.dart';
import 'package:solodesk_mobile/modules/voice_lead/presentation/pages/voice_capture_page_new.dart';
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

/// Navigator gốc. Màn chi tiết nằm trong một nhánh của `StatefulShellRoute`
/// mặc định dựng *bên trong* shell, tức thanh tab vẫn nổi ở đáy và đè lên
/// `BottomActionBar` của chúng. Đẩy chúng lên navigator này thì chúng phủ kín
/// màn hình như một màn push bình thường.
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Một màn đẩy lên trên shell, dùng chung hiệu ứng trượt của [_slidePage].
GoRoute _pushed(
  String path,
  Widget Function(GoRouterState state) child, {
  List<RouteBase> routes = const [],
}) {
  return GoRoute(
    path: path,
    parentNavigatorKey: _rootNavigatorKey,
    pageBuilder: (context, state) =>
        _slidePage(context: context, state: state, child: child(state)),
    routes: routes,
  );
}

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final tokenManager = ref.read(tokenManagerProvider);
  final routerNotifier = RouterNotifier(ref);

  final goRouter = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.home,
    refreshListenable: routerNotifier,
    redirect: (context, state) => authGuard(state, tokenManager),
    routes: [
      // ── Ngoài phiên đăng nhập ───────────────────────────────────────────
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginLandingPage(),
        routes: [
          // Form email + mật khẩu là lối phụ của MÀN 01, không phải màn gốc.
          _pushed('email', (_) => const LoginPage()),
        ],
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

      // ── Màn phủ kín, mở ra từ tab "Tôi" hoặc từ nút ＋ ────────────────────
      _pushed(RouteNames.offline, (_) => const HomeOfflinePage()),
      _pushed(RouteNames.notifications, (_) => const NotificationsPage()),
      _pushed(
        RouteNames.voiceCapture,
        (_) => const VoiceCapturePage(),
        routes: [_pushed('score', (_) => const LeadScorePage())],
      ),
      _pushed(
        RouteNames.proposalReview,
        (s) => ProposalReviewPage(proposalId: s.pathParameters['id']!),
      ),
      _pushed(
        RouteNames.reminderCompose,
        (s) => ReminderComposePage(
          invoiceId: s.uri.queryParameters['invoiceId'] ?? '',
        ),
      ),
      _pushed(RouteNames.revenue, (_) => const RevenuePage()),
      _pushed(RouteNames.plans, (_) => const PlansPage()),
      _pushed(RouteNames.templates, (_) => const TemplatesPage()),
      _pushed(RouteNames.settings, (_) => const SettingsPage()),
      _pushed(
        RouteNames.taskDetail,
        (s) => TaskDetailPage(taskId: s.pathParameters['id']!),
      ),
      _pushed(
        RouteNames.clients,
        (_) => const ClientsPage(),
        routes: [
          _pushed('new', (_) => const CreateClientPage()),
          _pushed(
            ':id',
            (s) => ClientDetailPage(clientId: s.pathParameters['id']!),
          ),
        ],
      ),
      _pushed(
        RouteNames.invoices,
        (_) => const InvoicesPage(),
        routes: [
          _pushed(
            'new',
            (s) => InvoiceFormPage(preset: s.extra as InvoiceFormArgs?),
          ),
          _pushed(
            ':id',
            (s) => InvoiceDetailPage(invoiceId: s.pathParameters['id']!),
            routes: [
              _pushed(
                'edit',
                (s) => InvoiceFormPage(invoiceId: s.pathParameters['id']!),
              ),
            ],
          ),
        ],
      ),

      // ── Bốn màn gốc, thanh tab do AppShell cấp ──────────────────────────
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
                builder: (context, state) => const HomeTodayPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.deals,
                builder: (context, state) => const PipelinePage(),
                routes: [
                  _pushed(
                    ':id',
                    (s) => DealDetailPage(dealId: s.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.projects,
                builder: (context, state) => const ProjectsPage(),
                routes: [
                  _pushed(
                    ':id',
                    (s) =>
                        ProjectDetailPage(projectId: s.pathParameters['id']!),
                    routes: [
                      _pushed(
                        'tasks',
                        (s) => ProjectTasksPage(
                          projectId: s.pathParameters['id']!,
                        ),
                      ),
                      _pushed(
                        'evidence',
                        (s) => EvidencePage(projectId: s.pathParameters['id']!),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.me,
                builder: (context, state) => const MePage(),
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
