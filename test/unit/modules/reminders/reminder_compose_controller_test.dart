import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/core/time/app_clock.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/repositories/invoices_repository.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_query.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/payment_method.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/repository/invoices_repository_impl.dart';
import 'package:solodesk_mobile/modules/reminders/domain/entities/reminder.dart';
import 'package:solodesk_mobile/modules/reminders/domain/repositories/reminders_repository.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_channel.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_query.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_status.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_target_type.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_tone.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_type.dart';
import 'package:solodesk_mobile/modules/reminders/infrastructure/repository/reminders_repository_impl.dart';
import 'package:solodesk_mobile/modules/reminders/presentation/controllers/reminder_compose_controller.dart';
import 'package:solodesk_mobile/modules/reminders/presentation/providers/reminders_provider.dart';

/// Fake tối thiểu — chỉ [getInvoice] có ý nghĩa cho luồng compose, các
/// phương thức khác không được gọi trong các test này.
class _FakeInvoicesRepository implements InvoicesRepository {
  _FakeInvoicesRepository(this.invoice);

  final Invoice invoice;

  @override
  Future<Invoice> getInvoice(String id) async => invoice;

  @override
  Future<InvoiceListPage> listInvoices({
    InvoiceListFilter filter = const InvoiceListFilter(),
    int page = 1,
    int pageSize = 20,
  }) => throw UnimplementedError();

  @override
  Future<Invoice> createInvoice({
    required String clientId,
    String? contractId,
    String? dealId,
    DateTime? issueDate,
    required DateTime dueDate,
    String? currency,
    double? subtotal,
    double? taxRate,
    String? notes,
    List<LineItemInput> lineItems = const [],
  }) => throw UnimplementedError();

  @override
  Future<Invoice> updateInvoice({
    required String id,
    double? subtotal,
    DateTime? dueDate,
    double? taxRate,
    String? notes,
    List<LineItemInput>? lineItems,
  }) => throw UnimplementedError();

  @override
  Future<Invoice> sendInvoice(String id) => throw UnimplementedError();

  @override
  Future<Invoice> voidInvoice(String id) => throw UnimplementedError();

  @override
  Future<List<PaymentRecord>> listPayments(String id) =>
      throw UnimplementedError();

  @override
  Future<Invoice> recordPayment({
    required String id,
    required double amount,
    required DateTime paymentDate,
    PaymentMethod? paymentMethod,
    String? referenceNote,
  }) => throw UnimplementedError();
}

/// Fake ghi lại mọi lệnh gọi [createReminder] để assert số lần gọi + tham số.
class _FakeRemindersRepository implements RemindersRepository {
  final List<_CreateCall> calls = [];

  @override
  Future<Reminder> createReminder({
    required ReminderTargetType targetType,
    required String targetId,
    required ReminderType reminderType,
    required ReminderChannel channel,
    required DateTime scheduledAt,
    String? messagePreview,
  }) async {
    calls.add(
      _CreateCall(
        targetType: targetType,
        targetId: targetId,
        reminderType: reminderType,
        channel: channel,
        scheduledAt: scheduledAt,
        messagePreview: messagePreview,
      ),
    );
    return Reminder(
      id: 'r-${calls.length}',
      ownerUserId: 'owner-1',
      targetType: targetType,
      targetId: targetId,
      reminderType: reminderType,
      channel: channel,
      status: ReminderStatus.pending,
      scheduledAt: scheduledAt,
      createdAt: scheduledAt,
      messagePreview: messagePreview,
    );
  }

  @override
  Future<void> cancelReminder(String id) => throw UnimplementedError();

  @override
  Future<Reminder?> getReminder(String id) => throw UnimplementedError();

  @override
  Future<List<Reminder>> listReminders({
    ReminderListFilter filter = const ReminderListFilter(),
  }) async => const [];

  @override
  Future<Reminder> updateReminder({
    required String id,
    DateTime? scheduledAt,
    String? messagePreview,
    ReminderChannel? channel,
  }) => throw UnimplementedError();
}

class _CreateCall {
  const _CreateCall({
    required this.targetType,
    required this.targetId,
    required this.reminderType,
    required this.channel,
    required this.scheduledAt,
    required this.messagePreview,
  });

