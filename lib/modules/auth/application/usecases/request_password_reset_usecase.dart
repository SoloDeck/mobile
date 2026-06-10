import 'package:solodesk_mobile/modules/auth/domain/repositories/auth_repository.dart';

class RequestPasswordResetUseCase {
  const RequestPasswordResetUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String email) => _repository.requestPasswordReset(email);
}
