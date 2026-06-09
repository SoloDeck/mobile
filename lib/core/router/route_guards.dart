import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/core/security/token_manager.dart';

Future<String?> authGuard(
  GoRouterState state,
  TokenManager tokenManager,
) async {
  final token = await tokenManager.getAccessToken();
  final isAuthenticated = token != null;
  final isAuthRoute = _authRoutes.contains(state.matchedLocation);

  if (!isAuthenticated && !isAuthRoute) return RouteNames.login;
  if (isAuthenticated && isAuthRoute) return RouteNames.home;
  return null;
}

const _authRoutes = {
  RouteNames.login,
  RouteNames.register,
  RouteNames.forgotPassword,
};
