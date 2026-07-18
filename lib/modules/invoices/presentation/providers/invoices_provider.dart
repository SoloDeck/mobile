import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/invoices/application/usecases/get_invoice_usecase.dart';
import 'package:solodesk_mobile/modules/invoices/application/usecases/list_invoices_usecase.dart';
import 'package:solodesk_mobile/modules/invoices/application/usecases/list_payments_usecase.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/repository/invoices_repository_impl.dart';

part 'invoices_provider.g.dart';

/// A single invoice by id (with line items), used by the detail page.
@riverpod
Future<Invoice> invoiceDetail(Ref ref, String id) {
  final useCase = GetInvoiceUseCase(ref.watch(invoicesRepositoryProvider));
  return useCase(id);
}

/// The payment history for one invoice.
@riverpod
Future<List<PaymentRecord>> invoicePayments(Ref ref, String id) {
  final useCase = ListPaymentsUseCase(ref.watch(invoicesRepositoryProvider));
  return useCase(id);
}

/// Invoices linked to a given deal — backs the deal-detail "Hóa đơn" section.
///
/// The list endpoint has no server-side `deal_id` filter, so a page is fetched
/// and filtered client-side. Adequate for a freelancer's dataset in v1.
@riverpod
Future<List<Invoice>> dealInvoices(Ref ref, String dealId) async {
  final useCase = ListInvoicesUseCase(ref.watch(invoicesRepositoryProvider));
  final page = await useCase(pageSize: 100);
  return page.invoices.where((invoice) => invoice.dealId == dealId).toList();
}
