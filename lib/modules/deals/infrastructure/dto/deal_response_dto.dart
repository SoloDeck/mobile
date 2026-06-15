import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';

part 'deal_response_dto.freezed.dart';
part 'deal_response_dto.g.dart';

/// Backend serializes Decimal money fields as JSON strings; parse defensively so
/// either a number or a string is accepted.
double? decimalFromJson(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

/// Wire shape of a deal as returned by `GET /deals` and `GET /deals/{id}`.
@freezed
abstract class DealResponseDto with _$DealResponseDto {
  const factory DealResponseDto({
    required String id,
    @JsonKey(name: 'owner_user_id') required String ownerUserId,
    @JsonKey(name: 'client_id') required String clientId,
    required String title,
    required DealStage stage,
    @JsonKey(name: 'client_name') String? clientName,
    @JsonKey(unknownEnumValue: DealSource.other) DealSource? source,
    @JsonKey(name: 'estimated_value', fromJson: decimalFromJson)
    double? estimatedValue,
    @JsonKey(name: 'actual_value', fromJson: decimalFromJson) double? actualValue,
    @Default('VND') String currency,
    String? notes,
    @JsonKey(name: 'closed_at') String? closedAt,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _DealResponseDto;

  factory DealResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DealResponseDtoFromJson(json);
}
