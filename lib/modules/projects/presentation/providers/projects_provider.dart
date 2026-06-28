import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/projects/application/usecases/get_project_usecase.dart';
import 'package:solodesk_mobile/modules/projects/application/usecases/list_projects_usecase.dart';
import 'package:solodesk_mobile/modules/projects/domain/entities/project.dart';
import 'package:solodesk_mobile/modules/projects/infrastructure/repository/projects_repository_impl.dart';

part 'projects_provider.g.dart';

/// All projects owned by the authenticated user.
@riverpod
Future<List<Project>> projectList(Ref ref) {
  final useCase = ListProjectsUseCase(ref.watch(projectsRepositoryProvider));
  return useCase();
}

/// A single project by id, used by the detail page.
@riverpod
Future<Project> projectDetail(Ref ref, String id) {
  final useCase = GetProjectUseCase(ref.watch(projectsRepositoryProvider));
  return useCase(id);
}

/// The project linked to a deal — fetched, or created on first access. Backs the
/// "Dự án" tab on the deal detail page.
@riverpod
Future<Project> dealProject(Ref ref, String dealId, String name) {
  final useCase = GetProjectUseCase(ref.watch(projectsRepositoryProvider));
  return useCase.forDeal(dealId: dealId, name: name);
}
