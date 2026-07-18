import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';

void main() {
  group('InvoiceStatus wire values', () {
    test('map to the backend snake_case strings', () {
      expect(InvoiceStatus.draft.wireValue, 'draft');
      expect(InvoiceStatus.sent.wireValue, 'sent');
      expect(InvoiceStatus.partiallyPaid.wireValue, 'partially_paid');
      expect(InvoiceStatus.paid.wireValue, 'paid');
      expect(InvoiceStatus.overdue.wireValue, 'overdue');
      expect(InvoiceStatus.voided.wireValue, 'void');
    });

    test('invoiceStatusFromWire round-trips every value', () {
      for (final status in InvoiceStatus.values) {
        expect(invoiceStatusFromWire(status.wireValue), status);
      }
    });

    test('invoiceStatusFromWire throws on an unknown value', () {
      expect(() => invoiceStatusFromWire('archived'), throwsArgumentError);
    });
  });

  group('InvoiceStatus capabilities', () {
    test('only a draft can be edited/sent', () {
      expect(InvoiceStatus.draft.isDraft, isTrue);
      expect(InvoiceStatus.sent.isDraft, isFalse);
    });

    test('void is blocked once a payment exists or already voided', () {
      expect(InvoiceStatus.draft.canVoid, isTrue);
      expect(InvoiceStatus.sent.canVoid, isTrue);
      expect(InvoiceStatus.overdue.canVoid, isTrue);
      expect(InvoiceStatus.partiallyPaid.canVoid, isFalse);
      expect(InvoiceStatus.paid.canVoid, isFalse);
      expect(InvoiceStatus.voided.canVoid, isFalse);
    });

    test('payment can be recorded only on live sent invoices', () {
      expect(InvoiceStatus.sent.canRecordPayment, isTrue);
      expect(InvoiceStatus.partiallyPaid.canRecordPayment, isTrue);
      expect(InvoiceStatus.overdue.canRecordPayment, isTrue);
      expect(InvoiceStatus.draft.canRecordPayment, isFalse);
      expect(InvoiceStatus.paid.canRecordPayment, isFalse);
      expect(InvoiceStatus.voided.canRecordPayment, isFalse);
    });

    test('paid and voided are terminal', () {
      expect(InvoiceStatus.paid.isTerminal, isTrue);
      expect(InvoiceStatus.voided.isTerminal, isTrue);
      expect(InvoiceStatus.sent.isTerminal, isFalse);
    });
  });
}
