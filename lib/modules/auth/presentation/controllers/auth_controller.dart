import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/security/token_manager.dart';
import 'package:solodesk_mobile/modules/auth/application/usecases/fetch_me_usecase.dart';
import 'package:solodesk_mobile/modules/auth/application/usecases/login_usecase.dart';
import 'package:solodesk_mobile/modules/auth/application/usecases/login_with_google_usecase.dart';
import 'package:solodesk_mobile/modules/auth/application/usecases/logout_usecase.dart';
import 'package:solodesk_mobile/modules/auth/application/usecases/register_usecase.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/datasource/google_sign_in_service.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/repository/auth_repository_impl.dart';
import 'package:solodesk_mobile/modules/auth/presentation/providers/auth_state_provider.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  AsyncValue<bool> build() => const AsyncValue.data(false);

  Future<bool> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    final useCase = LoginUseCase(
      ref.read(authRepositoryProvider),
      ref.read(tokenManagerProvider),
    );
    state = await AsyncValue.guard(() async {
      await useCase(email: email, password: password);
      await _loadCurrentUser();
      return true;
    });
    return state.value ?? false;
  }

  Future<bool> loginWithGoogle() async {
    state = const AsyncValue.loading();
    final useCase = LoginWithGoogleUseCase(
      ref.read(googleSignInServiceProvider),
      ref.read(authRepositoryProvider),
      ref.read(tokenManagerProvider),
    );
    state = await AsyncValue.guard(() async {
      final success = await useCase();
      if (success) await _loadCurrentUser();
      return success;
    });
    return state.value ?? false;
  }

  /// Restores a session without user interaction (e.g. on app startup).
  /// Returns `true` when a session was restored. Does not surface errors as a
  /// failed state — a silent attempt failing is expected and non-fatal.
  Future<bool> trySilentLogin() async {
    final useCase = LoginWithGoogleUseCase(
      ref.read(googleSignInServiceProvider),
      ref.read(authRepositoryProvider),
      ref.read(tokenManagerProvider),
    );
    try {
      final restored = await useCase.trySilentLogin();
      if (restored) await _loadCurrentUser();
      return restored;
    } catch (_) {
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncValue.loading();
    final useCase = RegisterUseCase(ref.read(authRepositoryProvider));
    final tokenManager = ref.read(tokenManagerProvider);
    state = await AsyncValue.guard(() async {
      final token = await useCase.execute(email, password, fullName);
      await tokenManager.saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
      );
      await _loadCurrentUser();
      return true;
    });
    return state.value ?? false;
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    final useCase = LogoutUseCase(ref.read(authRepositoryProvider));
    try {
      await useCase.execute();
    } catch (_) {
      // Best-effort server revocation; always clear local session below.
    }
    await ref.read(tokenManagerProvider).clearTokens();
    ref.read(currentUserProvider.notifier).clear();
    state = const AsyncValue.data(false);
    // Notify router — triggers navigation reset to /login.
    ref.read(logoutProvider.notifier).trigger();
  }

  /// Loads the authenticated user into [currentUserProvider]. Best-effort:
  /// a failed /me call does not invalidate the successful sign-in.
  Future<void> _loadCurrentUser() async {
    try {
      final user = await FetchMeUseCase(
        ref.read(authRepositoryProvider),
      ).execute();
      ref.read(currentUserProvider.notifier).set(user);
    } catch (_) {
      // Ignore — the session is still valid even if profile load failed.
    }
  }
}
