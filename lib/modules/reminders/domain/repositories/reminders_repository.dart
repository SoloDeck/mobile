import 'package:solodesk_mobile/modules/reminders/domain/entities/reminder.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_channel.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_query.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_target_type.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_type.dart';

/// Hợp đồng dữ liệu của module nhắc hẹn. Implemented in
/// `infrastructure/repository/reminders_repository_impl.dart`.
///
/// `GET /reminders` KHÔNG phân trang — khác hẳn invoices/proposals — nên
/// [listReminders] trả thẳng `List<Reminder>`, không có `page`/`pageSize`.
/// Backend không có endpoint "gửi ngay": [createReminder] luôn tạo với
/// `status='pending'` phía server, việc gửi thật do worker nền xử lý sau,
/// KHÔNG đồng bộ với lệnh gọi này.
abstract interface class RemindersRepository {
  Future<List<Reminder>> listReminders({
    ReminderListFilter filter = const ReminderListFilter(),
  });

  Future<Reminder?> getReminder(String id);

  Future<Reminder> createReminder({
    required ReminderTargetType targetType,
    required String targetId,
    required ReminderType reminderType,
    required ReminderChannel channel,
    required DateTime scheduledAt,
    String? messagePreview,
  });

  Future<Reminder> updateReminder({
    required String id,
    DateTime? scheduledAt,
    String? messagePreview,
    ReminderChannel? channel,
  });

  /// = DELETE, huỷ mềm ở backend (`status='cancelled'`), KHÔNG xoá cứng.
  Future<void> cancelReminder(String id);
}
