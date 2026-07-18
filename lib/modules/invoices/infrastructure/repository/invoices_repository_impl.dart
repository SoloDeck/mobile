import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/repositories/invoices_repository.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_query.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/payment_method.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/datasource/invoices_local_datasource.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/datasource/invoices_remote_datasource.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/create_invoice_request_dto.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/record_payment_request_dto.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/update_invoice_request_dto.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/mapper/invoice_mapper.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

part 'invoices_repository_impl.g.dart';

class InvoicesRepositoryImpl implements InvoicesRepository {
  const InvoicesRepositoryImpl(this._remote, this._local);

  final InvoicesRemoteDatasource _remote;
  final InvoicesLocalDatasource _local;

  @override
  Future<InvoiceListPage> listInvoices({
    InvoiceListFilter filter = const InvoiceListFilter(),
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final result = await _remote.listInvoices(
        filter: filter,
        page: page,
        pageSize: pageSize,
      );
      final invoices = result.items.map((dto) => dto.toDomain()).toList();
      // Only the first page seeds the offline cache — later pages append to the
      // live list but do not replace the cached summary set.
      if (page == 1) {
        await _local.upsertInvoices(invoices);
      }
      return InvoiceListPage(
        invoices: invoices,
        page: result.page,
        hasMore: result.page < result.totalPages,
      );
    } on NetworkException {
      if (page > 1) rethrow;
      final cached = await _local.listInvoices(filter: filter);
      return InvoiceListPage(invoices: cached, page: 1, hasMore: false);
    }
  }

  @override
  Future<Invoice> getInvoice(String id) async {
    final dto = await _remote.getInvoice(id);
    final invoice = dto.toDomain();
    await _local.upsertInvoices([invoice]);
    return invoice;
  }

  @override
  Future<Invoice> createInvoice({
    required String clientId,
    String? contractId,
    String? dealId,
    DateTime? issueDate,
    required DateTime dueDate,
    String? currency,
    double? subtotal,
    double? taxRate,
    String? notes,
    List<LineItemInput> lineItems = const [],
  }) async {
    final dto = await _remote.createInvoice(
      CreateInvoiceRequestDto(
        clientId: clientId,
        contractId: contractId,
        dealId: dealId,
        issueDate: issueDate == null ? null : _dateOnly(issueDate),
        dueDate: _dateOnly(dueDate),
        currency: currency,
        subtotal: subtotal,
        taxRate: taxRate,
        notes: notes,
        lineItems: lineItems.isEmpty
            ? null
            : lineItems.map(_toInputDto).toList(),
      ),
    );
    final invoice = dto.toDomain();
    await _local.upsertInvoices([invoice]);
    return invoice;
  }

  @override
  Future<Invoice> updateInvoice({
    required String id,
    double? subtotal,
    DateTime? dueDate,
    double? taxRate,
    String? notes,
    List<LineItemInput>? lineItems,
  }) async {
    final dto = await _remote.updateInvoice(
      id,
      UpdateInvoiceRequestDto(
        subtotal: subtotal,
        dueDate: dueDate == null ? null : _dateOnly(dueDate),
        taxRate: taxRate,
        notes: notes,
        lineItems: lineItems?.map(_toInputDto).toList(),
      ),
    );
    final invoice = dto.toDomain();
    await _local.upsertInvoices([invoice]);
    return invoice;
  }

  @override
  Future<Invoice> sendInvoice(String id) async {
    final invoice = (await _remote.sendInvoice(id)).toDomain();
    await _local.upsertInvoices([invoice]);
    return invoice;
  }

  @override
  Future<Invoice> voidInvoice(String id) async {
    final invoice = (await _remote.voidInvoice(id)).toDomain();
    await _local.upsertInvoices([invoice]);
    return invoice;
  }

  @override
  Future<List<PaymentRecord>> listPayments(String id) async {
    final dtos = await _remote.listPayments(id);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<Invoice> recordPayment({
    required String id,
    required double amount,
    required DateTime paymentDate,
    PaymentMethod? paymentMethod,
    String? referenceNote,
  }) async {
    final dto = await _remote.recordPayment(
      id,
      RecordPaymentRequestDto(
        amount: amount,
        paymentDate: _dateOnly(paymentDate),
        paymentMethod: paymentMethod,
        referenceNote: referenceNote,
      ),
    );
    final invoice = dto.toDomain();
    await _local.upsertInvoices([invoice]);
    return invoice;
  }

  LineItemInputDto _toInputDto(LineItemInput input) => LineItemInputDto(
    description: input.description,
    quantity: input.quantity,
    unitPrice: input.unitPrice,
    sortOrder: input.sortOrder,
  );

  /// The backend `date` fields expect `YYYY-MM-DD`, not a full timestamp.
  String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

@Riverpod(keepAlive: true)
InvoicesRepository invoicesRepository(Ref ref) {
  final client = ref.read(apiClientProvider);
  final database = ref.read(appDatabaseProvider);
  return InvoicesRepositoryImpl(
    InvoicesRemoteDatasource(client),
    InvoicesLocalDatasource(database),
  );
}
