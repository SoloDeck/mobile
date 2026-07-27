import 'package:solodesk_mobile/modules/reminders/domain/entities/reminder.dart';
import 'package:solodesk_mobile/modules/reminders/domain/repositories/reminders_repository.dart';

class GetReminderUseCase {
  const GetReminderUseCase(this._repository);

  final RemindersRepository _repository;

  Future<Reminder?> call(String id) => _repository.getReminder(id);
}
