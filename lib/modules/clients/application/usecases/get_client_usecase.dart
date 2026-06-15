import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/domain/repositories/clients_repository.dart';

class GetClientUseCase {
  const GetClientUseCase(this._repository);

  final ClientsRepository _repository;

  Future<Client> call(String id) => _repository.getClient(id);
}
