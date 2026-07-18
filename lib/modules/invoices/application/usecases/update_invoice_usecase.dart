import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/repositories/invoices_repository.dart';

/// Updates a draft invoice. Editing is only offered while the invoice is a
/// draft (the detail page hides the action otherwise); the backend also guards
/// this and returns 409 for non-draft edits.
class UpdateInvoiceUseCase {
  const UpdateInvoiceUseCase(this._repository);

  final InvoicesRepository _repository;

  Future<Invoice> call({
    required String id,
    double? subtotal,
    DateTime? dueDate,
    double? taxRate,
    String? notes,
    List<LineItemInput>? lineItems,
  }) => _repository.updateInvoice(
    id: id,
    subtotal: subtotal,
    dueDate: dueDate,
    taxRate: taxRate,
    notes: notes,
    lineItems: lineItems,
  );
}
