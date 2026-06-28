import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/projects/domain/value_objects/project_status.dart';
import 'package:solodesk_mobile/modules/projects/infrastructure/dto/create_project_request_dto.dart';
import 'package:solodesk_mobile/modules/projects/infrastructure/dto/project_response_dto.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';
import 'package:solodesk_mobile/shared/models/api_response.dart';

class ProjectsRemoteDatasource {
  const ProjectsRemoteDatasource(this._client);

  final ApiClient _client;

  Future<List<ProjectResponseDto>> listProjects({
    String? dealId,
    ProjectStatus? status,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.projects,
      queryParameters: {
        'deal_id': ?dealId,
        if (status != null) 'status': status.wireValue,
      },
    );
    final items = response.data!['data'] as List<dynamic>;
    return items
        .map((e) => ProjectResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProjectResponseDto> getProject(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.projectById(id),
    );
    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => ProjectResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<ProjectResponseDto> createProject(
    CreateProjectRequestDto request,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.projects,
      data: request.toJson(),
    );
    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => ProjectResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }
}
