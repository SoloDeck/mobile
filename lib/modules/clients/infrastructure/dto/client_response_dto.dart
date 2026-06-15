import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';

part 'client_response_dto.freezed.dart';
part 'client_response_dto.g.dart';

/// Wire shape of a client as returned by `GET /clients` and `GET /clients/{id}`.
@freezed
abstract class ClientResponseDto with _$ClientResponseDto {
  const factory ClientResponseDto({
    required String id,
    @JsonKey(name: 'owner_user_id') required String ownerUserId,
    required String name,
    required ClientType type,
    required ClientStatus status,
    @JsonKey(name: 'deal_count') @Default(0) int dealCount,
    @JsonKey(name: 'created_at') required String createdAt,
    String? email,
    String? phone,
    String? notes,
    String? description,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ClientResponseDto;

  factory ClientResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ClientResponseDtoFromJson(json);
}
