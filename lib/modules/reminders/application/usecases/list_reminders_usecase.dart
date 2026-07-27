import 'package:solodesk_mobile/modules/reminders/domain/entities/reminder.dart';
import 'package:solodesk_mobile/modules/reminders/domain/repositories/reminders_repository.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_query.dart';

class ListRemindersUseCase {
  const ListRemindersUseCase(this._repository);

  final RemindersRepository _repository;

  Future<List<Reminder>> call({
    ReminderListFilter filter = const ReminderListFilter(),
  }) => _repository.listReminders(filter: filter);
}
