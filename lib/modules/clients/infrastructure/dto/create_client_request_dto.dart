import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';

part 'create_client_request_dto.freezed.dart';
part 'create_client_request_dto.g.dart';

/// Request body for `POST /clients`. Null fields are omitted so the backend
/// applies its own defaults (e.g. `type=individual`, `status=prospect`).
@freezed
abstract class CreateClientRequestDto with _$CreateClientRequestDto {
  const factory CreateClientRequestDto({
    required String name,
    @JsonKey(includeIfNull: false) ClientType? type,
    @JsonKey(includeIfNull: false) String? email,
    @JsonKey(includeIfNull: false) String? phone,
    @JsonKey(includeIfNull: false) String? notes,
  }) = _CreateClientRequestDto;

  factory CreateClientRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateClientRequestDtoFromJson(json);
}
