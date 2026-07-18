import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/record_payment_sheet.dart';

Invoice _invoice({double outstanding = 1000000}) => Invoice(
  id: 'inv-1',
  ownerUserId: 'owner-1',
  clientId: 'client-1',
  invoiceNumber: 'INV-2026-0042',
  status: InvoiceStatus.sent,
  issueDate: DateTime.utc(2026, 7, 1),
  dueDate: DateTime.utc(2026, 7, 15),
  total: outstanding,
  createdAt: DateTime.utc(2026, 7, 1),
  amountOutstanding: outstanding,
);

void main() {
  testWidgets('blocks a payment above the outstanding balance inline', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: RecordPaymentSheet(invoice: _invoice())),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Số tiền (₫) *'),
      '2000000',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Ghi nhận'));
    await tester.pump();

    expect(find.textContaining('Vượt quá số còn lại'), findsOneWidget);
  });
}
