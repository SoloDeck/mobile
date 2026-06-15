import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/domain/repositories/clients_repository.dart';

class ListClientsUseCase {
  const ListClientsUseCase(this._repository);

  final ClientsRepository _repository;

  Future<List<Client>> call({
    ClientStatus? status,
    String? name,
    String? email,
  }) => _repository.listClients(status: status, name: name, email: email);
}