  final ReminderTargetType targetType;
  final String targetId;
  final ReminderType reminderType;
  final ReminderChannel channel;
  final DateTime scheduledAt;
  final String? messagePreview;
}

final _testInvoice = Invoice(
  id: 'inv-1',
  ownerUserId: 'owner-1',
  clientId: 'client-1',
  invoiceNumber: 'INV-2026-0042',
  status: InvoiceStatus.sent,
  issueDate: DateTime.utc(2026, 7, 1),
  dueDate: DateTime.utc(2026, 7, 20),
  total: 5000000,
  createdAt: DateTime.utc(2026, 7, 1),
  clientName: 'Chị Hoa',
  amountOutstanding: 5000000,
);

void main() {
  late _FakeRemindersRepository fakeReminders;
  late ProviderContainer container;

  /// [reminderComposeControllerProvider.build] chỉ `ref.watch` một
  /// `AsyncValue` đã có sẵn (KHÔNG tự `await`) — nên phải đợi
  /// `reminderComposeDataProvider` resolve xong trước khi đọc controller,
  /// nếu không `state.body` sẽ rỗng.
  Future<ProviderContainer> makeContainer() async {
    fakeReminders = _FakeRemindersRepository();
    final c = ProviderContainer(
      overrides: [
        invoicesRepositoryProvider.overrideWithValue(
          _FakeInvoicesRepository(_testInvoice),
        ),
        remindersRepositoryProvider.overrideWithValue(fakeReminders),
        appClockProvider.overrideWithValue(() => DateTime(2026, 7, 25)),
      ],
    );
    addTearDown(c.dispose);
    await c.read(reminderComposeDataProvider(_testInvoice.id).future);
    return c;
  }

  setUp(() async {
    container = await makeContainer();
  });

  test(
    'sendNow với repeatAfterDays == null gọi createReminder ĐÚNG 1 LẦN',
    () async {
      final notifier = container.read(
        reminderComposeControllerProvider(_testInvoice.id).notifier,
      );
      final draft = container.read(
        reminderComposeControllerProvider(_testInvoice.id),
      );
      expect(draft.repeatAfterDays, isNull);

      await notifier.sendNow(
        invoice: _testInvoice,
        reminderType: ReminderType.paymentDue,
      );

      expect(fakeReminders.calls, hasLength(1));
      expect(fakeReminders.calls.single.scheduledAt, DateTime(2026, 7, 25));
    },
  );

  test('sendNow với repeatAfterDays == 3 gọi createReminder ĐÚNG 2 LẦN, '
      'lần 2 có scheduledAt = lần 1 + 3 ngày', () async {
    final notifier = container.read(
      reminderComposeControllerProvider(_testInvoice.id).notifier,
    );
    notifier.toggleRepeat(days: 3);
    expect(
      container
          .read(reminderComposeControllerProvider(_testInvoice.id))
          .repeatAfterDays,
      3,
    );

    await notifier.sendNow(
      invoice: _testInvoice,
      reminderType: ReminderType.paymentDue,
    );

    expect(fakeReminders.calls, hasLength(2));
    final first = fakeReminders.calls[0].scheduledAt;
    final second = fakeReminders.calls[1].scheduledAt;
    expect(second, first.add(const Duration(days: 3)));
  });

  test('setTone đổi state.tone và soạn lại state.body', () async {
    final notifier = container.read(
      reminderComposeControllerProvider(_testInvoice.id).notifier,
    );
    final before = container.read(
      reminderComposeControllerProvider(_testInvoice.id),
    );
    // Mặc định của ReminderDraft là "Lịch sự".
    expect(before.tone, ReminderTone.polite);
    expect(before.body, isNotEmpty);

    notifier.setTone(ReminderTone.firm);

    final after = container.read(
      reminderComposeControllerProvider(_testInvoice.id),
    );
    expect(after.tone, ReminderTone.firm);
    expect(after.body, isNot(equals(before.body)));
    // Cụm đặc trưng riêng của giọng "Dứt khoát" trong ReminderMessageComposer.
    expect(after.body, contains('Đề nghị'));
  });
}
