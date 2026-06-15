import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/datasource/clients_local_datasource.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/datasource/clients_remote_datasource.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/dto/client_response_dto.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/repository/clients_repository_impl.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

class _MockClientsRemoteDatasource extends Mock
    implements ClientsRemoteDatasource {}

Client _client({String name = 'Cached client'}) => Client(
  id: 'client-1',
  ownerUserId: 'owner-1',
  name: name,
  type: ClientType.company,
  status: ClientStatus.active,
  dealCount: 2,
  createdAt: DateTime.utc(2026, 6, 14),
  email: 'client@example.com',
  updatedAt: DateTime.utc(2026, 6, 15),
);

ClientResponseDto _clientDto({String name = 'Remote client'}) =>
    ClientResponseDto(
      id: 'client-1',
      ownerUserId: 'owner-1',
      name: name,
      type: ClientType.company,
      status: ClientStatus.active,
      dealCount: 3,
      createdAt: '2026-06-14T00:00:00.000Z',
      email: 'client@example.com',
      updatedAt: '2026-06-15T00:00:00.000Z',
    );

void main() {
  late AppDatabase database;
  late ClientsLocalDatasource local;
  late _MockClientsRemoteDatasource remote;
  late ClientsRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    local = ClientsLocalDatasource(database);
    remote = _MockClientsRemoteDatasource();
    repository = ClientsRepositoryImpl(remote, local);
  });

  tearDown(() => database.close());

  test('listClients returns cached clients when remote is offline', () async {
    await local.upsertClients([_client()]);
    when(
      () => remote.listClients(status: null, name: null, email: null),
    ).thenThrow(NetworkException.noConnection());

    final result = await repository.listClients();

    expect(result, [_client()]);
  });

  test('successful listClients refresh upserts remote clients', () async {
    await local.upsertClients([_client(name: 'Stale client')]);
    when(
      () => remote.listClients(status: null, name: null, email: null),
    ).thenAnswer((_) async => [_clientDto()]);

    final result = await repository.listClients();
    final cached = await local.listClients();

    expect(result.single.name, 'Remote client');
    expect(cached, hasLength(1));
    expect(cached.single.name, 'Remote client');
    expect(cached.single.dealCount, 3);
  });
}
