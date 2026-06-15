import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/domain/repositories/clients_repository.dart';

class CreateClientUseCase {
  const CreateClientUseCase(this._repository);

  final ClientsRepository _repository;

  Future<Client> call({
    required String name,
    ClientType? type,
    String? email,
    String? phone,
    String? notes,
  }) => _repository.createClient(
    name: name,
    type: type,
    email: email,
    phone: phone,
    notes: notes,
  );
}
