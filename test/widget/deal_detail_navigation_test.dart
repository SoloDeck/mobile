import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deals_repository.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/repository/deals_repository_impl.dart';
import 'package:solodesk_mobile/modules/deals/presentation/pages/deal_detail_page_new.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/repositories/invoices_repository.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_query.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/payment_method.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/repository/invoices_repository_impl.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/pages/invoice_form_page.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

/// MÀN 05 có hai lối đi bằng ngón tay sang màn hoá đơn: chạm một dòng lịch
/// thanh toán để mở đúng hoá đơn đó, và nút ba chấm → "Tạo hóa đơn" để mở form
/// tạo với thương vụ đã điền sẵn.
///
/// `test/golden/screen_05_deal_detail_test.dart` dựng `DealDetailPage` trong
/// một `MaterialApp` **không có router**, nên nó chốt được hình dáng nhưng
/// không kiểm được chạm dẫn đi đâu. Chỗ này lo phần còn lại: một `GoRouter`
/// thật ba route, hai route đích là `Scaffold` giả — cái cần kiểm là *đường
/// dẫn và `extra`*, dựng màn hoá đơn thật chỉ kéo thêm provider vào cho test dễ
/// vỡ vì lý do không liên quan.

/// Repo giả trả về đúng một `Deal` cố định — đủ cho `dealDetailProvider`.
class _FakeDealsRepository implements DealsRepository {
  const _FakeDealsRepository(this.deal);

  final Deal deal;

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
  }) async => deal;
}

/// Repo giả trả về đúng danh sách hoá đơn đã gán cho `dealId` — đủ cho
/// `dealInvoicesProvider`.
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

/// `extra` mà route `/invoices/new` nhận được ở lần dựng gần nhất. Bắt ngay
/// trong `builder` chứ không đọc `router.state.extra` sau khi điều hướng, để
/// test chốt đúng thứ màn tạo hoá đơn thật sự sẽ nhận.
Object? _lastExtra;

/// Dựng MÀN 05 trong một router thật và trả về router đó để assert đường dẫn.
Future<GoRouter> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  _lastExtra = null;

  final router = GoRouter(
    initialLocation: '/deals/d1',
    routes: [
      GoRoute(
        path: '/deals/:id',
        builder: (context, state) =>
            DealDetailPage(dealId: state.pathParameters['id']!),
      ),
      // `/invoices/new` phải đứng trước `/invoices/:id`: go_router khớp theo
      // thứ tự khai báo, để sau thì "new" bị nuốt thành một id.
      GoRoute(
        path: '/invoices/new',
        builder: (context, state) {
          _lastExtra = state.extra;
          return const Scaffold(body: Text('màn tạo hoá đơn'));
        },
      ),
      GoRoute(
        path: '/invoices/:id',
        builder: (context, state) =>
            Scaffold(body: Text(state.pathParameters['id']!)),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dealsRepositoryProvider.overrideWithValue(
          _FakeDealsRepository(_testDeal),
        ),
        invoicesRepositoryProvider.overrideWithValue(
          _FakeInvoicesRepository(_testInvoices),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();

  return router;
}

void main() {
  testWidgets('chạm một dòng lịch thanh toán thì mở đúng hoá đơn đó', (
    tester,
  ) async {
    final router = await _pump(tester);
    expect(router.state.matchedLocation, '/deals/d1');

    // Tìm theo nhãn dòng chứ không phải chỉ số: nhãn buộc test phải nói rõ nó
    // đang chạm hoá đơn nào.
    await tester.tap(find.text('Hóa đơn HD-002 · Quá hạn'));
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, '/invoices/i2');
    expect(find.text('i2'), findsOneWidget);
  });

  testWidgets('mỗi dòng mang id riêng — dòng đầu không mở hoá đơn thứ hai', (
    tester,
  ) async {
    final router = await _pump(tester);

    await tester.tap(find.text('Hóa đơn HD-001 · Đã thanh toán'));
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, '/invoices/i1');
  });

  testWidgets('ba chấm → "Tạo hóa đơn" mở form với thương vụ điền sẵn', (
    tester,
  ) async {
    final router = await _pump(tester);

    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is IconButtonBox &&
            widget.icon == SoloIcons.dots &&
            widget.label == 'Tuỳ chọn khác',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tạo hóa đơn'));
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, '/invoices/new');

    // Không chỉ tới đúng đường dẫn: form phải nhận được thương vụ và khách để
    // khoá sẵn, nếu không người dùng lại phải chọn tay đúng thứ vừa mở.
    expect(_lastExtra, isA<InvoiceFormArgs>());
    final args = _lastExtra! as InvoiceFormArgs;
    expect(args.dealId, 'd1');
    expect(args.clientId, 'c1');
    expect(args.clientName, 'Cty TNHH Minh An');
    expect(args.dealTitle, 'Nhận diện Minh An');
  });
}
