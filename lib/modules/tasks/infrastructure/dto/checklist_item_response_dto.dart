import 'package:freezed_annotation/freezed_annotation.dart';

part 'checklist_item_response_dto.freezed.dart';
part 'checklist_item_response_dto.g.dart';

/// Wire shape of a checklist item, nested inside `TaskResponse.checklist_items`.
@freezed
abstract class ChecklistItemResponseDto with _$ChecklistItemResponseDto {
  const factory ChecklistItemResponseDto({
    required String id,
    @JsonKey(name: 'task_id') required String taskId,
    required String text,
    @JsonKey(name: 'is_done') required bool isDone,
    required int position,
  }) = _ChecklistItemResponseDto;

  factory ChecklistItemResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ChecklistItemResponseDtoFromJson(json);
}
