import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/projects/domain/entities/project.dart';
import 'package:solodesk_mobile/modules/projects/domain/repositories/projects_repository.dart';
import 'package:solodesk_mobile/modules/projects/domain/value_objects/project_status.dart';
import 'package:solodesk_mobile/modules/projects/infrastructure/datasource/projects_local_datasource.dart';
import 'package:solodesk_mobile/modules/projects/infrastructure/datasource/projects_remote_datasource.dart';
import 'package:solodesk_mobile/modules/projects/infrastructure/dto/create_project_request_dto.dart';
import 'package:solodesk_mobile/modules/projects/infrastructure/mapper/project_mapper.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

part 'projects_repository_impl.g.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  const ProjectsRepositoryImpl(this._remote, this._local);

  final ProjectsRemoteDatasource _remote;
  final ProjectsLocalDatasource _local;

  @override
  Future<List<Project>> listProjects({
    String? dealId,
    ProjectStatus? status,
  }) async {
    try {
      final dtos = await _remote.listProjects(dealId: dealId, status: status);
      final projects = dtos.map((dto) => dto.toDomain()).toList();
      await _local.upsertProjects(projects);
      return projects;
    } on NetworkException {
      return _local.listProjects(dealId: dealId, status: status);
    }
  }

  @override
  Future<Project> getProject(String id) async {
    final dto = await _remote.getProject(id);
    final project = dto.toDomain();
    await _local.upsertProjects([project]);
    return project;
  }

  @override
  Future<Project> createProject({
    required String name,
    String? dealId,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String? dateOnly(DateTime? value) =>
        value?.toIso8601String().split('T').first;

    final dto = await _remote.createProject(
      CreateProjectRequestDto(
        name: name,
        dealId: dealId,
        description: description,
        startDate: dateOnly(startDate),
        endDate: dateOnly(endDate),
      ),
    );
    final project = dto.toDomain();
    await _local.upsertProjects([project]);
    return project;
  }
}

@Riverpod(keepAlive: true)
ProjectsRepository projectsRepository(Ref ref) {
  final client = ref.read(apiClientProvider);
  final database = ref.read(appDatabaseProvider);
  return ProjectsRepositoryImpl(
    ProjectsRemoteDatasource(client),
    ProjectsLocalDatasource(database),
  );
}
