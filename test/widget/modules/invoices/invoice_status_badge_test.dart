import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/invoice_status_badge.dart';

void main() {
  testWidgets('shows the vi label and an icon (status not by colour alone)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const Scaffold(
          body: InvoiceStatusBadge(status: InvoiceStatus.overdue),
        ),
      ),
    );

    expect(find.text('Quá hạn'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });

  testWidgets('exposes a semantics label for accessibility', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const Scaffold(
          body: InvoiceStatusBadge(status: InvoiceStatus.paid),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(RegExp('Trạng thái: Đã thanh toán')),
      findsOneWidget,
    );
    handle.dispose();
  });
}
