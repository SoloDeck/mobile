import 'package:solodesk_mobile/modules/projects/domain/entities/project.dart';
import 'package:solodesk_mobile/modules/projects/domain/repositories/projects_repository.dart';

class CreateProjectUseCase {
  const CreateProjectUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<Project> call({
    required String name,
    String? dealId,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
  }) => _repository.createProject(
    name: name,
    dealId: dealId,
    description: description,
    startDate: startDate,
    endDate: endDate,
  );
}
