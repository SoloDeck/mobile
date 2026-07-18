import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_query.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/datasource/invoices_local_datasource.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/datasource/invoices_remote_datasource.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/invoice_response_dto.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/repository/invoices_repository_impl.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

class _MockRemote extends Mock implements InvoicesRemoteDatasource {}

Invoice _invoice({
  String id = 'inv-1',
  InvoiceStatus status = InvoiceStatus.sent,
  double outstanding = 11000000,
}) => Invoice(
  id: id,
  ownerUserId: 'owner-1',
  clientId: 'client-1',
  invoiceNumber: 'INV-2026-0042',
  status: status,
  issueDate: DateTime.utc(2026, 7, 1),
  dueDate: DateTime.utc(2026, 7, 15),
  total: 11000000,
  createdAt: DateTime.utc(2026, 7, 1),
  clientName: 'Công ty ABC',
  amountOutstanding: outstanding,
  updatedAt: DateTime.utc(2026, 7, 2),
);

InvoiceResponseDto _dto(String id) => InvoiceResponseDto.fromJson({
  'id': id,
  'owner_user_id': 'owner-1',
  'client_id': 'client-1',
  'client_name': 'Công ty ABC',
  'invoice_number': 'INV-2026-0042',
  'status': 'sent',
  'issue_date': '2026-07-01',
  'due_date': '2026-07-15',
  'total': 11000000,
  'amount_outstanding': 11000000,
  'created_at': '2026-07-01T08:00:00Z',
  'updated_at': '2026-07-02T08:00:00Z',
});

void main() {
  late AppDatabase database;
  late InvoicesLocalDatasource local;
  late _MockRemote remote;
  late InvoicesRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(const InvoiceListFilter()));

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    local = InvoicesLocalDatasource(database);
    remote = _MockRemote();
    repository = InvoicesRepositoryImpl(remote, local);
  });

  tearDown(() => database.close());

  test('listInvoices returns the cached summary when offline', () async {
    await local.upsertInvoices([_invoice()]);
    when(
      () => remote.listInvoices(
        filter: any(named: 'filter'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      ),
    ).thenThrow(NetworkException.noConnection());

    final page = await repository.listInvoices();

    expect(page.invoices.single.id, 'inv-1');
    expect(page.hasMore, isFalse);
  });

  test(
    'a successful list refresh seeds the cache and reports hasMore',
    () async {
      when(
        () => remote.listInvoices(
          filter: any(named: 'filter'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer(
        (_) async => (items: [_dto('inv-1')], page: 1, totalPages: 3),
      );

      final page = await repository.listInvoices();
      final cached = await local.listInvoices();

      expect(page.invoices.single.id, 'inv-1');
      expect(page.hasMore, isTrue);
      expect(cached.single.id, 'inv-1');
      expect(cached.single.amountOutstanding, 11000000);
    },
  );

  test(
    'offline load-more (page > 1) rethrows instead of serving stale cache',
    () async {
      when(
        () => remote.listInvoices(
          filter: any(named: 'filter'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenThrow(NetworkException.noConnection());

      expect(
        () => repository.listInvoices(page: 2),
        throwsA(isA<NetworkException>()),
      );
    },
  );

  test('the offline cache is filtered the same way as the server', () async {
    await local.upsertInvoices([
      _invoice(id: 'inv-1', status: InvoiceStatus.draft),
      _invoice(id: 'inv-2', status: InvoiceStatus.paid, outstanding: 0),
    ]);
    when(
      () => remote.listInvoices(
        filter: any(named: 'filter'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      ),
    ).thenThrow(NetworkException.noConnection());

    final page = await repository.listInvoices(
      filter: const InvoiceListFilter(status: InvoiceStatus.draft),
    );

    expect(page.invoices, hasLength(1));
    expect(page.invoices.single.id, 'inv-1');
  });
}
