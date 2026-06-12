import 'package:freezed_annotation/freezed_annotation.dart';

part 'preferences_dto.freezed.dart';
part 'preferences_dto.g.dart';

@freezed
abstract class PreferencesDto with _$PreferencesDto {
  const factory PreferencesDto({
    String? locale,
    String? timezone,
    @JsonKey(name: 'notification_channel') String? notificationChannel,
    String? theme,
  }) = _PreferencesDto;

  factory PreferencesDto.fromJson(Map<String, dynamic> json) =>
      _$PreferencesDtoFromJson(json);
}
