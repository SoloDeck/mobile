import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/priority.dart';

part 'create_task_request_dto.freezed.dart';
part 'create_task_request_dto.g.dart';

/// Request body for `POST /{entity}/{id}/tasks`. The owner is implied by the
/// endpoint, so only task content is sent. Null fields are omitted.
@freezed
abstract class CreateTaskRequestDto with _$CreateTaskRequestDto {
  const factory CreateTaskRequestDto({
    required String title,
    @JsonKey(includeIfNull: false) String? description,
    @JsonKey(includeIfNull: false) Priority? priority,
    @JsonKey(includeIfNull: false) String? deadline,
  }) = _CreateTaskRequestDto;

  factory CreateTaskRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskRequestDtoFromJson(json);
}
