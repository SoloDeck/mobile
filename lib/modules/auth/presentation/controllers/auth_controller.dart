import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/security/token_manager.dart';
import 'package:solodesk_mobile/modules/auth/application/usecases/login_usecase.dart';
import 'package:solodesk_mobile/modules/auth/application/usecases/login_with_google_usecase.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/datasource/google_sign_in_service.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/repository/auth_repository_impl.dart';

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
    state = await AsyncValue.guard(
      () => useCase(email: email, password: password).then((_) => true),
    );
    return state.value ?? false;
  }

  Future<bool> loginWithGoogle() async {
    state = const AsyncValue.loading();
    final useCase = LoginWithGoogleUseCase(
      ref.read(googleSignInServiceProvider),
      ref.read(authRepositoryProvider),
      ref.read(tokenManagerProvider),
    );
    state = await AsyncValue.guard(useCase.call);
    return state.value ?? false;
  }

  Future<void> logout() async {
    await ref.read(tokenManagerProvider).clearTokens();
    state = const AsyncValue.data(false);
  }
}
