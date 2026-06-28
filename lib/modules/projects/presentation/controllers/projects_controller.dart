import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/projects/application/usecases/create_project_usecase.dart';
import 'package:solodesk_mobile/modules/projects/domain/entities/project.dart';
import 'package:solodesk_mobile/modules/projects/infrastructure/repository/projects_repository_impl.dart';
import 'package:solodesk_mobile/modules/projects/presentation/providers/projects_provider.dart';

part 'projects_controller.g.dart';

/// Drives project creation and refreshes the project list on success.
@riverpod
class ProjectsController extends _$ProjectsController {
  @override
  AsyncValue<Project?> build() => const AsyncValue.data(null);

  Future<Project?> create({
    required String name,
    String? dealId,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = const AsyncValue.loading();
    final useCase = CreateProjectUseCase(ref.read(projectsRepositoryProvider));
    state = await AsyncValue.guard(
      () => useCase(
        name: name,
        dealId: dealId,
        description: description,
        startDate: startDate,
        endDate: endDate,
      ),
    );
    if (state.hasValue && state.value != null) {
      ref.invalidate(projectListProvider);
    }
    return state.value;
  }
}
