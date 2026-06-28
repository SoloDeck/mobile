import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/tasks/domain/entities/task.dart';
import 'package:solodesk_mobile/modules/tasks/domain/repositories/tasks_repository.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/priority.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_status.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/datasource/tasks_local_datasource.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/datasource/tasks_remote_datasource.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/dto/create_task_request_dto.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/mapper/task_mapper.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

part 'tasks_repository_impl.g.dart';

class TasksRepositoryImpl implements TasksRepository {
  const TasksRepositoryImpl(this._remote, this._local);

  final TasksRemoteDatasource _remote;
  final TasksLocalDatasource _local;

  @override
  Future<List<Task>> listByEntity({
    required TaskOwner entityType,
    required String entityId,
    TaskStatus? status,
  }) async {
    try {
      final dtos = await _remote.listByEntity(
        entityType: entityType,
        entityId: entityId,
        status: status,
      );
      final tasks = dtos.map((dto) => dto.toDomain()).toList();
      await _local.upsertTasks(tasks);
      return tasks;
    } on NetworkException {
      return _local.listByEntity(
        entityType: entityType,
        entityId: entityId,
        status: status,
      );
    }
  }

  @override
  Future<Task> getTask(String id) async {
    final dto = await _remote.getTask(id);
    final task = dto.toDomain();
    await _local.upsertTasks([task]);
    return task;
  }

  @override
  Future<Task> createTask({
    required TaskOwner entityType,
    required String entityId,
    required String title,
    String? description,
    Priority? priority,
    DateTime? deadline,
  }) async {
    final dto = await _remote.createTask(
      entityType: entityType,
      entityId: entityId,
      request: CreateTaskRequestDto(
        title: title,
        description: description,
        priority: priority,
        deadline: deadline?.toIso8601String(),
      ),
    );
    final task = dto.toDomain();
    await _local.upsertTasks([task]);
    return task;
  }

  @override
  Future<Task> updateStatus({
    required String taskId,
    required TaskStatus status,
  }) async {
    final dto = await _remote.updateStatus(taskId: taskId, status: status);
    final task = dto.toDomain();
    await _local.upsertTasks([task]);
    return task;
  }
}

@Riverpod(keepAlive: true)
TasksRepository tasksRepository(Ref ref) {
  final client = ref.read(apiClientProvider);
  final database = ref.read(appDatabaseProvider);
  return TasksRepositoryImpl(
    TasksRemoteDatasource(client),
    TasksLocalDatasource(database),
  );
}
