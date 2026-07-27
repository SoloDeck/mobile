import 'package:solodesk_mobile/modules/reminders/domain/entities/reminder.dart';
import 'package:solodesk_mobile/modules/reminders/domain/repositories/reminders_repository.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_channel.dart';

/// Sửa lịch/nội dung/kênh của một nhắc nhở đang chờ gửi. Chỉ khả dụng khi
/// [ReminderX.canEdit] cho phép (trang chi tiết ẩn thao tác này khi đã gửi
/// hoặc bị huỷ); backend cũng tự kiểm và trả lỗi tương ứng nếu vi phạm.
class UpdateReminderUseCase {
  const UpdateReminderUseCase(this._repository);

  final RemindersRepository _repository;

  Future<Reminder> call({
    required String id,
    DateTime? scheduledAt,
    String? messagePreview,
    ReminderChannel? channel,
  }) => _repository.updateReminder(
    id: id,
    scheduledAt: scheduledAt,
    messagePreview: messagePreview,
    channel: channel,
  );
}
