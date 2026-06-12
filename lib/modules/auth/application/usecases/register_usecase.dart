import 'package:solodesk_mobile/modules/auth/domain/entities/auth_token.dart';
import 'package:solodesk_mobile/modules/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repo);

  final AuthRepository _repo;

  Future<AuthToken> execute(String email, String password, String fullName) =>
      _repo.register(email: email, password: password, fullName: fullName);
}
