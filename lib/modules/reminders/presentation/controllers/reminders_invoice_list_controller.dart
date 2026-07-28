import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/invoices/application/usecases/list_invoices_usecase.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_query.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/repository/invoices_repository_impl.dart';

part 'reminders_invoice_list_controller.g.dart';

const _pageSize = 20;

/// Always show overdue invoices only — this screen never lets the freelancer
/// switch the filter, unlike the main Invoices tab.
const _overdueFilter = InvoiceListFilter(overdueOnly: true);

/// Accumulated state for the paginated overdue-invoices list backing the
/// "Nhắc thu tiền" screen.
@immutable
class RemindersInvoiceListState {
  const RemindersInvoiceListState({
    required this.invoices,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<Invoice> invoices;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  RemindersInvoiceListState copyWith({
    List<Invoice>? invoices,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) => RemindersInvoiceListState(
    invoices: invoices ?? this.invoices,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

/// Drives the overdue-invoices list shown on the "Nhắc thu tiền" screen:
/// initial load, pull-to-refresh and infinite scroll (load-more appends the
/// next page). Deliberately independent from `InvoicesListController` — that
/// controller is a shared singleton backing the main Invoices tab, and
/// mutating its filter from here would corrupt that other screen's state.
/// This controller only ever fetches with a fixed `overdueOnly` filter, so it
/// has no `setFilter`.
@riverpod
class RemindersInvoiceListController extends _$RemindersInvoiceListController {
  @override
  Future<RemindersInvoiceListState> build() => _fetchFirstPage();

  Future<RemindersInvoiceListState> _fetchFirstPage() async {
    final useCase = ListInvoicesUseCase(ref.read(invoicesRepositoryProvider));
    final page = await useCase(
      filter: _overdueFilter,
      page: 1,
      pageSize: _pageSize,
    );
    return RemindersInvoiceListState(
      invoices: page.invoices,
      page: page.page,
      hasMore: page.hasMore,
    );
  }

  /// Reloads the first page (pull-to-refresh).
  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetchFirstPage);
  }

  /// Fetches and appends the next page. A failed load-more keeps the already
  /// loaded items intact — the user can pull-to-refresh to retry.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    final useCase = ListInvoicesUseCase(ref.read(invoicesRepositoryProvider));
    try {
      final next = await useCase(
        filter: _overdueFilter,
        page: current.page + 1,
        pageSize: _pageSize,
      );
      state = AsyncValue.data(
        current.copyWith(
          invoices: [...current.invoices, ...next.invoices],
          page: next.page,
          hasMore: next.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Exception {
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
    }
  }
}
