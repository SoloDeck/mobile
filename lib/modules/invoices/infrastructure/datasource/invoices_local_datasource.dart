import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_query.dart';
import 'package:solodesk_mobile/modules/invoices/infrastructure/mapper/invoice_row_mapper.dart';

class InvoicesLocalDatasource {
  const InvoicesLocalDatasource(this._database);

  final AppDatabase _database;

  Future<void> upsertInvoices(Iterable<Invoice> invoices) =>
      _database.invoiceRowsDao.upsertAll(invoices.map((i) => i.toRow()));

  /// Returns the cached invoice summaries matching [filter]. Used as the offline
  /// fallback for the first page — the cache holds only summary rows.
  Future<List<Invoice>> listInvoices({
    InvoiceListFilter filter = const InvoiceListFilter(),
  }) async {
    final rows = await _database.invoiceRowsDao.getAll();
    return rows.map((row) => row.toDomain()).where(filter.matches).toList();
  }
}
