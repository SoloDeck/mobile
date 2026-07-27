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

/// Các màn mở được khi chưa có phiên. Thiếu một cái ở đây thì guard đá người
/// dùng về `/login` ngay khi họ mở nó — `loginEmail` là màn form của chính
/// `/login`, còn `resetPassword` mở từ link trong email nên người bấm vào gần
/// như luôn ở trạng thái chưa đăng nhập.
const _authRoutes = {
  RouteNames.login,
  RouteNames.loginEmail,
  RouteNames.register,
  RouteNames.forgotPassword,
  RouteNames.resetPassword,
};
