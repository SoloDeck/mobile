import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/dto/checklist_item_response_dto.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/priority.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_status.dart';

part 'task_response_dto.freezed.dart';
part 'task_response_dto.g.dart';

/// Wire shape of a task as returned by the task endpoints. `entity_type` selects
/// the polymorphic owner.
@freezed
abstract class TaskResponseDto with _$TaskResponseDto {
  const factory TaskResponseDto({
    required String id,
    @JsonKey(name: 'entity_type', unknownEnumValue: TaskOwner.project)
    required TaskOwner entityType,
    @JsonKey(name: 'entity_id') required String entityId,
    required String title,
    @JsonKey(unknownEnumValue: Priority.medium) required Priority priority,
    @JsonKey(unknownEnumValue: TaskStatus.todo) required TaskStatus status,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'checklist_items')
    @Default(<ChecklistItemResponseDto>[])
    List<ChecklistItemResponseDto> checklistItems,
    String? description,
    String? deadline,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _TaskResponseDto;

  factory TaskResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TaskResponseDtoFromJson(json);
}
