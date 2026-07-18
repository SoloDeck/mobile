import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/modules/invoices/application/usecases/create_invoice_usecase.dart';
import 'package:solodesk_mobile/modules/invoices/application/usecases/record_payment_usecase.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/repositories/invoices_repository.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

class _MockRepository extends Mock implements InvoicesRepository {}

Invoice _invoice() => Invoice(
  id: 'inv-1',
  ownerUserId: 'owner-1',
  clientId: 'client-1',
  invoiceNumber: 'INV-2026-0042',
  status: InvoiceStatus.sent,
  issueDate: DateTime.utc(2026, 7, 1),
  dueDate: DateTime.utc(2026, 7, 15),
  total: 11000000,
  createdAt: DateTime.utc(2026, 7, 1),
  amountOutstanding: 7000000,
);

void main() {
  late _MockRepository repository;

  setUp(() => repository = _MockRepository());

  group('CreateInvoiceUseCase', () {
    test('rejects a standalone invoice (no contract or deal)', () {
      final useCase = CreateInvoiceUseCase(repository);
      expect(
        () => useCase(
          clientId: 'client-1',
          dueDate: DateTime.utc(2026, 7, 15),
          lineItems: [
            const LineItemInput(description: 'X', quantity: 1, unitPrice: 100),
          ],
        ),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(
        () => repository.createInvoice(
          clientId: any(named: 'clientId'),
          dueDate: any(named: 'dueDate'),
        ),
      );
    });

    test('rejects when there are no line items and no subtotal', () {
      final useCase = CreateInvoiceUseCase(repository);
      expect(
        () => useCase(
          clientId: 'client-1',
          dealId: 'deal-1',
          dueDate: DateTime.utc(2026, 7, 15),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('forwards a valid create to the repository', () async {
      when(
        () => repository.createInvoice(
          clientId: any(named: 'clientId'),
          contractId: any(named: 'contractId'),
          dealId: any(named: 'dealId'),
          issueDate: any(named: 'issueDate'),
          dueDate: any(named: 'dueDate'),
          currency: any(named: 'currency'),
          subtotal: any(named: 'subtotal'),
          taxRate: any(named: 'taxRate'),
          notes: any(named: 'notes'),
          lineItems: any(named: 'lineItems'),
        ),
      ).thenAnswer((_) async => _invoice());

      final useCase = CreateInvoiceUseCase(repository);
      final result = await useCase(
        clientId: 'client-1',
        dealId: 'deal-1',
        dueDate: DateTime.utc(2026, 7, 15),
        lineItems: [
          const LineItemInput(description: 'X', quantity: 1, unitPrice: 100),
        ],
      );

      expect(result.id, 'inv-1');
    });
  });

  group('RecordPaymentUseCase', () {
    test('rejects a non-positive amount', () {
      final useCase = RecordPaymentUseCase(repository);
      expect(
        () => useCase(
          id: 'inv-1',
          amount: 0,
          amountOutstanding: 7000000,
          paymentDate: DateTime.utc(2026, 7, 5),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rejects overpayment above the outstanding balance', () {
      final useCase = RecordPaymentUseCase(repository);
      expect(
        () => useCase(
          id: 'inv-1',
          amount: 8000000,
          amountOutstanding: 7000000,
          paymentDate: DateTime.utc(2026, 7, 5),
        ),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(
        () => repository.recordPayment(
          id: any(named: 'id'),
          amount: any(named: 'amount'),
          paymentDate: any(named: 'paymentDate'),
        ),
      );
    });

    test('forwards a valid payment to the repository', () async {
      when(
        () => repository.recordPayment(
          id: any(named: 'id'),
          amount: any(named: 'amount'),
          paymentDate: any(named: 'paymentDate'),
          paymentMethod: any(named: 'paymentMethod'),
          referenceNote: any(named: 'referenceNote'),
        ),
      ).thenAnswer((_) async => _invoice());

      final useCase = RecordPaymentUseCase(repository);
      final result = await useCase(
        id: 'inv-1',
        amount: 7000000,
        amountOutstanding: 7000000,
        paymentDate: DateTime.utc(2026, 7, 5),
      );

      expect(result.amountOutstanding, 7000000);
    });
  });
}
