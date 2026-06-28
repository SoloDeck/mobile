import 'package:solodesk_mobile/modules/projects/domain/entities/project.dart';
import 'package:solodesk_mobile/modules/projects/domain/value_objects/project_status.dart';

/// Contract for reading and creating projects. Implemented in
/// `infrastructure/repository/projects_repository_impl.dart`.
abstract interface class ProjectsRepository {
  Future<List<Project>> listProjects({String? dealId, ProjectStatus? status});

  Future<Project> getProject(String id);

  Future<Project> createProject({
    required String name,
    String? dealId,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
  });
}
