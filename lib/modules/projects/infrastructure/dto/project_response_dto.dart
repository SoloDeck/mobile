import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/projects/domain/value_objects/project_status.dart';

part 'project_response_dto.freezed.dart';
part 'project_response_dto.g.dart';

/// Wire shape of a project as returned by `GET /projects` and
/// `GET /projects/{id}`.
@freezed
abstract class ProjectResponseDto with _$ProjectResponseDto {
  const factory ProjectResponseDto({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    required String name,
    @JsonKey(unknownEnumValue: ProjectStatus.planning)
    required ProjectStatus status,
    @JsonKey(name: 'task_count') @Default(0) int taskCount,
    @JsonKey(name: 'done_count') @Default(0) int doneCount,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'deal_id') String? dealId,
    String? description,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ProjectResponseDto;

  factory ProjectResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectResponseDtoFromJson(json);
}
