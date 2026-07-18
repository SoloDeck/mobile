import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';

/// The list-filter chips shown on the invoices page. A [status] filter and the
/// [overdueOnly] flag are the two axes the mobile UI exposes; the backend
/// supports more (date ranges, number search) but they are not surfaced in v1.
class InvoiceListFilter {
  const InvoiceListFilter({this.status, this.overdueOnly = false});

  final InvoiceStatus? status;
  final bool overdueOnly;

  /// Predicate used to filter the offline cache the same way the backend would.
  bool matches(Invoice invoice) {
    if (overdueOnly && !invoice.isOverdue) return false;
    if (status != null && invoice.status != status) return false;
    return true;
  }

  @override
  bool operator ==(Object other) =>
      other is InvoiceListFilter &&
      other.status == status &&
      other.overdueOnly == overdueOnly;

  @override
  int get hashCode => Object.hash(status, overdueOnly);
}

/// One page of invoices plus whether another page can be loaded — backs the
/// list's infinite scroll.
class InvoiceListPage {
  const InvoiceListPage({
    required this.invoices,
    required this.page,
    required this.hasMore,
  });

  final List<Invoice> invoices;
  final int page;
  final bool hasMore;
}
