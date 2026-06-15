import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/voice_lead/infrastructure/dto/lead_qualification_request_dto.dart';
import 'package:solodesk_mobile/modules/voice_lead/infrastructure/dto/lead_qualification_response_dto.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';

class AiLeadsDatasource {
  const AiLeadsDatasource(this._client);

  final ApiClient _client;

  Future<LeadQualificationResponseDto> qualify(
    LeadQualificationRequestDto request,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.aiLeadsQualify,
      data: request.toJson(),
    );
    return LeadQualificationResponseDto.fromJson(response.data!);
  }
}
