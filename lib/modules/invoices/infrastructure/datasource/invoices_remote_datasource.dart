import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_query.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/create_invoice_request_dto.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/invoice_response_dto.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/payment_record_dto.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/record_payment_request_dto.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/update_invoice_request_dto.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';
import 'package:solodesk_mobile/shared/models/api_response.dart';

/// One page of invoice DTOs plus the pagination cursor returned alongside them.
typedef InvoiceDtoPage = ({
  List<InvoiceResponseDto> items,
  int page,
  int totalPages,
});

class InvoicesRemoteDatasource {
  const InvoicesRemoteDatasource(this._client);

  final ApiClient _client;

  Future<InvoiceDtoPage> listInvoices({
    InvoiceListFilter filter = const InvoiceListFilter(),
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.invoices,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (filter.status != null) 'status': filter.status!.wireValue,
        if (filter.overdueOnly) 'overdue_only': true,
      },
    );
    final body = response.data!;
    final items = (body['data'] as List<dynamic>)
        .map((e) => InvoiceResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = body['pagination'] as Map<String, dynamic>?;
    final currentPage = (pagination?['page'] as num?)?.toInt() ?? page;
    final totalPages =
        (pagination?['total_pages'] as num?)?.toInt() ?? currentPage;
    return (items: items, page: currentPage, totalPages: totalPages);
  }

  Future<InvoiceResponseDto> getInvoice(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.invoiceById(id),
    );
    return _unwrapInvoice(response.data!);
  }

  Future<InvoiceResponseDto> createInvoice(
    CreateInvoiceRequestDto request,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.invoices,
      data: request.toJson(),
    );
    return _unwrapInvoice(response.data!);
  }

  Future<InvoiceResponseDto> updateInvoice(
    String id,
    UpdateInvoiceRequestDto request,
  ) async {
    final response = await _client.patch<Map<String, dynamic>>(
      ApiEndpoints.invoiceById(id),
      data: request.toJson(),
    );
    return _unwrapInvoice(response.data!);
  }

  Future<InvoiceResponseDto> sendInvoice(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.invoiceSend(id),
    );
    return _unwrapInvoice(response.data!);
  }

  Future<InvoiceResponseDto> voidInvoice(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.invoiceVoid(id),
    );
    return _unwrapInvoice(response.data!);
  }

  Future<List<PaymentRecordDto>> listPayments(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.invoicePayments(id),
    );
    final items = response.data!['data'] as List<dynamic>;
    return items
        .map((e) => PaymentRecordDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Records a payment and returns the **updated invoice** (not the payment
  /// record — the backend echoes the recalculated invoice).
  Future<InvoiceResponseDto> recordPayment(
    String id,
    RecordPaymentRequestDto request,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.invoicePayments(id),
      data: request.toJson(),
    );
    return _unwrapInvoice(response.data!);
  }

  InvoiceResponseDto _unwrapInvoice(Map<String, dynamic> body) {
    final envelope = ApiResponse.fromJson(
      body,
      (json) => InvoiceResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }
}
