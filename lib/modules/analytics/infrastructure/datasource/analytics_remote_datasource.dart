import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/analytics/infrastructure/dto/dashboard_response_dto.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';
import 'package:solodesk_mobile/shared/models/api_response.dart';

class AnalyticsRemoteDatasource {
  const AnalyticsRemoteDatasource(this._client);

  final ApiClient _client;

  Future<DashboardResponseDto> getDashboard() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.analyticsDashboard,
    );
    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => DashboardResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }
}
