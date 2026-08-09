import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/value_objects/deal_activity_type.dart';

part 'deal_activity_response_dto.freezed.dart';
part 'deal_activity_response_dto.g.dart';

/// Wire shape of `GET /deals/{id}/activity` items — matches
/// `DealActivityEntryResponse` in `contracts/openapi.yaml` (id, deal_id,
/// entry_type, description, previous_stage, new_stage, created_at). No
/// `owner_user_id` — backend never exposes it on this response.
@freezed
abstract class DealActivityResponseDto with _$DealActivityResponseDto {
  const factory DealActivityResponseDto({
    required String id,
    @JsonKey(name: 'deal_id') required String dealId,
    @JsonKey(name: 'entry_type') required DealActivityType entryType,
    required String description,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'previous_stage') DealStage? previousStage,
    @JsonKey(name: 'new_stage') DealStage? newStage,
  }) = _DealActivityResponseDto;

  factory DealActivityResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DealActivityResponseDtoFromJson(json);
}
