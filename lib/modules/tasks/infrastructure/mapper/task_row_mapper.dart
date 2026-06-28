import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/tasks/domain/entities/checklist_item.dart';
import 'package:solodesk_mobile/modules/tasks/domain/entities/task.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/priority.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_status.dart';

ChecklistItem _checklistFromJson(Map<String, dynamic> json) => ChecklistItem(
  id: json['id'] as String,
  taskId: json['task_id'] as String,
  text: json['text'] as String,
  isDone: json['is_done'] as bool,
  position: json['position'] as int,
);

Map<String, dynamic> _checklistToJson(ChecklistItem item) => {
  'id': item.id,
  'task_id': item.taskId,
  'text': item.text,
  'is_done': item.isDone,
  'position': item.position,
};

extension TaskRowMapper on TaskRow {
  Task toDomain() {
    final raw = jsonDecode(checklistItems) as List<dynamic>;
    return Task(
      id: id,
      entityType: TaskOwnerX.fromWire(entityType),
      entityId: entityId,
      title: title,
      priority: PriorityX.fromWire(priority),
      status: TaskStatusX.fromWire(status),
      createdAt: DateTime.parse(createdAt),
      checklistItems: raw
          .map((e) => _checklistFromJson(e as Map<String, dynamic>))
          .toList(),
      description: description,
      deadline: deadline == null ? null : DateTime.parse(deadline!),
      updatedAt: updatedAt == null ? null : DateTime.parse(updatedAt!),
    );
  }
}

extension TaskToRowMapper on Task {
  TaskRowsCompanion toRow() => TaskRowsCompanion(
    id: Value(id),
    entityType: Value(entityType.wireValue),
    entityId: Value(entityId),
    title: Value(title),
    priority: Value(priority.wireValue),
    status: Value(status.wireValue),
    checklistItems: Value(
      jsonEncode(checklistItems.map(_checklistToJson).toList()),
    ),
    createdAt: Value(createdAt.toIso8601String()),
    description: Value(description),
    deadline: Value(deadline?.toIso8601String()),
    updatedAt: Value(updatedAt?.toIso8601String()),
  );
}
