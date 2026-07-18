import 'package:flutter/material.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/payment_method.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/money_text.dart';
import 'package:solodesk_mobile/shared/extensions/datetime_extensions.dart';

/// One recorded payment in the invoice's payment history.
class PaymentRecordTile extends StatelessWidget {
  const PaymentRecordTile({super.key, required this.payment});

  final PaymentRecord payment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle =
        '${payment.paymentMethod.label} • ${payment.paymentDate.toDisplayDate()}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.payments_outlined,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
      title: MoneyText(payment.amount, style: theme.textTheme.titleSmall),
      subtitle: Text(
        payment.referenceNote == null
            ? subtitle
            : '$subtitle\n${payment.referenceNote}',
        style: theme.textTheme.bodySmall,
      ),
      isThreeLine: payment.referenceNote != null,
    );
  }
}
