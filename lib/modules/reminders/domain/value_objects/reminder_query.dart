import 'package:solodesk_mobile/modules/reminders/domain/entities/reminder.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_status.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_target_type.dart';

/// Bộ lọc danh sách nhắc nhở. Không có `ReminderListPage` — khác
/// invoices/proposals, `GET /reminders` KHÔNG phân trang, KHÔNG sort, KHÔNG
/// limit, luôn trả về toàn bộ tập dữ liệu — repository trả thẳng
/// `List<Reminder>`, lọc chạy tại chỗ trên cache offline giống cách backend
/// sẽ lọc nếu nó có hỗ trợ.
class ReminderListFilter {
  const ReminderListFilter({this.status, this.targetType});

  final ReminderStatus? status;
  final ReminderTargetType? targetType;

  bool matches(Reminder r) =>
      (status == null || r.status == status) &&
      (targetType == null || r.targetType == targetType);

  @override
  bool operator ==(Object other) =>
      other is ReminderListFilter &&
      other.status == status &&
      other.targetType == targetType;

  @override
  int get hashCode => Object.hash(status, targetType);
}
