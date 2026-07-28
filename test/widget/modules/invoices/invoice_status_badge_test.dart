import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/invoice_status_badge.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

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
    // Icons in this app are drawn with the custom SoloIcon vector set, not
    // Flutter's Material `Icon`/`IconData` — see lib/ui/solo_icons.dart.
    expect(
      find.byWidgetPredicate(
        (widget) => widget is SoloIcon && widget.icon == SoloIcons.clock,
      ),
      findsOneWidget,
    );
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
