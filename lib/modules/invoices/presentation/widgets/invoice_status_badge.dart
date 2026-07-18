import 'package:flutter/material.dart';
import 'package:solodesk_mobile/core/theme/app_semantic_colors.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';

/// Resolved visual tokens for an invoice status: an icon plus a foreground and
/// background color, so status is signalled by icon + color, never colour alone.
class InvoiceStatusVisual {
  const InvoiceStatusVisual({
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final Color foreground;
  final Color background;
}

InvoiceStatusVisual invoiceStatusVisual(
  BuildContext context,
  InvoiceStatus status,
) {
  final scheme = Theme.of(context).colorScheme;
  final semantic = context.semanticColors;
  return switch (status) {
    InvoiceStatus.draft => InvoiceStatusVisual(
      icon: Icons.edit_note_rounded,
      foreground: scheme.onSurfaceVariant,
      background: scheme.surfaceContainerHighest,
    ),
    InvoiceStatus.sent => InvoiceStatusVisual(
      icon: Icons.send_rounded,
      foreground: semantic.info,
      background: semantic.infoContainer,
    ),
    InvoiceStatus.partiallyPaid => InvoiceStatusVisual(
      icon: Icons.incomplete_circle_rounded,
      foreground: semantic.warning,
      background: semantic.warningContainer,
    ),
    InvoiceStatus.paid => InvoiceStatusVisual(
      icon: Icons.check_circle_rounded,
      foreground: semantic.success,
      background: semantic.successContainer,
    ),
    InvoiceStatus.overdue => InvoiceStatusVisual(
      icon: Icons.warning_amber_rounded,
      foreground: scheme.error,
      background: scheme.errorContainer,
    ),
    InvoiceStatus.voided => InvoiceStatusVisual(
      icon: Icons.block_rounded,
      foreground: scheme.onSurfaceVariant,
      background: scheme.surfaceContainerHighest,
    ),
  };
}

/// A compact status chip (icon + label) for cards and the detail header.
class InvoiceStatusBadge extends StatelessWidget {
  const InvoiceStatusBadge({super.key, required this.status});

  final InvoiceStatus status;

  @override
  Widget build(BuildContext context) {
    final visual = invoiceStatusVisual(context, status);
    return Semantics(
      label: 'Trạng thái: ${status.label}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: visual.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(visual.icon, size: 14, color: visual.foreground),
            const SizedBox(width: 4),
            Text(
              status.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: visual.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
