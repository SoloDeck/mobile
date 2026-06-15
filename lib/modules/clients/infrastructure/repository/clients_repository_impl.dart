import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/domain/repositories/clients_repository.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/datasource/clients_local_datasource.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/datasource/clients_remote_datasource.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/dto/create_client_request_dto.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/mapper/client_mapper.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

part 'clients_repository_impl.g.dart';

class ClientsRepositoryImpl implements ClientsRepository {
  const ClientsRepositoryImpl(this._remote, this._local);

  final ClientsRemoteDatasource _remote;
  final ClientsLocalDatasource _local;

  @override
  Future<List<Client>> listClients({
    ClientStatus? status,
    String? name,
    String? email,
  }) async {
    try {
      final dtos = await _remote.listClients(
        status: status,
        name: name,
        email: email,
      );
      final clients = dtos.map((dto) => dto.toDomain()).toList();
      await _local.upsertClients(clients);
      return clients;
    } on NetworkException {
      return _local.listClients(status: status, name: name, email: email);
    }
  }

  @override
  Future<Client> getClient(String id) async {
    final dto = await _remote.getClient(id);
    return dto.toDomain();
  }

  @override
  Future<Client> createClient({
    required String name,
    ClientType? type,
    String? email,
    String? phone,
    String? notes,
  }) async {
    final dto = await _remote.createClient(
      CreateClientRequestDto(
        name: name,
        type: type,
        email: email,
        phone: phone,
        notes: notes,
      ),
    );
    final client = dto.toDomain();
    await _local.upsertClients([client]);
    return client;
  }
}

@Riverpod(keepAlive: true)
ClientsRepository clientsRepository(Ref ref) {
  final client = ref.read(apiClientProvider);
  final database = ref.read(appDatabaseProvider);
  return ClientsRepositoryImpl(
    ClientsRemoteDatasource(client),
    ClientsLocalDatasource(database),
  );
}
