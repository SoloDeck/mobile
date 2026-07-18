import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/invoices/application/usecases/list_invoices_usecase.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_query.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/repository/invoices_repository_impl.dart';

part 'invoices_list_controller.g.dart';

const _pageSize = 20;

/// Accumulated state for the paginated, filterable invoices list.
@immutable
class InvoiceListState {
  const InvoiceListState({
    required this.invoices,
    required this.filter,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<Invoice> invoices;
  final InvoiceListFilter filter;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  InvoiceListState copyWith({
    List<Invoice>? invoices,
    InvoiceListFilter? filter,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) => InvoiceListState(
    invoices: invoices ?? this.invoices,
    filter: filter ?? this.filter,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

/// Drives the invoices list: initial load, filter switching, pull-to-refresh and
/// infinite scroll (load-more appends the next page).
@riverpod
class InvoicesListController extends _$InvoicesListController {
  @override
  Future<InvoiceListState> build() =>
      _fetchFirstPage(const InvoiceListFilter());

  Future<InvoiceListState> _fetchFirstPage(InvoiceListFilter filter) async {
    final useCase = ListInvoicesUseCase(ref.read(invoicesRepositoryProvider));
    final page = await useCase(filter: filter, page: 1, pageSize: _pageSize);
    return InvoiceListState(
      invoices: page.invoices,
      filter: filter,
      page: page.page,
      hasMore: page.hasMore,
    );
  }

  /// Applies a new filter and reloads from the first page.
  Future<void> setFilter(InvoiceListFilter filter) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchFirstPage(filter));
  }

  /// Reloads the first page keeping the current filter (pull-to-refresh).
  Future<void> refresh() async {
    final filter = state.value?.filter ?? const InvoiceListFilter();
    state = await AsyncValue.guard(() => _fetchFirstPage(filter));
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
        filter: current.filter,
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
