import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';

part 'stage_transition_request_dto.freezed.dart';
part 'stage_transition_request_dto.g.dart';

/// Request body for `POST /deals/{id}/stage`. `target_stage` is the canonical
/// field name the backend expects.
@freezed
abstract class StageTransitionRequestDto with _$StageTransitionRequestDto {
  const factory StageTransitionRequestDto({
    @JsonKey(name: 'target_stage') required DealStage targetStage,
    @JsonKey(includeIfNull: false) String? note,
  }) = _StageTransitionRequestDto;

  factory StageTransitionRequestDto.fromJson(Map<String, dynamic> json) =>
      _$StageTransitionRequestDtoFromJson(json);
}
