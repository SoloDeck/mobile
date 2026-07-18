import 'package:drift/drift.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';

/// The drift row caches only the summary fields the list needs. Non-summary
/// required fields (owner/client ids, issue date) are reconstructed as
/// placeholders — the detail page always re-fetches the full invoice from the
/// remote, so these placeholders never surface in the UI.
extension InvoiceRowMapper on InvoiceRow {
  Invoice toDomain() {
    final due = DateTime.parse(dueDate);
    return Invoice(
      id: id,
      ownerUserId: '',
      clientId: '',
      invoiceNumber: invoiceNumber,
      status: invoiceStatusFromWire(status),
      issueDate: due,
      dueDate: due,
      total: total,
      createdAt: updatedAt == null ? due : DateTime.parse(updatedAt!),
      clientName: clientName,
      amountOutstanding: amountOutstanding,
      updatedAt: updatedAt == null ? null : DateTime.parse(updatedAt!),
    );
  }
}

extension InvoiceToRowMapper on Invoice {
  InvoiceRowsCompanion toRow() => InvoiceRowsCompanion(
    id: Value(id),
    invoiceNumber: Value(invoiceNumber),
    status: Value(status.wireValue),
    dueDate: Value(dueDate.toIso8601String()),
    total: Value(total),
    amountOutstanding: Value(amountOutstanding),
    clientName: Value(clientName),
    updatedAt: Value(updatedAt?.toIso8601String()),
  );
}
