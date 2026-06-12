import 'package:solodesk_mobile/modules/auth/domain/repositories/auth_repository.dart';

class ConfirmPasswordResetUseCase {
  const ConfirmPasswordResetUseCase(this._repo);

  final AuthRepository _repo;

  Future<void> execute(String token, String newPassword) =>
      _repo.confirmPasswordReset(token, newPassword);
}
