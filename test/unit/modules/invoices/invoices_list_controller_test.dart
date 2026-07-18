import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/repositories/invoices_repository.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_query.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/repository/invoices_repository_impl.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/controllers/invoices_list_controller.dart';

class _MockRepository extends Mock implements InvoicesRepository {}

Invoice _invoice(String id) => Invoice(
  id: id,
  ownerUserId: 'owner-1',
  clientId: 'client-1',
  invoiceNumber: 'INV-$id',
  status: InvoiceStatus.sent,
  issueDate: DateTime.utc(2026, 7, 1),
  dueDate: DateTime.utc(2026, 7, 15),
  total: 11000000,
  createdAt: DateTime.utc(2026, 7, 1),
  amountOutstanding: 11000000,
);

InvoiceListPage _page(
  List<Invoice> invoices, {
  int page = 1,
  bool hasMore = false,
}) => InvoiceListPage(invoices: invoices, page: page, hasMore: hasMore);

void main() {
  late _MockRepository repo;

  setUp(() => repo = _MockRepository());

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [invoicesRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('build loads the first page and reports hasMore', () async {
    when(
      () => repo.listInvoices(
        filter: const InvoiceListFilter(),
        page: 1,
        pageSize: 20,
      ),
    ).thenAnswer((_) async => _page([_invoice('1')], hasMore: true));

    final container = makeContainer();
    final state = await container.read(invoicesListControllerProvider.future);

    expect(state.invoices, hasLength(1));
    expect(state.hasMore, isTrue);
  });

  test('loadMore appends the next page and updates hasMore', () async {
    when(
      () => repo.listInvoices(
        filter: const InvoiceListFilter(),
        page: 1,
        pageSize: 20,
      ),
    ).thenAnswer((_) async => _page([_invoice('1')], page: 1, hasMore: true));
    when(
      () => repo.listInvoices(
        filter: const InvoiceListFilter(),
        page: 2,
        pageSize: 20,
      ),
    ).thenAnswer((_) async => _page([_invoice('2')], page: 2, hasMore: false));

    final container = makeContainer();
    await container.read(invoicesListControllerProvider.future);
    await container.read(invoicesListControllerProvider.notifier).loadMore();

    final state = container.read(invoicesListControllerProvider).value!;
    expect(state.invoices.map((e) => e.id), ['1', '2']);
    expect(state.hasMore, isFalse);
  });

  test('setFilter reloads page 1 with the new filter', () async {
    when(
      () => repo.listInvoices(
        filter: const InvoiceListFilter(),
        page: 1,
        pageSize: 20,
      ),
    ).thenAnswer((_) async => _page([_invoice('1')]));
    when(
      () => repo.listInvoices(
        filter: const InvoiceListFilter(overdueOnly: true),
        page: 1,
        pageSize: 20,
      ),
    ).thenAnswer((_) async => _page([_invoice('9')]));

    final container = makeContainer();
    await container.read(invoicesListControllerProvider.future);
    await container
        .read(invoicesListControllerProvider.notifier)
        .setFilter(const InvoiceListFilter(overdueOnly: true));

    final state = container.read(invoicesListControllerProvider).value!;
    expect(state.filter.overdueOnly, isTrue);
    expect(state.invoices.single.id, '9');
  });
}
