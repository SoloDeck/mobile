import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_query.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/datasource/invoices_remote_datasource.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/create_invoice_request_dto.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/record_payment_request_dto.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  late _MockApiClient client;
  late InvoicesRemoteDatasource datasource;

  setUp(() {
    client = _MockApiClient();
    datasource = InvoicesRemoteDatasource(client);
  });

  Map<String, dynamic> invoiceJson(String id) => {
    'id': id,
    'owner_user_id': 'owner-1',
    'client_id': 'client-1',
    'invoice_number': 'INV-2026-0042',
    'status': 'draft',
    'issue_date': '2026-07-01',
    'due_date': '2026-07-15',
    'total': 11000000,
    'amount_outstanding': 11000000,
    'created_at': '2026-07-01T08:00:00Z',
  };

  Response<Map<String, dynamic>> resp(Map<String, dynamic> data) =>
      Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: ApiEndpoints.invoices),
        data: {
          'success': true,
          'code': 200,
          'timestamp': '2026-07-01T08:00:00Z',
          ...data,
        },
      );

  test(
    'listInvoices sends filter + pagination params and reads pagination',
    () async {
      when(
        () => client.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => resp({
          'data': [invoiceJson('inv-1')],
          'pagination': {
            'total': 5,
            'page': 1,
            'page_size': 20,
            'total_pages': 3,
          },
        }),
      );

      final page = await datasource.listInvoices(
        filter: const InvoiceListFilter(
          status: InvoiceStatus.sent,
          overdueOnly: true,
        ),
        page: 1,
      );

      expect(page.items, hasLength(1));
      expect(page.totalPages, 3);

      final params =
          verify(
                () => client.get<Map<String, dynamic>>(
                  ApiEndpoints.invoices,
                  queryParameters: captureAny(named: 'queryParameters'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(params['status'], 'sent');
      expect(params['overdue_only'], true);
      expect(params['page'], 1);
      expect(params['page_size'], 20);
    },
  );

  test(
    'createInvoice POSTs the body to /invoices and unwraps the envelope',
    () async {
      when(
        () =>
            client.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => resp({'data': invoiceJson('inv-1')}));

      final result = await datasource.createInvoice(
        const CreateInvoiceRequestDto(
          clientId: 'client-1',
          dueDate: '2026-07-15',
          dealId: 'deal-1',
          lineItems: [
            LineItemInputDto(description: 'X', quantity: 1, unitPrice: 100),
          ],
        ),
      );

      expect(result.id, 'inv-1');
      final captured =
          verify(
                () => client.post<Map<String, dynamic>>(
                  ApiEndpoints.invoices,
                  data: captureAny(named: 'data'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured['client_id'], 'client-1');
      expect(captured['deal_id'], 'deal-1');
    },
  );

  test('sendInvoice hits the /send endpoint', () async {
    when(
      () => client.post<Map<String, dynamic>>(any()),
    ).thenAnswer((_) async => resp({'data': invoiceJson('inv-1')}));

    await datasource.sendInvoice('inv-1');

    verify(
      () =>
          client.post<Map<String, dynamic>>(ApiEndpoints.invoiceSend('inv-1')),
    ).called(1);
  });

  test('voidInvoice hits the /void endpoint', () async {
    when(
      () => client.post<Map<String, dynamic>>(any()),
    ).thenAnswer((_) async => resp({'data': invoiceJson('inv-1')}));

    await datasource.voidInvoice('inv-1');

    verify(
      () =>
          client.post<Map<String, dynamic>>(ApiEndpoints.invoiceVoid('inv-1')),
    ).called(1);
  });

  test(
    'recordPayment POSTs to /payments and returns the updated invoice',
    () async {
      when(
        () =>
            client.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => resp({'data': invoiceJson('inv-1')}));

      final result = await datasource.recordPayment(
        'inv-1',
        const RecordPaymentRequestDto(
          amount: 1000000,
          paymentDate: '2026-07-05',
        ),
      );

      expect(result.id, 'inv-1');
      final captured =
          verify(
                () => client.post<Map<String, dynamic>>(
                  ApiEndpoints.invoicePayments('inv-1'),
                  data: captureAny(named: 'data'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured['amount'], 1000000);
    },
  );
}
