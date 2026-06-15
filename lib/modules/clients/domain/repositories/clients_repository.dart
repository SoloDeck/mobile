import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';

/// Contract for reading and creating clients. Implemented in
/// `infrastructure/repository/clients_repository_impl.dart`.
abstract interface class ClientsRepository {
  Future<List<Client>> listClients({
    ClientStatus? status,
    String? name,
    String? email,
  });

  Future<Client> getClient(String id);

  Future<Client> createClient({
    required String name,
    ClientType? type,
    String? email,
    String? phone,
    String? notes,
  });
}
