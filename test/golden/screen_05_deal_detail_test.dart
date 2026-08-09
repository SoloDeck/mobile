import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal_activity.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal_attachment.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deal_activities_repository.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deal_attachments_repository.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deals_repository.dart';
import 'package:solodesk_mobile/modules/deals/domain/value_objects/deal_activity_type.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/repository/deal_activities_repository_impl.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/repository/deal_attachments_repository_impl.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/repository/deals_repository_impl.dart';
import 'package:solodesk_mobile/modules/deals/presentation/pages/deal_detail_page_new.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/repositories/invoices_repository.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_query.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/payment_method.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/repository/invoices_repository_impl.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/tasks/domain/entities/task.dart';
import 'package:solodesk_mobile/modules/tasks/domain/repositories/tasks_repository.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/priority.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_status.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/repository/tasks_repository_impl.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/filter_chip_bar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';
import 'package:solodesk_mobile/ui/solo_nav_bar.dart';
import 'package:solodesk_mobile/ui/stage_bar.dart';
import 'package:solodesk_mobile/ui/stamp_badge.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

import '../flutter_test_config.dart';
import '../support/fake_settings_repository.dart';

/// Repo giả trả về đúng một `Deal` cố định — đủ cho `dealDetailProvider`.
///
/// Không `const` được nữa: nó phải *ghi nhớ* lần gọi `transitionStage` gần
/// nhất để test chốt được "chạm mục nào thì gửi đúng giai đoạn đó".
class _FakeDealsRepository implements DealsRepository {
  _FakeDealsRepository(this.deal, {this.transitionError});

  final Deal deal;

  /// Lỗi mà [transitionStage] sẽ ném, để thử đường báo lỗi của màn.
  final Object? transitionError;

  /// Giai đoạn đích của lần gọi [transitionStage] gần nhất; `null` khi chưa
  /// gọi lần nào.
  DealStage? lastTargetStage;

  @override
  Future<List<Deal>> listDeals({DealStage? stage}) async => [deal];

  @override
  Future<Deal> getDeal(String id) async => deal;

  @override
  Future<Deal> createDeal({
    required String clientId,
    required String title,
    DealSource? source,
    double? estimatedValue,
    String? currency,
    String? notes,
  }) async => deal;

  @override
  Future<Deal> transitionStage({
    required String id,
    required DealStage targetStage,
    String? note,
  }) async {
    lastTargetStage = targetStage;
    if (transitionError != null) throw transitionError!;
    return deal.copyWith(stage: targetStage);
  }
}

/// Repo giả trả về đúng danh sách hoá đơn đã gán cho `dealId` — đủ cho
/// `dealInvoicesProvider` (nó tự lọc theo `dealId` phía trên use case).
class _FakeInvoicesRepository implements InvoicesRepository {
  const _FakeInvoicesRepository(this.invoices);

  final List<Invoice> invoices;

  @override
  Future<InvoiceListPage> listInvoices({
    InvoiceListFilter filter = const InvoiceListFilter(),
    int page = 1,
    int pageSize = 20,
  }) async => InvoiceListPage(invoices: invoices, page: page, hasMore: false);

  @override
  Future<Invoice> getInvoice(String id) async =>
      invoices.firstWhere((invoice) => invoice.id == id);

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
  }) async => invoices.first;

  @override
  Future<Invoice> updateInvoice({
    required String id,
    double? subtotal,
    DateTime? dueDate,
    double? taxRate,
    String? notes,
    List<LineItemInput>? lineItems,
  }) async => invoices.first;

  @override
  Future<Invoice> sendInvoice(String id) async => invoices.first;

  @override
  Future<Invoice> voidInvoice(String id) async => invoices.first;

  @override
  Future<List<PaymentRecord>> listPayments(String id) async => [];

  @override
  Future<Invoice> recordPayment({
    required String id,
    required double amount,
    required DateTime paymentDate,
    PaymentMethod? paymentMethod,
    String? referenceNote,
  }) async => invoices.first;
}

/// Repo giả cho tab "Dự án" — trả về đúng một task gắn thẳng vào deal (không
/// đi qua lớp project, khác bản cũ đã xoá).
class _FakeTasksRepository implements TasksRepository {
  const _FakeTasksRepository(this.tasks);

  final List<Task> tasks;

