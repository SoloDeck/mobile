import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/dto/create_deal_request_dto.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/dto/deal_response_dto.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/dto/stage_transition_request_dto.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';
import 'package:solodesk_mobile/shared/models/api_response.dart';

class DealsRemoteDatasource {
  const DealsRemoteDatasource(this._client);

  final ApiClient _client;

  Future<List<DealResponseDto>> listDeals({DealStage? stage}) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.deals,
      queryParameters: {if (stage != null) 'stage': stage.wireValue},
    );
    final items = response.data!['data'] as List<dynamic>;
    return items
        .map((e) => DealResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DealResponseDto> getDeal(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.dealById(id),
    );
    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => DealResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<DealResponseDto> createDeal(CreateDealRequestDto request) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.deals,
      data: request.toJson(),
    );
    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => DealResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<DealResponseDto> transitionStage(
    String id,
    StageTransitionRequestDto request,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.dealStage(id),
      data: request.toJson(),
    );
    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => DealResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }
}
