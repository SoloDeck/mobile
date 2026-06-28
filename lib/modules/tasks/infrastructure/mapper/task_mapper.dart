import 'package:solodesk_mobile/modules/tasks/domain/entities/checklist_item.dart';
import 'package:solodesk_mobile/modules/tasks/domain/entities/task.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/dto/checklist_item_response_dto.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/dto/task_response_dto.dart';

extension ChecklistItemResponseDtoMapper on ChecklistItemResponseDto {
  ChecklistItem toDomain() => ChecklistItem(
    id: id,
    taskId: taskId,
    text: text,
    isDone: isDone,
    position: position,
  );
}

extension TaskResponseDtoMapper on TaskResponseDto {
  Task toDomain() => Task(
    id: id,
    entityType: entityType,
    entityId: entityId,
    title: title,
    priority: priority,
    status: status,
    createdAt: DateTime.parse(createdAt),
    checklistItems: checklistItems.map((c) => c.toDomain()).toList(),
    description: description,
    deadline: deadline == null ? null : DateTime.parse(deadline!),
    updatedAt: updatedAt == null ? null : DateTime.parse(updatedAt!),
  );
}
