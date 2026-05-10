
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/domain/providers/auth_provider.dart';
import 'package:mobile/presentation/auth/login_screen.dart';
import 'package:mobile/presentation/home/home_screen.dart';
import 'package:mobile/presentation/pipeline/pipeline_screen.dart';

/// Provider cho GoRouter, tích hợp redirect dựa trên auth state.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/pipeline',
        builder: (context, state) => const PipelineScreen(),
      ),
    ],
  );
});
