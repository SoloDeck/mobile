import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/invoice_response_dto.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/line_item_dto.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/dto/payment_record_dto.dart';

extension InvoiceResponseDtoMapper on InvoiceResponseDto {
  Invoice toDomain() => Invoice(
    id: id,
    ownerUserId: ownerUserId,
    clientId: clientId,
    invoiceNumber: invoiceNumber,
    status: status,
    issueDate: DateTime.parse(issueDate),
    dueDate: DateTime.parse(dueDate),
    total: total,
    createdAt: DateTime.parse(createdAt),
    clientName: clientName,
    contractId: contractId,
    dealId: dealId,
    currency: currency,
    subtotal: subtotal,
    taxRate: taxRate,
    taxAmount: taxAmount,
    amountPaid: amountPaid,
    amountOutstanding: amountOutstanding,
    notes: notes,
    lineItems: lineItems.map((item) => item.toDomain()).toList(),
    sentAt: sentAt == null ? null : DateTime.parse(sentAt!),
    voidedAt: voidedAt == null ? null : DateTime.parse(voidedAt!),
    updatedAt: updatedAt == null ? null : DateTime.parse(updatedAt!),
  );
}

extension LineItemDtoMapper on LineItemDto {
  LineItem toDomain() => LineItem(
    description: description,
    quantity: quantity,
    unitPrice: unitPrice,
    amount: amount,
    sortOrder: sortOrder,
  );
}

extension PaymentRecordDtoMapper on PaymentRecordDto {
  PaymentRecord toDomain() => PaymentRecord(
    id: id,
    invoiceId: invoiceId,
    amount: amount,
    paymentDate: DateTime.parse(paymentDate),
    paymentMethod: paymentMethod,
    createdAt: DateTime.parse(createdAt),
    referenceNote: referenceNote,
  );
}
