import 'package:solodesk_mobile/modules/tasks/domain/entities/task.dart';
import 'package:solodesk_mobile/modules/tasks/domain/repositories/tasks_repository.dart';

class GetTaskUseCase {
  const GetTaskUseCase(this._repository);

  final TasksRepository _repository;

  Future<Task> call(String id) => _repository.getTask(id);
}
