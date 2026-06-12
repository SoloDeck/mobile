import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_request_dto.freezed.dart';
part 'refresh_request_dto.g.dart';

@freezed
abstract class RefreshRequestDto with _$RefreshRequestDto {
  const factory RefreshRequestDto({
    @JsonKey(name: 'refresh_token') required String refreshToken,
  }) = _RefreshRequestDto;

  factory RefreshRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RefreshRequestDtoFromJson(json);
}
