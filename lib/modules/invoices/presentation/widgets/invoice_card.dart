import 'package:flutter/material.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/invoice_status_badge.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/money_text.dart';
import 'package:solodesk_mobile/shared/extensions/datetime_extensions.dart';

/// One row in the invoices list — number, client, due date and total, with the
/// status shown as an icon-led badge and overdue invoices flagged in danger.
class InvoiceCard extends StatelessWidget {
  const InvoiceCard({super.key, required this.invoice, required this.onTap});

  final Invoice invoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = invoiceStatusVisual(context, invoice.status);
    final overdue = invoice.isOverdue;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: visual.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(visual.icon, color: visual.foreground, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      invoice.clientName ?? 'Không có khách hàng',
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _DueDate(dueDate: invoice.dueDate, overdue: overdue),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyText(invoice.total, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  InvoiceStatusBadge(status: invoice.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DueDate extends StatelessWidget {
  const _DueDate({required this.dueDate, required this.overdue});

  final DateTime dueDate;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = overdue
        ? theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          overdue ? Icons.warning_amber_rounded : Icons.event_outlined,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          'Hạn: ${dueDate.toDisplayDate()}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: overdue ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
