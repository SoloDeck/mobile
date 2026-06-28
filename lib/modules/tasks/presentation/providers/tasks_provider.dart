import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/tasks/application/usecases/get_task_usecase.dart';
import 'package:solodesk_mobile/modules/tasks/application/usecases/list_tasks_usecase.dart';
import 'package:solodesk_mobile/modules/tasks/domain/entities/task.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/repository/tasks_repository_impl.dart';

part 'tasks_provider.g.dart';

/// Tasks for a given owner entity (project, deal, or reminder). Family keyed by
/// the polymorphic (entityType, entityId) pair so the same provider backs the
/// reusable [TaskListWidget] everywhere.
@riverpod
Future<List<Task>> taskList(Ref ref, TaskOwner entityType, String entityId) {
  final useCase = ListTasksUseCase(ref.watch(tasksRepositoryProvider));
  return useCase(entityType: entityType, entityId: entityId);
}

/// A single task by id, used by the task detail page.
@riverpod
Future<Task> taskDetail(Ref ref, String id) {
  final useCase = GetTaskUseCase(ref.watch(tasksRepositoryProvider));
  return useCase(id);
}
