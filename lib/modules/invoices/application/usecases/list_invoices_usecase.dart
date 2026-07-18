import 'package:solodesk_mobile/modules/invoices/domain/repositories/invoices_repository.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_query.dart';

class ListInvoicesUseCase {
  const ListInvoicesUseCase(this._repository);

  final InvoicesRepository _repository;

  Future<InvoiceListPage> call({
    InvoiceListFilter filter = const InvoiceListFilter(),
    int page = 1,
    int pageSize = 20,
  }) =>
      _repository.listInvoices(filter: filter, page: page, pageSize: pageSize);
}
