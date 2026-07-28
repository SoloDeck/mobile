import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/invoice_card.dart';
import 'package:solodesk_mobile/modules/reminders/presentation/controllers/reminders_invoice_list_controller.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/shared/widgets/error_retry_widget.dart';
import 'package:solodesk_mobile/shared/widgets/loading_shimmer.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';

/// "Nhắc thu tiền" — the list of overdue invoices the freelancer still needs
/// to chase, one tap away from composing a reminder for each.
///
/// Deliberately backed by its own [remindersInvoiceListControllerProvider]
/// rather than the shared `invoicesListControllerProvider`: that controller
/// is a singleton driving the main Invoices tab, and this screen always shows
/// a fixed `overdueOnly` filter — reusing it would let this screen mutate the
/// other tab's filter state.
class RemindersListPage extends ConsumerStatefulWidget {
  const RemindersListPage({super.key});

  @override
  ConsumerState<RemindersListPage> createState() => _RemindersListPageState();
}

class _RemindersListPageState extends ConsumerState<RemindersListPage> {
  final _scrollController = ScrollController();

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
      ref.read(remindersInvoiceListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(remindersInvoiceListControllerProvider);
    final appearance = ref.watch(appearanceControllerProvider);

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: Scaffold(
        appBar: AppBar(title: const Text('Nhắc thu tiền')),
        body: state.when(
          loading: () => const LoadingShimmer(),
          error: (error, _) => ErrorRetryWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(remindersInvoiceListControllerProvider),
          ),
          data: (data) => RefreshIndicator(
            onRefresh: () =>
                ref.read(remindersInvoiceListControllerProvider.notifier).refresh(),
            child: data.invoices.isEmpty
                ? _EmptyState(scrollController: _scrollController)
                : _ReminderInvoiceList(
                    scrollController: _scrollController,
                    state: data,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ReminderInvoiceList extends StatelessWidget {
  const _ReminderInvoiceList({
    required this.scrollController,
    required this.state,
  });

  final ScrollController scrollController;
  final RemindersInvoiceListState state;

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
          onTap: () =>
              context.push(RouteNames.reminderComposeOf(invoice.id)),
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
        const SizedBox(height: AppGap.navBarInset),
        Icon(
          Icons.task_alt_outlined,
          size: 56,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Không có hoá đơn cần nhắc',
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Mọi hoá đơn hiện đều trong hạn thanh toán.',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
