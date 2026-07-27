import 'package:solodesk_mobile/modules/reminders/domain/entities/reminder.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_channel.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_status.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_target_type.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_type.dart';
import 'package:solodesk_mobile/modules/reminders/infrastructure/dto/reminder_response_dto.dart';

extension ReminderResponseDtoMapper on ReminderResponseDto {
  Reminder toDomain() => Reminder(
    id: id,
    ownerUserId: ownerUserId,
    targetType: reminderTargetTypeFromWire(targetType),
    targetId: targetId,
    reminderType: reminderTypeFromWire(reminderType),
    channel: reminderChannelFromWire(channel),
    status: reminderStatusFromWire(status),
    scheduledAt: DateTime.parse(scheduledAt),
    createdAt: DateTime.parse(createdAt),
    messagePreview: messagePreview,
    updatedAt: updatedAt == null ? null : DateTime.parse(updatedAt!),
  );
}
