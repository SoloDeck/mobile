import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/time/app_clock.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/reminders/application/usecases/compose_reminder_message_usecase.dart';
import 'package:solodesk_mobile/modules/reminders/application/usecases/schedule_reminder_usecase.dart';
import 'package:solodesk_mobile/modules/reminders/domain/entities/reminder_draft.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_channel.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_target_type.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_tone.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_type.dart';
import 'package:solodesk_mobile/modules/reminders/infrastructure/repository/reminders_repository_impl.dart';
import 'package:solodesk_mobile/modules/reminders/presentation/providers/reminders_provider.dart';

part 'reminder_compose_controller.g.dart';

/// Điều khiển bản nháp của MÀN 12, theo từng hoá đơn ([invoiceId] là tham số
/// family — mỗi hoá đơn có một bản nháp riêng).
///
/// [build] khởi tạo [ReminderDraft.body] ngay bằng bản soạn sẵn của
/// [reminderComposeDataProvider] thay vì để rỗng: hàm này chỉ `ref.watch` một
/// `AsyncValue` đã có sẵn (trang chỉ dựng widget này sau khi
/// `AsyncValueWidget` của `reminderComposeDataProvider(invoiceId)` đã ở trạng
/// thái `data`), nên đây vẫn là một hàm ĐỒNG BỘ, không có `await` nào — nếu để
/// `body` rỗng thì bấm "Gửi ngay" ngay từ đầu (chưa đổi giọng văn, chưa bật/tắt
/// công tắc nào) sẽ gửi đi một `messagePreview` rỗng.
@riverpod
class ReminderComposeController extends _$ReminderComposeController {
  @override
  ReminderDraft build(String invoiceId) {
    final data = ref.watch(reminderComposeDataProvider(invoiceId)).value;
    return ReminderDraft(body: data?.suggestedBody ?? '');
  }

  void setTone(ReminderTone tone) {
    // Luôn soạn lại nội dung theo giọng mới — chấp nhận ghi đè phần người
    // dùng có thể đã sửa tay trước đó, vì đổi giọng văn thì người dùng cũng
    // mong nội dung đổi theo.
    state = state.copyWith(
      tone: tone,
      body: _recompose(tone: tone, attachPaymentLink: state.attachPaymentLink),
    );
  }

  void setChannel(ReminderChannel channel) {
    state = state.copyWith(channel: channel);
  }

  void toggleMomoLink() {
    final attach = !state.attachPaymentLink;
    state = state.copyWith(
      attachPaymentLink: attach,
      body: _recompose(tone: state.tone, attachPaymentLink: attach),
    );
  }

  void toggleRepeat({int days = 3}) {
    state = state.copyWith(
      repeatAfterDays: state.repeatAfterDays == null ? days : null,
    );
  }

  void editBody(String body) {
    state = state.copyWith(body: body);
  }

  /// Soạn lại nội dung nhắc từ hoá đơn đang mở. Trả nguyên [state.body] nếu
  /// [reminderComposeDataProvider] chưa có dữ liệu (không thể xảy ra trong
  /// luồng bình thường — trang chỉ cho tương tác sau khi đã tải xong hoá đơn).
  String _recompose({
    required ReminderTone tone,
    required bool attachPaymentLink,
  }) {
    final invoice = ref
        .read(reminderComposeDataProvider(invoiceId))
        .value
        ?.invoice;
    if (invoice == null) return state.body;
    return const ComposeReminderMessageUseCase()(
      tone: tone,
      clientName: invoice.clientName ?? 'quý khách',
      amount: invoice.amountOutstanding,
      dueDate: invoice.dueDate,
      attachPaymentLink: attachPaymentLink,
    );
  }

  /// "Gửi ngay": tạo reminder chính, và nếu "repeatAfterDays" khác null thì
  /// tạo THÊM MỘT reminder thứ hai với `scheduledAt` lùi thêm N ngày — hai
  /// lượt gọi backend riêng biệt (backend không có khái niệm "lặp lại", đây
  /// là hai bản ghi độc lập).
  Future<void> sendNow({
    required Invoice invoice,
    required ReminderType reminderType,
  }) async {
    final now = ref.read(appClockProvider)();
    final useCase = ScheduleReminderUseCase(
      ref.read(remindersRepositoryProvider),
    );
    await useCase(
      targetType: ReminderTargetType.invoice,
      targetId: invoice.id,
      reminderType: reminderType,
      channel: state.channel,
      scheduledAt: now,
      messagePreview: state.body,
    );
    if (state.repeatAfterDays != null) {
      await useCase(
        targetType: ReminderTargetType.invoice,
        targetId: invoice.id,
        reminderType: reminderType,
        channel: state.channel,
        scheduledAt: now.add(Duration(days: state.repeatAfterDays!)),
        messagePreview: state.body,
      );
    }
    ref.invalidate(remindersProvider);
  }
}
