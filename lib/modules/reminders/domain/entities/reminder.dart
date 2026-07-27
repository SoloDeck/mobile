import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_channel.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_status.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_target_type.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_type.dart';

part 'reminder.freezed.dart';

/// Một nhắc nhở (nhắc thu tiền, nhắc duyệt báo giá, nhắc ký hợp đồng, ...).
/// Pure domain entity — fields mirror the backend `ReminderResponse` contract
/// (`GET /reminders`, không phân trang).
@freezed
abstract class Reminder with _$Reminder {
  const factory Reminder({
    required String id,
    required String ownerUserId,
    required ReminderTargetType targetType,
    required String targetId,
    required ReminderType reminderType,
    required ReminderChannel channel,
    required ReminderStatus status,
    required DateTime scheduledAt,
    required DateTime createdAt,
    String? messagePreview,
    DateTime? updatedAt,
  }) = _Reminder;
}

extension ReminderX on Reminder {
  /// Còn chờ gửi và mốc hẹn đã trôi qua — dùng để hiện nhãn "Trễ N ngày" thay
  /// vì chỉ dựa vào [status] (backend cập nhật `status` bất đồng bộ qua worker
  /// nền, có độ trễ).
  bool isOverdueAt(DateTime now) =>
      status == ReminderStatus.pending && scheduledAt.isBefore(now);

  /// Có thể sửa lịch/nội dung/kênh — chỉ khi còn ở trạng thái chờ gửi.
  bool get canEdit => status == ReminderStatus.pending;

  /// Có thể huỷ — chỉ khi còn ở trạng thái chờ gửi.
  bool get canCancel => status == ReminderStatus.pending;
}
