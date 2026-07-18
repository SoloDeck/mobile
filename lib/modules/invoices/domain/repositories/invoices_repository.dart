import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_query.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/payment_method.dart';

/// Contract for reading and mutating invoices. Implemented in
/// `infrastructure/repository/invoices_repository_impl.dart`.
abstract interface class InvoicesRepository {
  Future<InvoiceListPage> listInvoices({
    InvoiceListFilter filter,
    int page,
    int pageSize,
  });

  Future<Invoice> getInvoice(String id);

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
    List<LineItemInput> lineItems,
  });

  Future<Invoice> updateInvoice({
    required String id,
    double? subtotal,
    DateTime? dueDate,
    double? taxRate,
    String? notes,
    List<LineItemInput>? lineItems,
  });

  Future<Invoice> sendInvoice(String id);

  Future<Invoice> voidInvoice(String id);

  Future<List<PaymentRecord>> listPayments(String id);

  Future<Invoice> recordPayment({
    required String id,
    required double amount,
    required DateTime paymentDate,
    PaymentMethod? paymentMethod,
    String? referenceNote,
  });
}

/// A line item as entered on the create/edit form — the backend computes
/// `amount` server-side, so only the inputs are sent.
class LineItemInput {
  const LineItemInput({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.sortOrder,
  });

  final String description;
  final double quantity;
  final double unitPrice;
  final int? sortOrder;

  double get amount => quantity * unitPrice;
}
