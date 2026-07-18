import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_query.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/controllers/invoices_list_controller.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/invoice_card.dart';
import 'package:solodesk_mobile/shared/widgets/error_retry_widget.dart';
import 'package:solodesk_mobile/shared/widgets/loading_shimmer.dart';

/// The "Hóa đơn" tab — a filterable, paginated list of the freelancer's
/// invoices.
class InvoicesPage extends ConsumerStatefulWidget {
  const InvoicesPage({super.key});

  @override
  ConsumerState<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends ConsumerState<InvoicesPage> {
  final _scrollController = ScrollController();

  static const _filters = <({String label, InvoiceListFilter filter})>[
    (label: 'Tất cả', filter: InvoiceListFilter()),
    (label: 'Quá hạn', filter: InvoiceListFilter(overdueOnly: true)),
    (label: 'Nháp', filter: InvoiceListFilter(status: InvoiceStatus.draft)),
    (label: 'Đã gửi', filter: InvoiceListFilter(status: InvoiceStatus.sent)),
    (
      label: 'Đã thanh toán',
      filter: InvoiceListFilter(status: InvoiceStatus.paid),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 240) {
      ref.read(invoicesListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invoicesListControllerProvider);
    final activeFilter = state.value?.filter ?? const InvoiceListFilter();

    return Scaffold(
      appBar: AppBar(title: const Text('Hóa đơn')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('${RouteNames.invoices}/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tạo hóa đơn'),
      ),
      body: Column(
        children: [
          _FilterBar(
            filters: _filters,
            active: activeFilter,
            onSelected: (filter) => ref
                .read(invoicesListControllerProvider.notifier)
                .setFilter(filter),
          ),
          Expanded(
            child: state.when(
              loading: () => const LoadingShimmer(),
              error: (error, _) => ErrorRetryWidget(
                message: error.toString(),
                onRetry: () => ref.invalidate(invoicesListControllerProvider),
              ),
              data: (data) => RefreshIndicator(
                onRefresh: () =>
                    ref.read(invoicesListControllerProvider.notifier).refresh(),
                child: data.invoices.isEmpty
                    ? _EmptyState(scrollController: _scrollController)
                    : _InvoiceList(
                        scrollController: _scrollController,
                        state: data,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filters,
    required this.active,
    required this.onSelected,
  });

  final List<({String label, InvoiceListFilter filter})> filters;
  final InvoiceListFilter active;
  final ValueChanged<InvoiceListFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = filters[index];
          return ChoiceChip(
            label: Text(entry.label),
            selected: entry.filter == active,
            onSelected: (_) => onSelected(entry.filter),
          );
        },
      ),
    );
  }
}

class _InvoiceList extends StatelessWidget {
  const _InvoiceList({required this.scrollController, required this.state});

  final ScrollController scrollController;
  final InvoiceListState state;

  @override
  Widget build(BuildContext context) {
    final showFooter = state.isLoadingMore;
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.invoices.length + (showFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.invoices.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final invoice = state.invoices[index];
        return InvoiceCard(
          invoice: invoice,
          onTap: () => context.push('${RouteNames.invoices}/${invoice.id}'),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      controller: scrollController,
      children: [
        const SizedBox(height: 120),
        Icon(
          Icons.receipt_long_outlined,
          size: 56,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Center(
          child: Text('Chưa có hóa đơn', style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Tạo hóa đơn đầu tiên từ một thương vụ',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
