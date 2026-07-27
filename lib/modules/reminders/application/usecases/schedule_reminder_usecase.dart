import 'package:solodesk_mobile/modules/reminders/domain/entities/reminder.dart';
import 'package:solodesk_mobile/modules/reminders/domain/repositories/reminders_repository.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_channel.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_target_type.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_type.dart';

/// Đặt một nhắc nhở mới. Backend không có endpoint "gửi ngay": bản ghi tạo ra
/// luôn ở trạng thái `pending`, việc gửi thật do worker nền xử lý sau, KHÔNG
/// đồng bộ với lệnh gọi này.
class ScheduleReminderUseCase {
  const ScheduleReminderUseCase(this._repository);

  final RemindersRepository _repository;

  Future<Reminder> call({
    required ReminderTargetType targetType,
    required String targetId,
    required ReminderType reminderType,
    required ReminderChannel channel,
    required DateTime scheduledAt,
    String? messagePreview,
  }) => _repository.createReminder(
    targetType: targetType,
    targetId: targetId,
    reminderType: reminderType,
    channel: channel,
    scheduledAt: scheduledAt,
    messagePreview: messagePreview,
  );
}
