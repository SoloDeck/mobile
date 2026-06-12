import 'package:solodesk_mobile/modules/auth/domain/entities/auth_user.dart';
import 'package:solodesk_mobile/modules/auth/domain/repositories/auth_repository.dart';

class FetchMeUseCase {
  const FetchMeUseCase(this._repo);

  final AuthRepository _repo;

  Future<AuthUser> execute() => _repo.fetchMe();
}
