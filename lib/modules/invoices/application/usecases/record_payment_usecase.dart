import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/repositories/invoices_repository.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/payment_method.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

/// Records a payment against an invoice. The amount must be positive and cannot
/// exceed the outstanding balance — checked locally before the request so the
/// sheet gives immediate feedback, mirroring the backend's 400.
class RecordPaymentUseCase {
  const RecordPaymentUseCase(this._repository);

  final InvoicesRepository _repository;

  Future<Invoice> call({
    required String id,
    required double amount,
    required double amountOutstanding,
    required DateTime paymentDate,
    PaymentMethod? paymentMethod,
    String? referenceNote,
  }) {
    if (amount <= 0) {
      throw const ValidationException('Số tiền phải lớn hơn 0');
    }
    if (amount > amountOutstanding) {
      throw const ValidationException('Số tiền vượt quá số còn lại phải trả');
    }
    return _repository.recordPayment(
      id: id,
      amount: amount,
      paymentDate: paymentDate,
      paymentMethod: paymentMethod,
      referenceNote: referenceNote,
    );
  }
}
