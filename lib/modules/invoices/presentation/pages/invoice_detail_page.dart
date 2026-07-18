import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/controllers/invoice_detail_controller.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/providers/invoices_provider.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/invoice_amount_summary.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/invoice_status_badge.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/money_text.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/payment_record_tile.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/record_payment_sheet.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';
import 'package:solodesk_mobile/shared/extensions/context_extensions.dart';
import 'package:solodesk_mobile/shared/extensions/datetime_extensions.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';

/// Invoice detail — money summary, line items, payment history and the
/// status-driven actions (edit / send / record payment / void).
class InvoiceDetailPage extends ConsumerWidget {
  const InvoiceDetailPage({super.key, required this.invoiceId});

  final String invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoice = ref.watch(invoiceDetailProvider(invoiceId));

    ref.listen(invoiceDetailControllerProvider, (previous, next) {
      if (next.hasError) {
        final error = next.error;
        context.showSnackBar(
          error is AppException ? error.message : 'Đã xảy ra lỗi',
          isError: true,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết hóa đơn')),
      body: AsyncValueWidget<Invoice>(
        value: invoice,
        onRetry: () => ref.invalidate(invoiceDetailProvider(invoiceId)),
        data: (d) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    d.invoiceNumber,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                InvoiceStatusBadge(status: d.status),
              ],
            ),
            const SizedBox(height: 16),
            InvoiceAmountSummary(invoice: d),
            const SizedBox(height: 24),
            _MetaSection(invoice: d),
            const SizedBox(height: 24),
            _LineItemsSection(invoice: d),
            const SizedBox(height: 24),
            _PaymentsSection(invoiceId: invoiceId),
          ],
        ),
      ),
      bottomNavigationBar: invoice.maybeWhen(
        data: (d) => _ActionBar(invoice: d),
        orElse: () => null,
      ),
    );
  }
}

class _MetaSection extends StatelessWidget {
  const _MetaSection({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetaRow(
          label: 'Khách hàng',
          value: invoice.clientName ?? invoice.clientId,
        ),
        _MetaRow(label: 'Ngày lập', value: invoice.issueDate.toDisplayDate()),
        _MetaRow(
          label: 'Hạn thanh toán',
          value: invoice.dueDate.toDisplayDate(),
          emphasize: invoice.isOverdue,
        ),
        if (invoice.notes != null && invoice.notes!.isNotEmpty)
          _MetaRow(label: 'Ghi chú', value: invoice.notes!),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: emphasize ? theme.colorScheme.error : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineItemsSection extends StatelessWidget {
  const _LineItemsSection({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hạng mục', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (invoice.lineItems.isEmpty)
          Text('Không có hạng mục', style: theme.textTheme.bodySmall)
        else
          for (final item in invoice.lineItems)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          '${_qty(item.quantity)} × ${_qty(item.unitPrice)}₫',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  MoneyText(item.amount, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
        const Divider(height: 24),
        _TotalsRow(label: 'Tạm tính', value: invoice.subtotal),
        if (invoice.taxAmount > 0)
          _TotalsRow(
            label: 'Thuế (${(invoice.taxRate * 100).toStringAsFixed(0)}%)',
            value: invoice.taxAmount,
          ),
        _TotalsRow(label: 'Tổng cộng', value: invoice.total, bold: true),
      ],
    );
  }

  static String _qty(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final double value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = bold
        ? theme.textTheme.titleMedium
        : theme.textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          MoneyText(value, style: style),
        ],
      ),
    );
  }
}

class _PaymentsSection extends ConsumerWidget {
  const _PaymentsSection({required this.invoiceId});

  final String invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final payments = ref.watch(invoicePaymentsProvider(invoiceId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lịch sử thanh toán', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        payments.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Text(
            'Không tải được lịch sử thanh toán',
            style: theme.textTheme.bodySmall,
          ),
          data: (records) => records.isEmpty
              ? Text('Chưa có thanh toán', style: theme.textTheme.bodySmall)
              : Column(
                  children: [
                    for (final record in records)
                      PaymentRecordTile(payment: record),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.invoice});

  final Invoice invoice;

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Huỷ bỏ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: destructive
                ? TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _send(BuildContext context, WidgetRef ref) async {
    final ok = await _confirm(
      context,
      title: 'Gửi hóa đơn',
      message: 'Gửi hóa đơn ${invoice.invoiceNumber} cho khách hàng?',
      confirmLabel: 'Gửi',
    );
    if (!ok) return;
    final result = await ref
        .read(invoiceDetailControllerProvider.notifier)
        .send(invoice.id);
    if (result != null && context.mounted) {
      context.showSnackBar('Đã gửi hóa đơn');
    }
  }

  Future<void> _void(BuildContext context, WidgetRef ref) async {
    final isDraft = invoice.status.isDraft;
    final ok = await _confirm(
      context,
      title: isDraft ? 'Xoá hóa đơn' : 'Huỷ hóa đơn',
      message: isDraft
          ? 'Xoá bản nháp ${invoice.invoiceNumber}? Không thể khôi phục.'
          : 'Huỷ hóa đơn ${invoice.invoiceNumber}? Không thể khôi phục.',
      confirmLabel: isDraft ? 'Xoá' : 'Huỷ hóa đơn',
      destructive: true,
    );
    if (!ok) return;
    final result = await ref
        .read(invoiceDetailControllerProvider.notifier)
        .voidInvoice(invoice.id);
    if (result != null && context.mounted) {
      context.showSnackBar('Đã huỷ hóa đơn');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isBusy = ref.watch(invoiceDetailControllerProvider).isLoading;

    final primaryRow = <Widget>[];
    if (invoice.canEdit) {
      primaryRow.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isBusy
                ? null
                : () =>
                      context.push('${RouteNames.invoices}/${invoice.id}/edit'),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Sửa'),
          ),
        ),
      );
    }
    if (invoice.canSend) {
      if (primaryRow.isNotEmpty) primaryRow.add(const SizedBox(width: 12));
      primaryRow.add(
        Expanded(
          child: FilledButton.icon(
            onPressed: isBusy ? null : () => _send(context, ref),
            icon: const Icon(Icons.send_rounded),
            label: const Text('Gửi hóa đơn'),
          ),
        ),
      );
    }
    if (invoice.canRecordPayment) {
      primaryRow.add(
        Expanded(
          child: FilledButton.icon(
            onPressed: isBusy
                ? null
                : () => RecordPaymentSheet.show(context, invoice),
            icon: const Icon(Icons.payments_outlined),
            label: const Text('Ghi nhận thanh toán'),
          ),
        ),
      );
    }

    if (primaryRow.isEmpty && !invoice.canVoid) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (primaryRow.isNotEmpty) Row(children: primaryRow),
            if (invoice.canVoid) ...[
              if (primaryRow.isNotEmpty) const SizedBox(height: 4),
              TextButton.icon(
                onPressed: isBusy ? null : () => _void(context, ref),
                icon: const Icon(Icons.block_rounded),
                label: Text(
                  invoice.status.isDraft ? 'Xoá hóa đơn' : 'Huỷ hóa đơn',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
