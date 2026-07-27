import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/providers/invoices_provider.dart';
import 'package:solodesk_mobile/modules/reminders/application/usecases/compose_reminder_message_usecase.dart';
import 'package:solodesk_mobile/modules/reminders/application/usecases/list_reminders_usecase.dart';
import 'package:solodesk_mobile/modules/reminders/domain/entities/reminder.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_query.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_tone.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_type.dart';
import 'package:solodesk_mobile/modules/reminders/infrastructure/repository/reminders_repository_impl.dart';

part 'reminders_provider.g.dart';

/// Toàn bộ nhắc nhở, có lọc — `GET /reminders` không phân trang nên trả thẳng
/// `List<Reminder>` (xem doc [ReminderListFilter]).
@riverpod
Future<List<Reminder>> reminders(Ref ref, ReminderListFilter filter) =>
    ListRemindersUseCase(ref.watch(remindersRepositoryProvider))(
      filter: filter,
    );

/// Dữ liệu cho MÀN 12: hoá đơn cần nhắc + loại nhắc gợi ý + bản nháp soạn sẵn
/// bằng giọng "Lịch sự" (mặc định).
class ReminderComposeData {
  const ReminderComposeData({
    required this.invoice,
    required this.suggestedType,
    required this.suggestedBody,
  });

  final Invoice invoice;
  final ReminderType suggestedType;
  final String suggestedBody;
}

/// Gộp hoá đơn cần nhắc với một bản nháp soạn sẵn — [ComposeReminderMessageUseCase]
/// là hàm thuần (không gọi API) nên chạy ngay tại đây, không cần usecase riêng
/// ở tầng controller cho lần soạn đầu tiên.
@riverpod
Future<ReminderComposeData> reminderComposeData(
  Ref ref,
  String invoiceId,
) async {
  final invoice = await ref.watch(invoiceDetailProvider(invoiceId).future);
  // Loại nhắc gợi ý theo tình trạng hoá đơn thật — không giả định luôn quá
  // hạn như bản mock cũ.
  final suggestedType = invoice.isOverdue
      ? ReminderType.paymentOverdue
      : ReminderType.paymentDue;
  final suggestedBody = const ComposeReminderMessageUseCase()(
    tone: ReminderTone.polite,
    clientName: invoice.clientName ?? 'quý khách',
    amount: invoice.amountOutstanding,
    dueDate: invoice.dueDate,
    attachPaymentLink: true,
  );
  return ReminderComposeData(
    invoice: invoice,
    suggestedType: suggestedType,
    suggestedBody: suggestedBody,
  );
}
