import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/tasks/domain/entities/checklist_item.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/priority.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_status.dart';

part 'task.freezed.dart';

/// A polymorphic task attached to a project, deal, or reminder. Pure domain
/// entity mirroring the backend `TaskResponse` contract.
@freezed
abstract class Task with _$Task {
  const factory Task({
    required String id,
    required TaskOwner entityType,
    required String entityId,
    required String title,
    required Priority priority,
    required TaskStatus status,
    required DateTime createdAt,
    @Default(<ChecklistItem>[]) List<ChecklistItem> checklistItems,
    String? description,
    DateTime? deadline,
    DateTime? updatedAt,
  }) = _Task;
}
