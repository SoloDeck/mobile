import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder_request_dto.freezed.dart';
part 'reminder_request_dto.g.dart';

/// Request body dùng CHUNG cho `POST /reminders` và `PATCH /reminders/{id}`
/// — đúng theo hợp đồng backend: PATCH vẫn đòi đủ field dù chỉ áp dụng thay
/// đổi cho `scheduled_at`/`message_preview`/`channel`
/// ([RemindersRepositoryImpl.updateReminder] đọc bản ghi hiện tại để lấp lại
/// `target_type`/`target_id`/`reminder_type` trước khi gọi PATCH).
@freezed
abstract class ReminderRequestDto with _$ReminderRequestDto {
  const factory ReminderRequestDto({
    @JsonKey(name: 'target_type') required String targetType,
    @JsonKey(name: 'target_id') required String targetId,
    @JsonKey(name: 'reminder_type') required String reminderType,
    required String channel,
    @JsonKey(name: 'scheduled_at') required String scheduledAt,
    @JsonKey(name: 'message_preview') String? messagePreview,
  }) = _ReminderRequestDto;

  factory ReminderRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ReminderRequestDtoFromJson(json);
}
