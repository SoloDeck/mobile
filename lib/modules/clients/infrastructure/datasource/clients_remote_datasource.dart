import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/dto/client_response_dto.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/dto/create_client_request_dto.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';
import 'package:solodesk_mobile/shared/models/api_response.dart';

class ClientsRemoteDatasource {
  const ClientsRemoteDatasource(this._client);

  final ApiClient _client;

  Future<List<ClientResponseDto>> listClients({
    ClientStatus? status,
    String? name,
    String? email,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.clients,
      queryParameters: {
        if (status != null) 'status': status.name,
        if (name != null && name.isNotEmpty) 'name': name,
        if (email != null && email.isNotEmpty) 'email': email,
      },
    );
    final items = response.data!['data'] as List<dynamic>;
    return items
        .map((e) => ClientResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ClientResponseDto> getClient(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.clientById(id),
    );
    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => ClientResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<ClientResponseDto> createClient(CreateClientRequestDto request) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.clients,
      data: request.toJson(),
    );
    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => ClientResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }
}
