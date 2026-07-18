import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/repositories/invoices_repository.dart';

/// Voids an invoice. The backend rejects voiding a paid / partially-paid invoice
/// with 409; the detail page only offers the action when [InvoiceStatusX.canVoid]
/// allows it.
class VoidInvoiceUseCase {
  const VoidInvoiceUseCase(this._repository);

  final InvoicesRepository _repository;

  Future<Invoice> call(String id) => _repository.voidInvoice(id);
}
