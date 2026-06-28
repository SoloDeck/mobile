import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/tasks/domain/entities/task.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_status.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/mapper/task_row_mapper.dart';

class TasksLocalDatasource {
  const TasksLocalDatasource(this._database);

  final AppDatabase _database;

  Future<void> upsertTasks(Iterable<Task> tasks) =>
      _database.taskRowsDao.upsertAll(tasks.map((t) => t.toRow()));

  Future<List<Task>> listByEntity({
    required TaskOwner entityType,
    required String entityId,
    TaskStatus? status,
  }) async {
    final rows = await _database.taskRowsDao.getAll();
    return rows
        .map((row) => row.toDomain())
        .where((t) => t.entityType == entityType && t.entityId == entityId)
        .where((t) => status == null || t.status == status)
        .toList();
  }
}
