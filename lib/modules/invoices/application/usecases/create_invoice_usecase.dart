import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/repositories/invoices_repository.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

/// Creates a draft invoice. The two backend invariants that the UI can check
/// cheaply are enforced here first, so a request the backend would reject is
/// never sent: an invoice must be linked to a contract or a deal, and it must
/// have at least one line item (or an explicit subtotal).
class CreateInvoiceUseCase {
  const CreateInvoiceUseCase(this._repository);

  final InvoicesRepository _repository;

  Future<Invoice> call({
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
  }) {
    if (contractId == null && dealId == null) {
      throw const ValidationException(
        'Hóa đơn phải gắn với một hợp đồng hoặc thương vụ',
      );
    }
    if (lineItems.isEmpty && subtotal == null) {
      throw const ValidationException(
        'Cần ít nhất một hạng mục hoặc nhập tạm tính',
      );
    }
    return _repository.createInvoice(
      clientId: clientId,
      contractId: contractId,
      dealId: dealId,
      issueDate: issueDate,
      dueDate: dueDate,
      currency: currency,
      subtotal: subtotal,
      taxRate: taxRate,
      notes: notes,
      lineItems: lineItems,
    );
  }
}
