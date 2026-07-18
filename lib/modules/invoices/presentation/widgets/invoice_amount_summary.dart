import 'package:flutter/material.dart';
import 'package:solodesk_mobile/core/theme/app_semantic_colors.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/money_text.dart';

/// The money panel at the top of the invoice detail — the outstanding balance is
/// the hero figure, with total and amount-paid beneath it.
class InvoiceAmountSummary extends StatelessWidget {
  const InvoiceAmountSummary({super.key, required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final outstandingColor = invoice.isOverdue ? scheme.error : scheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Còn lại phải trả', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          MoneyText(
            invoice.amountOutstanding,
            style: theme.textTheme.headlineMedium,
            color: outstandingColor,
          ),
          const Divider(height: 28),
          _Row(
            label: 'Tổng cộng',
            child: MoneyText(invoice.total, style: theme.textTheme.titleSmall),
          ),
          const SizedBox(height: 8),
          _Row(
            label: 'Đã thanh toán',
            child: MoneyText(
              invoice.amountPaid,
              style: theme.textTheme.titleSmall,
              color: invoice.amountPaid > 0
                  ? context.semanticColors.success
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        child,
      ],
    );
  }
}
