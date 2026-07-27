import 'package:solodesk_mobile/modules/reminders/domain/repositories/reminders_repository.dart';

class CancelReminderUseCase {
  const CancelReminderUseCase(this._repository);

  final RemindersRepository _repository;

  Future<void> call(String id) => _repository.cancelReminder(id);
}
