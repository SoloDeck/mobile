import 'package:solodesk_mobile/modules/projects/domain/entities/project.dart';
import 'package:solodesk_mobile/modules/projects/domain/repositories/projects_repository.dart';
import 'package:solodesk_mobile/modules/projects/domain/value_objects/project_status.dart';

class ListProjectsUseCase {
  const ListProjectsUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<List<Project>> call({String? dealId, ProjectStatus? status}) =>
      _repository.listProjects(dealId: dealId, status: status);
}
