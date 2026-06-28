import 'package:solodesk_mobile/modules/tasks/domain/entities/task.dart';
import 'package:solodesk_mobile/modules/tasks/domain/repositories/tasks_repository.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_status.dart';

class UpdateTaskStatusUseCase {
  const UpdateTaskStatusUseCase(this._repository);

  final TasksRepository _repository;

  Future<Task> call({required String taskId, required TaskStatus status}) =>
      _repository.updateStatus(taskId: taskId, status: status);
}
