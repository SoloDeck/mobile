import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/tasks/application/usecases/create_task_usecase.dart';
import 'package:solodesk_mobile/modules/tasks/application/usecases/update_task_status_usecase.dart';
import 'package:solodesk_mobile/modules/tasks/domain/entities/task.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/priority.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_status.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/repository/tasks_repository_impl.dart';
import 'package:solodesk_mobile/modules/tasks/presentation/providers/tasks_provider.dart';

part 'tasks_controller.g.dart';

/// Drives task creation and status changes for one owner entity. Family keyed by
/// (entityType, entityId); refreshes the matching task list on success.
@riverpod
class TasksController extends _$TasksController {
  @override
  AsyncValue<Task?> build(TaskOwner entityType, String entityId) =>
      const AsyncValue.data(null);

  Future<Task?> createTask({
    required String title,
    String? description,
    Priority? priority,
    DateTime? deadline,
  }) async {
    state = const AsyncValue.loading();
    final useCase = CreateTaskUseCase(ref.read(tasksRepositoryProvider));
    state = await AsyncValue.guard(
      () => useCase(
        entityType: entityType,
        entityId: entityId,
        title: title,
        description: description,
        priority: priority,
        deadline: deadline,
      ),
    );
    _refreshOnSuccess();
    return state.value;
  }

  Future<Task?> updateStatus({
    required String taskId,
    required TaskStatus status,
  }) async {
    state = const AsyncValue.loading();
    final useCase = UpdateTaskStatusUseCase(ref.read(tasksRepositoryProvider));
    state = await AsyncValue.guard(
      () => useCase(taskId: taskId, status: status),
    );
    _refreshOnSuccess();
    return state.value;
  }

  void _refreshOnSuccess() {
    if (state.hasValue && state.value != null) {
      ref.invalidate(taskListProvider(entityType, entityId));
    }
  }
}
