import 'package:solodesk_mobile/modules/projects/domain/entities/project.dart';
import 'package:solodesk_mobile/modules/projects/domain/repositories/projects_repository.dart';

class GetProjectUseCase {
  const GetProjectUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<Project> call(String id) => _repository.getProject(id);

  /// Fetches the project linked to [dealId], creating one named [name] if none
  /// exists yet. Used by the deal detail "Dự án" tab so a deal always has a
  /// project to attach tasks to.
  Future<Project> forDeal({required String dealId, required String name}) async {
    final existing = await _repository.listProjects(dealId: dealId);
    if (existing.isNotEmpty) return existing.first;
    return _repository.createProject(name: name, dealId: dealId);
  }
}
