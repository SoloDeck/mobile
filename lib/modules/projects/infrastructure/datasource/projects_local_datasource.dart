import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/projects/domain/entities/project.dart';
import 'package:solodesk_mobile/modules/projects/domain/value_objects/project_status.dart';
import 'package:solodesk_mobile/modules/projects/infrastructure/mapper/project_row_mapper.dart';

class ProjectsLocalDatasource {
  const ProjectsLocalDatasource(this._database);

  final AppDatabase _database;

  Future<void> upsertProjects(Iterable<Project> projects) =>
      _database.projectRowsDao.upsertAll(projects.map((p) => p.toRow()));

  Future<List<Project>> listProjects({
    String? dealId,
    ProjectStatus? status,
  }) async {
    final rows = await _database.projectRowsDao.getAll();
    return rows
        .map((row) => row.toDomain())
        .where((p) => dealId == null || p.dealId == dealId)
        .where((p) => status == null || p.status == status)
        .toList();
  }
}
