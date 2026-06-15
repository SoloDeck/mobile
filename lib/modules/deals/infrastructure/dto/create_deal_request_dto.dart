import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';

part 'create_deal_request_dto.freezed.dart';
part 'create_deal_request_dto.g.dart';

/// Request body for `POST /deals`. The deal always starts in `new_lead`, so no
/// stage is sent. Null fields are omitted.
@freezed
abstract class CreateDealRequestDto with _$CreateDealRequestDto {
  const factory CreateDealRequestDto({
    @JsonKey(name: 'client_id') required String clientId,
    required String title,
    @JsonKey(includeIfNull: false) DealSource? source,
    @JsonKey(name: 'estimated_value', includeIfNull: false)
    double? estimatedValue,
    @JsonKey(includeIfNull: false) String? currency,
    @JsonKey(includeIfNull: false) String? notes,
  }) = _CreateDealRequestDto;

  factory CreateDealRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateDealRequestDtoFromJson(json);
}
