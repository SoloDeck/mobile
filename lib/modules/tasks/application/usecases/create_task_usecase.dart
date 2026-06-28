import 'package:solodesk_mobile/modules/tasks/domain/entities/task.dart';
import 'package:solodesk_mobile/modules/tasks/domain/repositories/tasks_repository.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/priority.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';

class CreateTaskUseCase {
  const CreateTaskUseCase(this._repository);

  final TasksRepository _repository;

  Future<Task> call({
    required TaskOwner entityType,
    required String entityId,
    required String title,
    String? description,
    Priority? priority,
    DateTime? deadline,
  }) => _repository.createTask(
    entityType: entityType,
    entityId: entityId,
    title: title,
    description: description,
    priority: priority,
    deadline: deadline,
  );
}
