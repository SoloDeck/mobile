import 'package:flutter/material.dart';
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
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_type.dart';
import 'package:solodesk_mobile/modules/reminders/infrastructure/repository/reminders_repository_impl.dart';
import 'package:solodesk_mobile/modules/reminders/presentation/pages/reminder_compose_page.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/accent_card.dart';
import 'package:solodesk_mobile/ui/bottom_action_bar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';
import 'package:solodesk_mobile/ui/solo_nav_bar.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

import '../flutter_test_config.dart';
import '../support/fake_settings_repository.dart';

/// Repo giả trả về đúng một `Invoice` cố định — đủ cho
/// `reminderComposeDataProvider` (nó chỉ gọi `getInvoice`). Các phương thức
/// khác của `InvoicesRepository` không được màn này dùng tới.
class _FakeInvoicesRepository implements InvoicesRepository {
  const _FakeInvoicesRepository(this.invoice);

  final Invoice invoice;

  @override
  Future<Invoice> getInvoice(String id) async => invoice;

  @override
  Future<InvoiceListPage> listInvoices({
    InvoiceListFilter filter = const InvoiceListFilter(),
    int page = 1,
    int pageSize = 20,
  }) async => throw UnimplementedError();

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
  }) async => throw UnimplementedError();

  @override
  Future<Invoice> updateInvoice({
    required String id,
    double? subtotal,
    DateTime? dueDate,
    double? taxRate,
    String? notes,
    List<LineItemInput>? lineItems,
  }) async => throw UnimplementedError();

  @override
  Future<Invoice> sendInvoice(String id) async => throw UnimplementedError();

  @override
  Future<Invoice> voidInvoice(String id) async => throw UnimplementedError();

  @override
  Future<List<PaymentRecord>> listPayments(String id) async =>
      throw UnimplementedError();

  @override
  Future<Invoice> recordPayment({
    required String id,
    required double amount,
    required DateTime paymentDate,
    PaymentMethod? paymentMethod,
    String? referenceNote,
  }) async => throw UnimplementedError();
}

/// Repo giả cho `RemindersRepository` — `listReminders` trả rỗng (đủ cho
/// `remindersProvider` mà `sendNow` gọi `ref.invalidate` sau khi gửi) và
/// `createReminder` trả một `Reminder` giả bất kỳ, đủ để `sendNow` không
/// crash NẾU golden test lỡ chạm nút. Golden test này không bấm nút nào, chỉ
/// pump và chụp — các phương thức còn lại không được dùng tới.
class _FakeRemindersRepository implements RemindersRepository {
  const _FakeRemindersRepository();

  @override
  Future<List<Reminder>> listReminders({
    ReminderListFilter filter = const ReminderListFilter(),
  }) async => [];

  @override
  Future<Reminder> createReminder({
    required ReminderTargetType targetType,
    required String targetId,
    required ReminderType reminderType,
    required ReminderChannel channel,
    required DateTime scheduledAt,
    String? messagePreview,
  }) async => Reminder(
    id: 'rem-1',
    ownerUserId: 'u-1',
    targetType: targetType,
    targetId: targetId,
    reminderType: reminderType,
    channel: channel,
    status: ReminderStatus.pending,
    scheduledAt: scheduledAt,
    createdAt: scheduledAt,
    messagePreview: messagePreview,
  );

  @override
  Future<Reminder?> getReminder(String id) async => throw UnimplementedError();

  @override
  Future<Reminder> updateReminder({
    required String id,
    DateTime? scheduledAt,
    String? messagePreview,
    ReminderChannel? channel,
  }) async => throw UnimplementedError();

  @override
  Future<void> cancelReminder(String id) async => throw UnimplementedError();
}

