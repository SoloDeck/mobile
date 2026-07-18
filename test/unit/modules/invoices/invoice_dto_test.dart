import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/payment_method.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/create_invoice_request_dto.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/invoice_response_dto.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/payment_record_dto.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/record_payment_request_dto.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/update_invoice_request_dto.dart';

void main() {
  group('InvoiceResponseDto.fromJson', () {
    test('parses a full invoice with line items and null contract/deal', () {
      final dto = InvoiceResponseDto.fromJson({
        'id': 'inv-1',
        'owner_user_id': 'owner-1',
        'client_id': 'client-1',
        'client_name': 'Công ty ABC',
        'contract_id': null,
        'deal_id': 'deal-1',
        'invoice_number': 'INV-2026-0042',
        'status': 'partially_paid',
        'issue_date': '2026-07-01',
        'due_date': '2026-07-15',
        'currency': 'VND',
        'subtotal': 10000000,
        'tax_rate': 0.1,
        'tax_amount': 1000000,
        'total': 11000000,
        'amount_paid': 4000000,
        'amount_outstanding': 7000000,
        'notes': 'Đợt 1',
        'line_items': [
          {
            'description': 'Thiết kế',
            'quantity': 2,
            'unit_price': 5000000,
            'amount': 10000000,
            'sort_order': 0,
          },
        ],
        'sent_at': '2026-07-01T09:00:00Z',
        'voided_at': null,
        'created_at': '2026-07-01T08:00:00Z',
        'updated_at': '2026-07-02T08:00:00Z',
      });

      expect(dto.status, InvoiceStatus.partiallyPaid);
      expect(dto.contractId, isNull);
      expect(dto.dealId, 'deal-1');
      expect(dto.total, 11000000);
      expect(dto.amountOutstanding, 7000000);
      expect(dto.lineItems.single.amount, 10000000);
      expect(dto.lineItems.single.sortOrder, 0);
    });

    test('parses Decimal money sent as a JSON string', () {
      final dto = InvoiceResponseDto.fromJson({
        'id': 'inv-2',
        'owner_user_id': 'owner-1',
        'client_id': 'client-1',
        'invoice_number': 'INV-2026-0043',
        'status': 'draft',
        'issue_date': '2026-07-01',
        'due_date': '2026-07-15',
        'total': '2500000.50',
        'created_at': '2026-07-01T08:00:00Z',
      });

      expect(dto.total, 2500000.50);
      // Absent optional money fields default to 0.
      expect(dto.amountOutstanding, 0);
      expect(dto.taxRate, 0);
      expect(dto.lineItems, isEmpty);
      expect(dto.currency, 'VND');
    });

    test('maps the void status keyword', () {
      final dto = InvoiceResponseDto.fromJson({
        'id': 'inv-3',
        'owner_user_id': 'owner-1',
        'client_id': 'client-1',
        'invoice_number': 'INV-2026-0044',
        'status': 'void',
        'issue_date': '2026-07-01',
        'due_date': '2026-07-15',
        'total': 0,
        'created_at': '2026-07-01T08:00:00Z',
      });
      expect(dto.status, InvoiceStatus.voided);
    });
  });

  group('PaymentRecordDto.fromJson', () {
    test('parses a payment record with the enum method', () {
      final dto = PaymentRecordDto.fromJson({
        'id': 'pay-1',
        'invoice_id': 'inv-1',
        'amount': 4000000,
        'payment_date': '2026-07-05',
        'payment_method': 'bank_transfer',
        'reference_note': 'Chuyển khoản Vietcombank',
        'created_at': '2026-07-05T10:00:00Z',
      });

      expect(dto.amount, 4000000);
      expect(dto.paymentMethod, PaymentMethod.bankTransfer);
      expect(dto.referenceNote, 'Chuyển khoản Vietcombank');
    });
  });

  group('Request DTO toJson', () {
    test('CreateInvoiceRequestDto omits null fields and nests line items', () {
      final json = const CreateInvoiceRequestDto(
        clientId: 'client-1',
        dueDate: '2026-07-15',
        dealId: 'deal-1',
        taxRate: 0.1,
        lineItems: [
          LineItemInputDto(
            description: 'Thiết kế',
            quantity: 2,
            unitPrice: 5000000,
            sortOrder: 0,
          ),
        ],
      ).toJson();

      expect(json['client_id'], 'client-1');
      expect(json['due_date'], '2026-07-15');
      expect(json['deal_id'], 'deal-1');
      expect(json['tax_rate'], 0.1);
      expect(json.containsKey('contract_id'), isFalse);
      expect(json.containsKey('subtotal'), isFalse);
      final items = json['line_items'] as List<dynamic>;
      final item = items.single as Map<String, dynamic>;
      expect(item['unit_price'], 5000000);
      expect(item.containsKey('amount'), isFalse);
    });

    test('UpdateInvoiceRequestDto sends only provided fields', () {
      final json = const UpdateInvoiceRequestDto(taxRate: 0.08).toJson();
      expect(json['tax_rate'], 0.08);
      expect(json.containsKey('subtotal'), isFalse);
      expect(json.containsKey('line_items'), isFalse);
      expect(json.containsKey('due_date'), isFalse);
    });

    test('RecordPaymentRequestDto serializes the method enum', () {
      final json = const RecordPaymentRequestDto(
        amount: 1000000,
        paymentDate: '2026-07-05',
        paymentMethod: PaymentMethod.cash,
      ).toJson();
      expect(json['amount'], 1000000);
      expect(json['payment_method'], 'cash');
      expect(json.containsKey('reference_note'), isFalse);
    });
  });
}
