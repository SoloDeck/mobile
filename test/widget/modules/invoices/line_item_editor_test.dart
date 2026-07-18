import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/invoices/domain/repositories/invoices_repository.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/line_item_editor.dart';

void main() {
  testWidgets('computes the line amount and emits the entered items', (
    tester,
  ) async {
    var latest = <LineItemInput>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LineItemEditor(
              initialItems: const [],
              onChanged: (items) => latest = items,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Mô tả'),
      'Thiết kế logo',
    );
    await tester.enterText(find.widgetWithText(TextField, 'SL'), '2');
    await tester.enterText(
      find.widgetWithText(TextField, 'Đơn giá (₫)'),
      '1000',
    );
    await tester.pump();

    expect(latest, hasLength(1));
    expect(latest.single.description, 'Thiết kế logo');
    expect(latest.single.quantity, 2);
    expect(latest.single.unitPrice, 1000);
    expect(latest.single.amount, 2000);
  });

  testWidgets('adds a second row on "Thêm hạng mục"', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LineItemEditor(initialItems: const [], onChanged: (_) {}),
          ),
        ),
      ),
    );

    expect(find.widgetWithText(TextField, 'Mô tả'), findsOneWidget);
    await tester.tap(find.text('Thêm hạng mục'));
    await tester.pump();
    expect(find.widgetWithText(TextField, 'Mô tả'), findsNWidgets(2));
  });
}
