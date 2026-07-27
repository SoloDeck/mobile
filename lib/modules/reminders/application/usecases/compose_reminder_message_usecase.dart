import 'package:solodesk_mobile/modules/reminders/domain/services/reminder_message_composer.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_tone.dart';

/// Soạn sẵn nội dung nhắc để người dùng XEM VÀ SỬA trước khi gửi — hàm THUẦN,
/// không gọi API, không cần repository.
class ComposeReminderMessageUseCase {
  const ComposeReminderMessageUseCase();

  String call({
    required ReminderTone tone,
    required String clientName,
    required double amount,
    required DateTime dueDate,
    required bool attachPaymentLink,
  }) => ReminderMessageComposer.compose(
    tone: tone,
    clientName: clientName,
    amount: amount,
    dueDate: dueDate,
    attachPaymentLink: attachPaymentLink,
  );
}
