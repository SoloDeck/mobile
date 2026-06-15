import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/datasource/clients_remote_datasource.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/dto/create_client_request_dto.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  late _MockApiClient client;
  late ClientsRemoteDatasource datasource;

  setUp(() {
    client = _MockApiClient();
    datasource = ClientsRemoteDatasource(client);
  });

  Map<String, dynamic> clientJson(String id, String name) => {
    'id': id,
    'owner_user_id': 'owner-1',
    'name': name,
    'type': 'individual',
    'status': 'prospect',
    'deal_count': 1,
    'created_at': '2026-06-14T00:00:00Z',
    'updated_at': '2026-06-14T00:00:00Z',
  };

  Response<Map<String, dynamic>> envelope(Object? data) =>
      Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: ApiEndpoints.clients),
        data: {
          'success': true,
          'code': 200,
          'timestamp': '2026-06-14T00:00:00Z',
          'data': data,
        },
      );

  test('listClients parses the data array into DTOs', () async {
    when(
      () => client.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async =>
          envelope([clientJson('c1', 'Anh Tú'), clientJson('c2', 'Chị Lan')]),
    );

    final result = await datasource.listClients();

    expect(result, hasLength(2));
    expect(result.first.name, 'Anh Tú');
    expect(result.first.dealCount, 1);
  });

  test('createClient POSTs only the provided fields to /clients', () async {
    when(
      () => client.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
    ).thenAnswer((_) async => envelope(clientJson('c1', 'Anh Tú')));

    await datasource.createClient(
      const CreateClientRequestDto(
        name: 'Anh Tú',
        type: ClientType.individual,
        email: 'tu@example.com',
      ),
    );

    final body =
        verify(
              () => client.post<Map<String, dynamic>>(
                ApiEndpoints.clients,
                data: captureAny(named: 'data'),
              ),
            ).captured.single
            as Map<String, dynamic>;

    expect(body['name'], 'Anh Tú');
    expect(body['type'], 'individual');
    expect(body['email'], 'tu@example.com');
    // Null fields are omitted from the request body.
    expect(body.containsKey('phone'), isFalse);
    expect(body.containsKey('notes'), isFalse);
  });
}
