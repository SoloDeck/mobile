import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder_response_dto.freezed.dart';
part 'reminder_response_dto.g.dart';

/// Wire shape của một nhắc nhở, trả về từ `GET /reminders` (không phân
/// trang, trả toàn bộ tập dữ liệu) và các endpoint đơn lẻ. Các trường enum
/// (`target_type`, `reminder_type`, `channel`, `status`) giữ nguyên dạng
/// String — chuyển đổi sang value object domain diễn ra ở mapper, KHÔNG phải
/// ở đây. Ngày/giờ cũng giữ dạng String, `DateTime.parse` ở mapper.
@freezed
abstract class ReminderResponseDto with _$ReminderResponseDto {
  const factory ReminderResponseDto({
    required String id,
    @JsonKey(name: 'owner_user_id') required String ownerUserId,
    @JsonKey(name: 'target_type') required String targetType,
    @JsonKey(name: 'target_id') required String targetId,
    @JsonKey(name: 'reminder_type') required String reminderType,
    required String channel,
    required String status,
    @JsonKey(name: 'scheduled_at') required String scheduledAt,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'message_preview') String? messagePreview,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ReminderResponseDto;

  factory ReminderResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ReminderResponseDtoFromJson(json);
}
