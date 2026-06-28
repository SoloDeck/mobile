import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_status.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/dto/create_task_request_dto.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/dto/task_response_dto.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';
import 'package:solodesk_mobile/shared/models/api_response.dart';

class TasksRemoteDatasource {
  const TasksRemoteDatasource(this._client);

  final ApiClient _client;

  /// Resolves the polymorphic collection endpoint for an owner entity.
  String _collectionPath(TaskOwner entityType, String entityId) =>
      switch (entityType) {
        TaskOwner.project => ApiEndpoints.projectTasks(entityId),
        TaskOwner.deal => ApiEndpoints.dealTasks(entityId),
        TaskOwner.reminder => ApiEndpoints.reminderTasks(entityId),
      };

  Future<List<TaskResponseDto>> listByEntity({
    required TaskOwner entityType,
    required String entityId,
    TaskStatus? status,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      _collectionPath(entityType, entityId),
      queryParameters: {if (status != null) 'status': status.wireValue},
    );
    final items = response.data!['data'] as List<dynamic>;
    return items
        .map((e) => TaskResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TaskResponseDto> getTask(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.taskById(id),
    );
    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => TaskResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<TaskResponseDto> createTask({
    required TaskOwner entityType,
    required String entityId,
    required CreateTaskRequestDto request,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      _collectionPath(entityType, entityId),
      data: request.toJson(),
    );
    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => TaskResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<TaskResponseDto> updateStatus({
    required String taskId,
    required TaskStatus status,
  }) async {
    final response = await _client.put<Map<String, dynamic>>(
      ApiEndpoints.taskById(taskId),
      data: {'status': status.wireValue},
    );
    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => TaskResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }
}
