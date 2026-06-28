import 'package:solodesk_mobile/modules/tasks/domain/entities/task.dart';
import 'package:solodesk_mobile/modules/tasks/domain/repositories/tasks_repository.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_status.dart';

class ListTasksUseCase {
  const ListTasksUseCase(this._repository);

  final TasksRepository _repository;

  Future<List<Task>> call({
    required TaskOwner entityType,
    required String entityId,
    TaskStatus? status,
  }) => _repository.listByEntity(
    entityType: entityType,
    entityId: entityId,
    status: status,
  );
}