  @override
  Future<List<Task>> listByEntity({
    required TaskOwner entityType,
    required String entityId,
    TaskStatus? status,
  }) async => tasks;

  @override
  Future<Task> getTask(String id) async =>
      tasks.firstWhere((t) => t.id == id);

  @override
  Future<Task> createTask({
    required TaskOwner entityType,
    required String entityId,
    required String title,
    String? description,
    Priority? priority,
    DateTime? deadline,
  }) async => tasks.first;

  @override
  Future<Task> updateStatus({
    required String taskId,
    required TaskStatus status,
  }) async => tasks.firstWhere((t) => t.id == taskId);
}

/// Repo giả cho tab "Tài liệu".
class _FakeDealAttachmentsRepository implements DealAttachmentsRepository {
  const _FakeDealAttachmentsRepository(this.attachments);

  final List<DealAttachment> attachments;

  @override
  Future<List<DealAttachment>> listAttachments(String dealId) async =>
      attachments;

  @override
  Future<DealAttachment> uploadAttachment({
    required String dealId,
    required String filePath,
    required String filename,
  }) async => attachments.first;

  @override
  Future<List<int>> downloadAttachment(String attachmentId) async => [1, 2, 3];

  @override
  Future<void> deleteAttachment(String attachmentId) async {}
}

/// Repo giả cho tab "Lịch sử".
class _FakeDealActivitiesRepository implements DealActivitiesRepository {
  const _FakeDealActivitiesRepository(this.activities);

  final List<DealActivity> activities;

  @override
  Future<List<DealActivity>> listActivities(String dealId) async =>
      activities;
}

final _testDeal = Deal(
  id: 'd1',
  ownerUserId: 'u1',
  clientId: 'c1',
  title: 'Nhận diện Minh An',
  stage: DealStage.active,
  createdAt: DateTime.utc(2026, 6, 1),
  clientName: 'Cty TNHH Minh An',
  actualValue: 25000000,
);

Invoice _invoice({
  required String id,
  required String invoiceNumber,
  required InvoiceStatus status,
  required double total,
  required DateTime dueDate,
}) => Invoice(
  id: id,
  ownerUserId: 'u1',
  clientId: 'c1',
  invoiceNumber: invoiceNumber,
  status: status,
  issueDate: DateTime.utc(2026, 6, 1),
  dueDate: dueDate,
  total: total,
  createdAt: DateTime.utc(2026, 6, 1),
  dealId: 'd1',
);

final _testInvoices = [
  _invoice(
    id: 'i1',
    invoiceNumber: 'HD-001',
    status: InvoiceStatus.paid,
    total: 12500000,
    dueDate: DateTime.utc(2026, 6, 10),
  ),
  _invoice(
    id: 'i2',
    invoiceNumber: 'HD-002',
    status: InvoiceStatus.overdue,
    total: 7500000,
    dueDate: DateTime.utc(2026, 6, 15),
  ),
  _invoice(
    id: 'i3',
    invoiceNumber: 'HD-003',
    status: InvoiceStatus.sent,
    total: 5000000,
    dueDate: DateTime.utc(2027, 1, 1),
  ),
];

final _testTasks = [
  Task(
    id: 't1',
    entityType: TaskOwner.deal,
    entityId: 'd1',
    title: 'Gửi bản nháp logo vòng 2',
    priority: Priority.high,
    status: TaskStatus.inProgress,
    createdAt: DateTime.utc(2026, 6, 1),
  ),
];

final _testAttachments = [
  DealAttachment(
    id: 'att-1',
    dealId: 'd1',
    filename: 'brief.pdf',
    contentType: 'application/pdf',
    sizeBytes: 20480,
    // Cố ý false: để test tab Tài liệu phủ luôn nhánh hiện badge cảnh báo.
    aiReadable: false,
    createdAt: DateTime.utc(2026, 7, 1),
  ),
];

final _testActivities = [
  DealActivity(
    id: 'act-1',
    dealId: 'd1',
    entryType: DealActivityType.stageChange,
    description: 'Stage changed: qualified → active',
    createdAt: DateTime.utc(2026, 7, 1),
    previousStage: DealStage.qualified,
    newStage: DealStage.active,
  ),
];

