import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/repositories/invoices_repository.dart';

class ListPaymentsUseCase {
  const ListPaymentsUseCase(this._repository);

  final InvoicesRepository _repository;

  Future<List<PaymentRecord>> call(String id) => _repository.listPayments(id);
}
