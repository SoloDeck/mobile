import 'package:flutter/material.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/money.dart';
import 'package:solodesk_mobile/ui/perforated_divider.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';

/// The money panel at the top of the invoice detail — the outstanding balance is
/// the hero figure, with total and amount-paid beneath it.
class InvoiceAmountSummary extends StatelessWidget {
  const InvoiceAmountSummary({super.key, required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return SlipCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Còn lại phải trả', style: AppText.sub),
          const SizedBox(height: 4),
          Money.hero(invoice.amountOutstanding, tone: Tone.money),
          const PerforatedDivider(),
          _Row(
            label: 'Tổng cộng',
            child: Money.card(invoice.total, tone: Tone.neutral),
          ),
          const SizedBox(height: 8),
          _Row(
            label: 'Đã thanh toán',
            child: Money.card(
              invoice.amountPaid,
              tone: invoice.amountPaid > 0 ? Tone.ok : Tone.neutral,
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
      children: [Text(label, style: AppText.body), child],
    );
  }
}
