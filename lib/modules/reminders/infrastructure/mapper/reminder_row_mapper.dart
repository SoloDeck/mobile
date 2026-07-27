import 'package:drift/drift.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/reminders/domain/entities/reminder.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_channel.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_status.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_target_type.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_type.dart';

extension ReminderRowMapper on ReminderRow {
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

extension ReminderToRowMapper on Reminder {
  ReminderRowsCompanion toRow() => ReminderRowsCompanion(
    id: Value(id),
    ownerUserId: Value(ownerUserId),
    targetType: Value(targetType.wireValue),
    targetId: Value(targetId),
    reminderType: Value(reminderType.wireValue),
    channel: Value(channel.wireValue),
    status: Value(status.wireValue),
    scheduledAt: Value(scheduledAt.toIso8601String()),
    messagePreview: Value(messagePreview),
    createdAt: Value(createdAt.toIso8601String()),
    updatedAt: Value(updatedAt?.toIso8601String()),
  );
}
