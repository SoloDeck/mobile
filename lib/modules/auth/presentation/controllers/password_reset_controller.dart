import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/auth/application/usecases/confirm_password_reset_usecase.dart';
import 'package:solodesk_mobile/modules/auth/application/usecases/request_password_reset_usecase.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/repository/auth_repository_impl.dart';

part 'password_reset_controller.g.dart';

@riverpod
class PasswordResetController extends _$PasswordResetController {
  @override
  AsyncValue<bool> build() => const AsyncValue.data(false);

  /// Requests a reset email. Returns `true` when the request succeeded.
  Future<bool> requestReset(String email) async {
    state = const AsyncValue.loading();
    final useCase = RequestPasswordResetUseCase(
      ref.read(authRepositoryProvider),
    );
    state = await AsyncValue.guard(() => useCase(email).then((_) => true));
    return state.value ?? false;
  }

  /// Applies a new password via the reset token. Returns `true` on success.
  Future<bool> confirmReset(String token, String newPassword) async {
    state = const AsyncValue.loading();
    final useCase = ConfirmPasswordResetUseCase(
      ref.read(authRepositoryProvider),
    );
    state = await AsyncValue.guard(
      () => useCase.execute(token, newPassword).then((_) => true),
    );
    return state.value ?? false;
  }
}
