import 'package:drift/drift.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/projects/domain/entities/project.dart';
import 'package:solodesk_mobile/modules/projects/domain/value_objects/project_status.dart';

extension ProjectRowMapper on ProjectRow {
  Project toDomain() => Project(
    id: id,
    ownerId: ownerId,
    name: name,
    status: ProjectStatusX.fromWire(status),
    taskCount: taskCount,
    doneCount: doneCount,
    createdAt: DateTime.parse(createdAt),
    dealId: dealId,
    description: description,
    startDate: startDate == null ? null : DateTime.parse(startDate!),
    endDate: endDate == null ? null : DateTime.parse(endDate!),
    updatedAt: updatedAt == null ? null : DateTime.parse(updatedAt!),
  );
}

extension ProjectToRowMapper on Project {
  ProjectRowsCompanion toRow() => ProjectRowsCompanion(
    id: Value(id),
    ownerId: Value(ownerId),
    name: Value(name),
    status: Value(status.wireValue),
    taskCount: Value(taskCount),
    doneCount: Value(doneCount),
    createdAt: Value(createdAt.toIso8601String()),
    dealId: Value(dealId),
    description: Value(description),
    startDate: Value(startDate?.toIso8601String()),
    endDate: Value(endDate?.toIso8601String()),
    updatedAt: Value(updatedAt?.toIso8601String()),
  );
}
