import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/invoice_response_dto.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/mapper/invoice_mapper.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/mapper/invoice_row_mapper.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';

void main() {
  InvoiceResponseDto dto() => InvoiceResponseDto.fromJson({
    'id': 'inv-1',
    'owner_user_id': 'owner-1',
    'client_id': 'client-1',
    'client_name': 'Công ty ABC',
    'deal_id': 'deal-1',
    'invoice_number': 'INV-2026-0042',
    'status': 'sent',
    'issue_date': '2026-07-01',
    'due_date': '2026-07-15',
    'subtotal': 10000000,
    'tax_rate': 0.1,
    'tax_amount': 1000000,
    'total': 11000000,
    'amount_paid': 0,
    'amount_outstanding': 11000000,
    'line_items': [
      {
        'description': 'Thiết kế',
        'quantity': 2,
        'unit_price': 5000000,
        'amount': 10000000,
        'sort_order': 0,
      },
    ],
    'created_at': '2026-07-01T08:00:00Z',
    'updated_at': '2026-07-02T08:00:00Z',
  });

  test('InvoiceResponseDto.toDomain maps every field and parses dates', () {
    final invoice = dto().toDomain();

    expect(invoice.id, 'inv-1');
    expect(invoice.status, InvoiceStatus.sent);
    expect(invoice.clientName, 'Công ty ABC');
    expect(invoice.dealId, 'deal-1');
    expect(invoice.issueDate, DateTime.parse('2026-07-01'));
    expect(invoice.total, 11000000);
    expect(invoice.amountOutstanding, 11000000);
    expect(invoice.lineItems.single.description, 'Thiết kế');
    expect(invoice.updatedAt, DateTime.parse('2026-07-02T08:00:00Z'));
  });

  test(
    'Invoice to-row keeps the summary fields, row-to-domain restores them',
    () {
      final invoice = dto().toDomain();
      final row = invoice.toRow();
      final restored = InvoiceRow(
        id: row.id.value,
        invoiceNumber: row.invoiceNumber.value,
        status: row.status.value,
        dueDate: row.dueDate.value,
        total: row.total.value,
        amountOutstanding: row.amountOutstanding.value,
        clientName: row.clientName.value,
        updatedAt: row.updatedAt.value,
      ).toDomain();

      expect(restored.id, invoice.id);
      expect(restored.invoiceNumber, invoice.invoiceNumber);
      expect(restored.status, invoice.status);
      expect(restored.total, invoice.total);
      expect(restored.amountOutstanding, invoice.amountOutstanding);
      expect(restored.clientName, invoice.clientName);
      expect(restored.dueDate, invoice.dueDate);
    },
  );
}
