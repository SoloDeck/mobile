import 'package:solodesk_mobile/modules/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repo);

  final AuthRepository _repo;

  Future<void> execute() => _repo.logout();
}
