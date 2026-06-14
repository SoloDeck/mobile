import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/datasource/auth_remote_datasource.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  late _MockApiClient client;
  late AuthRemoteDatasource datasource;

  setUp(() {
    client = _MockApiClient();
    datasource = AuthRemoteDatasource(client);
  });

  Response<Map<String, dynamic>> tokenResponse() => Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: ApiEndpoints.authGoogle),
        data: {
          'success': true,
          'code': 200,
          'timestamp': '2026-06-14T00:00:00Z',
          'data': {
            'access_token': 'access',
            'refresh_token': 'refresh',
            'token_type': 'bearer',
            'expires_in': 900,
          },
        },
      );

  test('loginWithGoogle posts the id token and platform to /auth/google', () async {
    when(
      () => client.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
    ).thenAnswer((_) async => tokenResponse());

    await datasource.loginWithGoogle('the-id-token');

    final body = verify(
      () => client.post<Map<String, dynamic>>(
        ApiEndpoints.authGoogle,
        data: captureAny(named: 'data'),
      ),
    ).captured.single as Map<String, dynamic>;

    expect(body['id_token'], 'the-id-token');
    expect(body['platform'], anyOf('android', 'ios'));
  });
}
