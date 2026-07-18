import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/invoices/application/usecases/create_invoice_usecase.dart';
import 'package:solodesk_mobile/modules/invoices/application/usecases/record_payment_usecase.dart';
import 'package:solodesk_mobile/modules/invoices/application/usecases/send_invoice_usecase.dart';
import 'package:solodesk_mobile/modules/invoices/application/usecases/update_invoice_usecase.dart';
import 'package:solodesk_mobile/modules/invoices/application/usecases/void_invoice_usecase.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/repositories/invoices_repository.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/payment_method.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/repository/invoices_repository_impl.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/controllers/invoices_list_controller.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/providers/invoices_provider.dart';

part 'invoice_detail_controller.g.dart';

/// Drives the status actions on the invoice detail page (send / void / record
/// payment). On success it refreshes the detail, payment history, list and any
/// deal-detail invoice section.
@riverpod
class InvoiceDetailController extends _$InvoiceDetailController {
  @override
  AsyncValue<Invoice?> build() => const AsyncValue.data(null);

  Future<Invoice?> send(String id) async {
    state = const AsyncValue.loading();
    final useCase = SendInvoiceUseCase(ref.read(invoicesRepositoryProvider));
    state = await AsyncValue.guard(() => useCase(id));
    _refreshOnSuccess(id);
    return state.value;
  }

  Future<Invoice?> voidInvoice(String id) async {
    state = const AsyncValue.loading();
    final useCase = VoidInvoiceUseCase(ref.read(invoicesRepositoryProvider));
    state = await AsyncValue.guard(() => useCase(id));
    _refreshOnSuccess(id);
    return state.value;
  }

  Future<Invoice?> recordPayment({
    required String id,
    required double amount,
    required double amountOutstanding,
    required DateTime paymentDate,
    PaymentMethod? paymentMethod,
    String? referenceNote,
  }) async {
    state = const AsyncValue.loading();
    final useCase = RecordPaymentUseCase(ref.read(invoicesRepositoryProvider));
    state = await AsyncValue.guard(
      () => useCase(
        id: id,
        amount: amount,
        amountOutstanding: amountOutstanding,
        paymentDate: paymentDate,
        paymentMethod: paymentMethod,
        referenceNote: referenceNote,
      ),
    );
    if (state.hasValue && state.value != null) {
      ref.invalidate(invoicePaymentsProvider(id));
    }
    _refreshOnSuccess(id);
    return state.value;
  }

  void _refreshOnSuccess(String id) {
    if (state.hasValue && state.value != null) {
      ref.invalidate(invoiceDetailProvider(id));
      ref.invalidate(dealInvoicesProvider);
      ref.read(invoicesListControllerProvider.notifier).refresh();
    }
  }
}

/// Drives the create / edit-draft form. Holds the most recently saved invoice
/// (or `null` before the first submit) and refreshes affected views on success.
@riverpod
class InvoiceFormController extends _$InvoiceFormController {
  @override
  AsyncValue<Invoice?> build() => const AsyncValue.data(null);

  Future<Invoice?> create({
    required String clientId,
    String? contractId,
    String? dealId,
    DateTime? issueDate,
    required DateTime dueDate,
    double? taxRate,
    String? notes,
    List<LineItemInput> lineItems = const [],
  }) async {
    state = const AsyncValue.loading();
    final useCase = CreateInvoiceUseCase(ref.read(invoicesRepositoryProvider));
    state = await AsyncValue.guard(
      () => useCase(
        clientId: clientId,
        contractId: contractId,
        dealId: dealId,
        issueDate: issueDate,
        dueDate: dueDate,
        taxRate: taxRate,
        notes: notes,
        lineItems: lineItems,
      ),
    );
    if (state.hasValue && state.value != null) {
      ref.invalidate(dealInvoicesProvider);
      ref.read(invoicesListControllerProvider.notifier).refresh();
    }
    return state.value;
  }

  Future<Invoice?> update({
    required String id,
    DateTime? dueDate,
    double? taxRate,
    String? notes,
    List<LineItemInput>? lineItems,
  }) async {
    state = const AsyncValue.loading();
    final useCase = UpdateInvoiceUseCase(ref.read(invoicesRepositoryProvider));
    state = await AsyncValue.guard(
      () => useCase(
        id: id,
        dueDate: dueDate,
        taxRate: taxRate,
        notes: notes,
        lineItems: lineItems,
      ),
    );
    if (state.hasValue && state.value != null) {
      ref.invalidate(invoiceDetailProvider(id));
      ref.invalidate(dealInvoicesProvider);
      ref.read(invoicesListControllerProvider.notifier).refresh();
    }
    return state.value;
  }
}