/// Hoá đơn cần nhắc — `amountOutstanding` truyền rõ 7.500.000 để '7.500.000
/// ₫' đúng và `isOverdue` tính `true` với `appClockProvider` ghim ở 25/07 bên
/// dưới (hạn 19/07, chưa ở trạng thái terminal).
final _invoice = Invoice(
  id: 'inv-1',
  ownerUserId: 'u-1',
  clientId: 'c-1',
  invoiceNumber: 'HD-2026-0042',
  status: InvoiceStatus.sent,
  issueDate: DateTime(2026, 7, 1),
  dueDate: DateTime(2026, 7, 19),
  total: 7500000,
  createdAt: DateTime(2026, 7, 1),
  clientName: 'Cty TNHH Minh An',
  currency: 'VND',
  amountOutstanding: 7500000,
);

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        invoicesRepositoryProvider.overrideWithValue(
          _FakeInvoicesRepository(_invoice),
        ),
        remindersRepositoryProvider.overrideWithValue(
          const _FakeRemindersRepository(),
        ),
        // Ghim mốc 25/07/2026: hạn 19/07 → "TRỄ 6 NGÀY".
        appClockProvider.overrideWithValue(() => DateTime(2026, 7, 25)),
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ReminderComposePage(invoiceId: 'inv-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MÀN 12 — cấu trúc theo figcaption', () {
    testWidgets('ba mức giọng văn, đúng một mức đang chọn (tone mực đặc)', (
      tester,
    ) async {
      await _pump(tester);

      final byLabel = {
        for (final chip in tester.widgetList<StatusChip>(
          find.byType(StatusChip),
        ))
          chip.label: chip.tone,
      };

      expect(byLabel['Thân mật'], Tone.neutral);
      expect(byLabel['Lịch sự'], Tone.solid);
      expect(byLabel['Dứt khoát'], Tone.neutral);
    });

    testWidgets(
      'công tắc MoMo mặc định bật, công tắc tự nhắc lại mặc định tắt',
      (tester) async {
        final handle = tester.ensureSemantics();
        await _pump(tester);

        expect(
          find.bySemanticsLabel('Đính kèm link MoMo, đang bật'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('Tự nhắc lại sau 3 ngày, đang tắt'),
          findsOneWidget,
        );
        handle.dispose();
      },
    );

    testWidgets('bản nháp AI có nhãn "Sửa được", không gửi thẳng', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('Sửa được'), findsOneWidget);
      expect(find.text('Sửa lời'), findsOneWidget);
      expect(find.text('Gửi ngay'), findsOneWidget);

      final draftCard = tester.widget<AccentCard>(find.byType(AccentCard));
      expect(draftCard.tone, Tone.ai);
    });

    testWidgets('kênh gửi Zalo OA đã chọn sẵn, email chỉ là dự phòng', (
      tester,
    ) async {
      await _pump(tester);

      final byLabel = {
        for (final chip in tester.widgetList<StatusChip>(
          find.byType(StatusChip),
        ))
          chip.label: chip.tone,
      };

      expect(byLabel['Zalo OA'], Tone.ok);
      expect(byLabel['Email dự phòng'], Tone.neutral);
    });

    testWidgets('nút gửi nằm trong dải hành động nổi ở đáy', (tester) async {
      await _pump(tester);
      expect(find.byType(BottomActionBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(BottomActionBar),
          matching: find.text('Gửi ngay'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('nút quay lại có nối hành động', (tester) async {
      await _pump(tester);
      final back = tester.widget<IconButtonBox>(
        find.byWidgetPredicate(
          (w) => w is IconButtonBox && w.label == 'Quay lại',
        ),
      );
      expect(back.onTap, isNotNull);
    });
  });

  group('MÀN 12 — quy ước màu', () {
    testWidgets('chỉ một tấm phiếu răng cưa, viền hồng nhạt vì là tiền', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.byType(SlipCard), findsOneWidget);
      final slip = tester.widget<SlipCard>(find.byType(SlipCard));
      expect(slip.borderColor, AppColors.momoLine);
    });

    testWidgets('số tiền trong phiếu tô hồng vì là tiền đang phải đòi', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.text('7.500.000 ₫'), findsOneWidget);
    });
  });

  group('MÀN 12 — chuỗi hiển thị chép từ bản phác thảo', () {
    testWidgets('nguyên văn tiếng Việt, không diễn giải lại', (tester) async {
      await _pump(tester);

      for (final text in [
        'Nhắc thanh toán',
        'Cty TNHH Minh An',
        'Hoá đơn HD-2026-0042 · đến hạn 19/07',
        'Số tiền',
        'Thân mật',
        'Lịch sự',
        'Dứt khoát',
        'Sửa được',
        'Đính kèm link MoMo',
        'Tự nhắc lại sau 3 ngày',
        'Zalo OA',
        'Email dự phòng',
        'Sửa lời',
        'Gửi ngay',
      ]) {
        expect(find.text(text), findsWidgets, reason: 'thiếu chuỗi "$text"');
      }

      // Con dấu tự in hoa: "Trễ 6 ngày" hiển thị thành "TRỄ 6 NGÀY".
      expect(find.text('TRỄ 6 NGÀY'), findsOneWidget);

      // SectionLabel tự in hoa: "Gửi cho" / "Giọng văn" hiển thị IN HOA.
      expect(find.text('GỬI CHO'), findsOneWidget);
      expect(find.text('GIỌNG VĂN'), findsOneWidget);

      // Đoạn thư AI soạn chép nguyên văn, kể cả đường lùi (xuất hoá đơn, dời
      // lịch) mà figcaption nói là cố ý phải có.
      expect(
        find.textContaining('trị giá', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('xuất hoá đơn hay lùi lịch', findRichText: true),
        findsOneWidget,
      );
    });
  });

  group('MÀN 12 — quy tắc không được vi phạm', () {
    testWidgets('nền màn là màu giấy, không phải trắng', (tester) async {
      await _pump(tester);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        AppColors.paper,
      );
    });

    testWidgets('không có thành phần kéo thả nào', (tester) async {
      await _pump(tester);
      expect(find.byType(Draggable<Object>), findsNothing);
      expect(find.byType(ReorderableListView), findsNothing);
    });

    testWidgets('màn con không có thanh tab dưới — chỉ có dải hành động', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.byType(SoloNavBar), findsNothing);
      expect(find.byType(BottomActionBar), findsOneWidget);
    });
  });

  testWidgets('ảnh vàng — màn 12 nhắc thu tiền', (tester) async {
    await _pump(tester);
    await expectLater(
      find.byType(ReminderComposePage),
      matchesGoldenFile('goldens/screen_12_payment_reminder.png'),
    );
  }, skip: !soloFontsLoaded);
}
