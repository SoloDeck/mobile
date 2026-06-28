import 'package:solodesk_mobile/modules/tasks/domain/entities/task.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/priority.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_status.dart';

/// Contract for the polymorphic task store. Implemented in
/// `infrastructure/repository/tasks_repository_impl.dart`.
abstract interface class TasksRepository {
  /// Lists tasks for a given owner entity (project, deal, or reminder).
  Future<List<Task>> listByEntity({
    required TaskOwner entityType,
    required String entityId,
    TaskStatus? status,
  });

  Future<Task> getTask(String id);

  Future<Task> createTask({
    required TaskOwner entityType,
    required String entityId,
    required String title,
    String? description,
    Priority? priority,
    DateTime? deadline,
  });

  Future<Task> updateStatus({required String taskId, required TaskStatus status});
}
