import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/reminders/domain/entities/reminder.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_query.dart';
import 'package:solodesk_mobile/modules/reminders/infrastructure/mapper/reminder_row_mapper.dart';

class RemindersLocalDatasource {
  const RemindersLocalDatasource(this._database);

  final AppDatabase _database;

  /// Thay TOÀN BỘ cache — vì `GET /reminders` trả toàn bộ tập dữ liệu mỗi
  /// lần, không phải trang. Nếu chỉ upsert, nhắc hẹn đã bị huỷ ở server sẽ
  /// nằm lại mãi trong cache.
  Future<void> replaceAll(List<Reminder> reminders) =>
      _database.reminderRowsDao.replaceAll(reminders.map((r) => r.toRow()));

  Future<List<Reminder>> listReminders({
    ReminderListFilter filter = const ReminderListFilter(),
  }) async {
    final rows = await _database.reminderRowsDao.getAll();
    return rows.map((r) => r.toDomain()).where(filter.matches).toList();
  }
}