/// [deals] cho phép từng test thay repo giả (deal ở giai đoạn khác, hoặc repo
/// ném lỗi). Bỏ trống thì đúng cấu hình mặc định mà ảnh vàng chốt.
Future<void> _pump(WidgetTester tester, {_FakeDealsRepository? deals}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dealsRepositoryProvider.overrideWithValue(
          deals ?? _FakeDealsRepository(_testDeal),
        ),
        invoicesRepositoryProvider.overrideWithValue(
          _FakeInvoicesRepository(_testInvoices),
        ),
        tasksRepositoryProvider.overrideWithValue(
          _FakeTasksRepository(_testTasks),
        ),
        dealAttachmentsRepositoryProvider.overrideWithValue(
          _FakeDealAttachmentsRepository(_testAttachments),
        ),
        dealActivitiesRepositoryProvider.overrideWithValue(
          _FakeDealActivitiesRepository(_testActivities),
        ),
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const DealDetailPage(dealId: 'd1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Màu chữ của `Text` hiển thị đúng [text], để so với quy ước tone của màn.
Color _colorOfText(WidgetTester tester, String text) {
  final widget = tester.widget<Text>(find.text(text));
  return widget.style!.color!;
}

void main() {
  group('MÀN 05 — cấu trúc theo figcaption', () {
    testWidgets(
      'nút nhắn Zalo đặt cạnh tên khách, không gộp vào menu ba chấm ở appbar',
      (tester) async {
        await _pump(tester);

        // Đúng ba ô icon: quay lại, ba chấm (appbar), và nhắn Zalo (thẻ
        // khách hàng) — không có ô thứ tư nào gộp Zalo vào appbar.
        final boxes = tester.widgetList<IconButtonBox>(
          find.byType(IconButtonBox),
        );
        expect(boxes.length, 3);

        final zalo = find.byWidgetPredicate(
          (w) => w is IconButtonBox && w.label == 'Nhắn Zalo',
        );
        expect(zalo, findsOneWidget);
        expect(tester.widget<IconButtonBox>(zalo).tone, Tone.ok);

        // Nằm ở thẻ khách hàng, tức là phía trên thẻ giai đoạn.
        final zaloTop = tester.getTopLeft(zalo).dy;
        final stageBarTop = tester.getTopLeft(find.byType(StageBar)).dy;
        expect(zaloTop, lessThan(stageBarTop));
      },
    );

    testWidgets(
      'thanh sáu vạch phản ánh đúng giai đoạn của deal thật, bước 5/6 cho '
      '"active"',
      (tester) async {
        await _pump(tester);

        final stageBar = tester.widget<StageBar>(find.byType(StageBar));
        expect(stageBar.filledSteps, 5);
        expect(find.text('Đang triển khai · bước 5/6'), findsOneWidget);
      },
    );

    testWidgets('lịch thanh toán dựng bằng tờ phiếu vì đúng là tiền', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.byType(SlipCard), findsOneWidget);
      final stamp = tester.widget<StampBadge>(
        find.descendant(
          of: find.byType(SlipCard),
          matching: find.byType(StampBadge),
        ),
      );
      expect(stamp.tone, Tone.money);
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

    testWidgets('tab con gom bằng dải chip cuộn ngang, "Tổng quan" đang chọn', (
      tester,
    ) async {
      await _pump(tester);

      final bar = tester.widget<FilterChipBar>(find.byType(FilterChipBar));
      expect(bar.labels, ['Tổng quan', 'Dự án', 'Tài liệu', 'Lịch sử']);
      expect(bar.selectedIndex, 0);
    });
  });

  group('MÀN 05 — quy ước màu', () {
    testWidgets('giá trị hợp đồng là số tham chiếu, không phải công nợ', (
      tester,
    ) async {
      await _pump(tester);

      expect(_colorOfText(tester, '25.000.000 ₫'), AppColors.ink);
    });

    testWidgets(
      'lịch thanh toán: đã thu màu ngọc, quá hạn màu hồng, chưa tới màu xám',
      (tester) async {
        await _pump(tester);

        expect(_colorOfText(tester, '12.500.000 ₫'), AppColors.jade);
        expect(_colorOfText(tester, '7.500.000 ₫'), AppColors.momo);
        expect(_colorOfText(tester, '5.000.000 ₫'), AppColors.ink3);
      },
    );

    testWidgets('chip "Đổi giai đoạn" trung tính, không phải nút hành động', (
      tester,
    ) async {
      await _pump(tester);

      final chip = tester
          .widgetList<StatusChip>(find.byType(StatusChip))
          .firstWhere((c) => c.label == 'Đổi giai đoạn');
      expect(chip.tone, Tone.neutral);
    });

    testWidgets('chỉ một tấm phiếu răng cưa trong cả màn', (tester) async {
      await _pump(tester);
      expect(find.byType(SlipCard), findsOneWidget);
    });
  });

  group('MÀN 05 — dữ liệu nối thật từ provider', () {
    testWidgets('tên khách và giá trị hợp đồng lấy từ Deal, không phải mock', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('Nhận diện Minh An'), findsWidgets);
      expect(find.text('Cty TNHH Minh An'), findsOneWidget);
      expect(find.text('25.000.000 ₫'), findsOneWidget);
    });

    testWidgets(
      'mỗi hoá đơn của deal thành một dòng trong lịch thanh toán, đúng số '
      'tiền và trạng thái thật',
      (tester) async {
        await _pump(tester);

        expect(find.text('Hóa đơn HD-001 · Đã thanh toán'), findsOneWidget);
        expect(find.text('Hóa đơn HD-002 · Quá hạn'), findsOneWidget);
        expect(find.text('Hóa đơn HD-003 · Đã gửi'), findsOneWidget);
      },
    );

    testWidgets('nút MoMo và con dấu quá hạn nêu đúng hoá đơn đang quá hạn', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('HD-002 QUÁ HẠN'), findsOneWidget);
      expect(find.text('Tạo link MoMo cho hóa đơn HD-002'), findsOneWidget);
    });
  });

  group('MÀN 05 — tab con Dự án / Tài liệu / Lịch sử nối API thật', () {
    testWidgets('tab "Dự án" hiện task gắn thẳng vào deal, không qua project', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(find.text('Dự án'));
      await tester.pumpAndSettle();

      expect(find.text('Gửi bản nháp logo vòng 2'), findsOneWidget);
    });

    testWidgets(
      'tab "Tài liệu" hiện tên file và cảnh báo khi AI chưa đọc được',
      (tester) async {
        await _pump(tester);
        await tester.tap(find.text('Tài liệu'));
        await tester.pumpAndSettle();

        expect(find.text('brief.pdf'), findsOneWidget);
        expect(find.text('AI chưa đọc được nội dung này'), findsOneWidget);
      },
    );

    testWidgets(
      'tab "Lịch sử" hiện đúng mô tả và chiều đổi giai đoạn của activity thật',
      (tester) async {
        await _pump(tester);
        await tester.dragUntilVisible(
          find.text('Lịch sử'),
          find.byType(FilterChipBar),
          const Offset(-60, 0),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Lịch sử'));
        await tester.pumpAndSettle();

        expect(
          find.text('Stage changed: qualified → active'),
          findsOneWidget,
        );
        expect(find.text('Đã sàng lọc → Đang triển khai'), findsOneWidget);
      },
    );
  });

  group('MÀN 05 — chuỗi hiển thị chép từ bản phác thảo', () {
    testWidgets('nguyên văn tiếng Việt, không diễn giải lại', (tester) async {
      await _pump(tester);

      for (final text in [
        'Nhận diện Minh An',
        'Cty TNHH Minh An',
        'Chị Hạnh · 0903 xxx 118',
        'GIÁ TRỊ HỢP ĐỒNG',
        '25.000.000 ₫',
        'GIAI ĐOẠN',
        'Đang triển khai · bước 5/6',
        'Đổi giai đoạn',
        'Tổng quan',
        'Dự án',
        'Tài liệu',
        'LỊCH THANH TOÁN',
        'HD-002 QUÁ HẠN',
        'Hóa đơn HD-001 · Đã thanh toán',
        '12.500.000 ₫',
        'Hóa đơn HD-002 · Quá hạn',
        '7.500.000 ₫',
        'Hóa đơn HD-003 · Đã gửi',
        '5.000.000 ₫',
        'Tạo link MoMo cho hóa đơn HD-002',
        'TRAO ĐỔI GẦN NHẤT',
        'Thêm ghi chú',
        'Chị Hạnh xin lùi duyệt nháp sang tuần sau, sẽ chuyển cọc đợt 2 vào '
            'thứ Hai.',
        'Ghi qua giọng nói · 19/07',
      ]) {
        expect(find.text(text), findsWidgets, reason: 'thiếu chuỗi "$text"');
      }

      // "Lịch sử" là chip cuối của dải cuộn ngang; `ListView.separated` chỉ
      // dựng chip đang nằm trong khung nhìn nên phải kéo dải sang trái trước
      // khi tìm được chuỗi này.
      await tester.dragUntilVisible(
        find.text('Lịch sử'),
        find.byType(FilterChipBar),
        const Offset(-60, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('Lịch sử'), findsWidgets);
    });
  });

  group('MÀN 05 — đổi giai đoạn qua bảng chọn', () {
    testWidgets('bảng chỉ hiện đúng những giai đoạn đi tiếp được', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(find.text('Đổi giai đoạn'));
      await tester.pumpAndSettle();

      // `active` chỉ đi tiếp được sang "hoàn tất & xuất hóa đơn", cộng lối
      // thoát "đã mất" mà mọi giai đoạn chưa kết thúc đều có.
      expect(find.text('Hoàn tất & xuất hóa đơn'), findsOneWidget);
      expect(find.text('Đã mất'), findsOneWidget);

      // Pipeline chỉ chạy tới, không lùi: không giai đoạn nào phía trước được
      // bày ra để bấm.
      for (final label in [
        'Khách mới',
        'Đã sàng lọc',
        'Đã gửi báo giá',
        'Đang đàm phán',
      ]) {
        expect(find.text(label), findsNothing, reason: 'lộ giai đoạn "$label"');
      }
    });

    testWidgets('chạm một giai đoạn thì gửi đúng giai đoạn đó xuống repo', (
      tester,
    ) async {
      final deals = _FakeDealsRepository(_testDeal);
      await _pump(tester, deals: deals);

      await tester.tap(find.text('Đổi giai đoạn'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hoàn tất & xuất hóa đơn'));
      await tester.pumpAndSettle();

      expect(deals.lastTargetStage, DealStage.completedAndBilled);
      // Bảng đóng trước khi gửi, để SnackBar lỗi không bị che.
      expect(find.text('Chuyển sang'.toUpperCase()), findsNothing);
    });

    testWidgets('thương vụ đã kết thúc thì bảng nói rõ không còn bước nào', (
      tester,
    ) async {
      await _pump(
        tester,
        deals: _FakeDealsRepository(
          _testDeal.copyWith(stage: DealStage.completedAndBilled),
        ),
      );

      await tester.tap(find.text('Đổi giai đoạn'));
      await tester.pumpAndSettle();

      expect(find.text('Thương vụ đã ở trạng thái kết thúc.'), findsOneWidget);
      expect(find.text('Hoàn tất & xuất hóa đơn'), findsNothing);
    });

    testWidgets('đổi giai đoạn hỏng thì hiện SnackBar báo lỗi', (tester) async {
      await _pump(
        tester,
        deals: _FakeDealsRepository(
          _testDeal,
          transitionError: const ServerException(500, 'Máy chủ đang bận'),
        ),
      );

      await tester.tap(find.text('Đổi giai đoạn'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hoàn tất & xuất hóa đơn'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      // `AppException` mang sẵn câu tiếng Việt — không in `toString()` trần.
      expect(find.text('Máy chủ đang bận'), findsOneWidget);

      // Chạy hết thời gian sống của SnackBar để không còn Timer treo lúc test
      // kết thúc.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  });

  group('MÀN 05 — quy tắc không được vi phạm', () {
    testWidgets('nền màn là màu giấy, không phải trắng', (tester) async {
      await _pump(tester);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        AppColors.paper,
      );
    });

    testWidgets('không có SoloNavBar — đây là màn con, không phải mục tab', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.byType(SoloNavBar), findsNothing);
    });

    testWidgets('không có thành phần kéo thả nào (đổi giai đoạn qua menu)', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.byType(Draggable<Object>), findsNothing);
      expect(find.byType(ReorderableListView), findsNothing);
    });

    testWidgets('không có khung máy mockup — không .sbar, không .homebar', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.text('9:41'), findsNothing);
    });
  });

  testWidgets('ảnh vàng — màn 05 chi tiết thương vụ', (tester) async {
    await _pump(tester);
    await expectLater(
      find.byType(DealDetailPage),
      matchesGoldenFile('goldens/screen_05_deal_detail.png'),
    );
  }, skip: !soloFontsLoaded);
}
