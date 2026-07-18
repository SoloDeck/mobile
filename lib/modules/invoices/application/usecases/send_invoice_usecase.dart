import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/repositories/invoices_repository.dart';

class SendInvoiceUseCase {
  const SendInvoiceUseCase(this._repository);

  final InvoicesRepository _repository;

  Future<Invoice> call(String id) => _repository.sendInvoice(id);
}
