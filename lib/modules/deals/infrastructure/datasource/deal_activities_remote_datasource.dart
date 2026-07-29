import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/dto/deal_activity_response_dto.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';

class DealActivitiesRemoteDatasource {
  const DealActivitiesRemoteDatasource(this._client);

  final ApiClient _client;

  Future<List<DealActivityResponseDto>> listActivities(
    String dealId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.dealActivities(dealId),
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    final items = response.data!['data'] as List<dynamic>;
    return items
        .map(
          (e) => DealActivityResponseDto.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }
}
