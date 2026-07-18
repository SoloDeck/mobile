import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/presentation/providers/deals_provider.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/repositories/invoices_repository.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/controllers/invoice_detail_controller.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/providers/invoices_provider.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/line_item_editor.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/money_text.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';
import 'package:solodesk_mobile/shared/extensions/context_extensions.dart';
import 'package:solodesk_mobile/shared/extensions/datetime_extensions.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';

/// Preset linkage passed via `GoRouter` `extra` when creating an invoice from a
/// deal — the deal (and its client) are then locked in the form.
class InvoiceFormArgs {
  const InvoiceFormArgs({
    required this.dealId,
    required this.clientId,
    this.clientName,
    this.dealTitle,
  });

  final String dealId;
  final String clientId;
  final String? clientName;
  final String? dealTitle;
}

/// Create a draft invoice, or edit an existing draft (when [invoiceId] is set).
class InvoiceFormPage extends ConsumerWidget {
  const InvoiceFormPage({super.key, this.invoiceId, this.preset});

  final String? invoiceId;
  final InvoiceFormArgs? preset;

  bool get _isEdit => invoiceId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Sửa hóa đơn' : 'Tạo hóa đơn')),
      body: _isEdit
          ? AsyncValueWidget<Invoice>(
              value: ref.watch(invoiceDetailProvider(invoiceId!)),
              onRetry: () => ref.invalidate(invoiceDetailProvider(invoiceId!)),
              data: (invoice) => _InvoiceFormBody(invoice: invoice),
            )
          : _InvoiceFormBody(preset: preset),
    );
  }
}

class _InvoiceFormBody extends ConsumerStatefulWidget {
  const _InvoiceFormBody({this.invoice, this.preset});

  final Invoice? invoice;
  final InvoiceFormArgs? preset;

  @override
  ConsumerState<_InvoiceFormBody> createState() => _InvoiceFormBodyState();
}

class _InvoiceFormBodyState extends ConsumerState<_InvoiceFormBody> {
  final _taxCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _dealId;
  String? _clientId;
  String? _dealLabel;

  late DateTime _issueDate;
  late DateTime _dueDate;
  List<LineItemInput> _initialItems = const [];
  List<LineItemInput> _lineItems = const [];
  String? _formError;

  bool get _isEdit => widget.invoice != null;
  bool get _dealLocked => _isEdit || widget.preset != null;

  @override
  void initState() {
    super.initState();
    final invoice = widget.invoice;
    if (invoice != null) {
      _dealId = invoice.dealId;
      _clientId = invoice.clientId;
      _dealLabel = invoice.clientName ?? 'Thương vụ đã liên kết';
      _issueDate = invoice.issueDate;
      _dueDate = invoice.dueDate;
      _taxCtrl.text = _asPercent(invoice.taxRate);
      _notesCtrl.text = invoice.notes ?? '';
      _initialItems = invoice.lineItems
          .map(
            (item) => LineItemInput(
              description: item.description,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              sortOrder: item.sortOrder,
            ),
          )
          .toList();
      _lineItems = _initialItems;
    } else {
      final preset = widget.preset;
      _dealId = preset?.dealId;
      _clientId = preset?.clientId;
      _dealLabel = preset?.dealTitle ?? preset?.clientName;
      _issueDate = DateTime.now();
      _dueDate = DateTime.now().add(const Duration(days: 14));
      _taxCtrl.text = '0';
    }
  }

  @override
  void dispose() {
    _taxCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _subtotal => _lineItems.fold(0, (sum, item) => sum + item.amount);
  double get _taxRateFraction =>
      (double.tryParse(_taxCtrl.text.trim()) ?? 0) / 100;
  double get _taxAmount => _subtotal * _taxRateFraction;
  double get _total => _subtotal + _taxAmount;

  static String _asPercent(double fraction) {
    final percent = fraction * 100;
    return percent == percent.roundToDouble()
        ? percent.toInt().toString()
        : '$percent';
  }

  Future<void> _pickDeal() async {
    final deal = await showModalBottomSheet<Deal>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _DealPickerSheet(),
    );
    if (deal != null) {
      setState(() {
        _dealId = deal.id;
        _clientId = deal.clientId;
        _dealLabel = deal.title;
      });
    }
  }

  Future<void> _pickDate({required bool isDue}) async {
    final initial = isDue ? _dueDate : _issueDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => isDue ? _dueDate = picked : _issueDate = picked);
    }
  }

  String? _validate() {
    if (_dealId == null || _clientId == null) {
      return 'Vui lòng chọn thương vụ';
    }
    if (_lineItems.isEmpty) {
      return 'Cần ít nhất một hạng mục có mô tả';
    }
    if (_lineItems.any((item) => item.quantity <= 0 || item.unitPrice <= 0)) {
      return 'Số lượng và đơn giá phải lớn hơn 0';
    }
    return null;
  }

  Future<void> _submit() async {
    final error = _validate();
    setState(() => _formError = error);
    if (error != null) return;

    final notes = _notesCtrl.text.trim().isEmpty
        ? null
        : _notesCtrl.text.trim();
    final notifier = ref.read(invoiceFormControllerProvider.notifier);
    final Invoice? result;
    if (_isEdit) {
      result = await notifier.update(
        id: widget.invoice!.id,
        dueDate: _dueDate,
        taxRate: _taxRateFraction,
        notes: notes,
        lineItems: _lineItems,
      );
    } else {
      result = await notifier.create(
        clientId: _clientId!,
        dealId: _dealId,
        issueDate: _issueDate,
        dueDate: _dueDate,
        taxRate: _taxRateFraction,
        notes: notes,
        lineItems: _lineItems,
      );
    }

    if (!mounted) return;
    if (result != null) {
      Navigator.of(context).pop(result);
      context.showSnackBar(_isEdit ? 'Đã cập nhật hóa đơn' : 'Đã tạo hóa đơn');
    } else {
      final err = ref.read(invoiceFormControllerProvider).error;
      setState(() {
        _formError = err is AppException
            ? err.message
            : 'Không thể lưu hóa đơn';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSubmitting = ref.watch(invoiceFormControllerProvider).isLoading;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DealField(
                label: _dealLabel,
                locked: _dealLocked,
                onTap: _pickDeal,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Ngày lập',
                      value: _issueDate,
                      // issue_date is immutable once created (PATCH omits it).
                      onTap: _isEdit ? null : () => _pickDate(isDue: false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'Hạn thanh toán *',
                      value: _dueDate,
                      onTap: () => _pickDate(isDue: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Hạng mục', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              LineItemEditor(
                initialItems: _initialItems,
                onChanged: (items) => setState(() => _lineItems = items),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _taxCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(labelText: 'Thuế suất (%)'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Ghi chú'),
              ),
              const SizedBox(height: 20),
              _TotalsPreview(
                subtotal: _subtotal,
                taxAmount: _taxAmount,
                total: _total,
              ),
              if (_formError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _formError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FilledButton(
              onPressed: isSubmitting ? null : _submit,
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEdit ? 'Lưu thay đổi' : 'Tạo hóa đơn'),
            ),
          ),
        ),
      ],
    );
  }
}

class _DealField extends StatelessWidget {
  const _DealField({
    required this.label,
    required this.locked,
    required this.onTap,
  });

  final String? label;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: locked ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Thương vụ *',
          suffixIcon: locked
              ? const Icon(Icons.lock_outline, size: 18)
              : const Icon(Icons.chevron_right_rounded),
        ),
        child: Text(
          label ?? 'Chọn thương vụ',
          style: label == null
              ? theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )
              : theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.value, this.onTap});

  final String label;
  final DateTime value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.event_outlined, size: 20),
          enabled: onTap != null,
        ),
        child: Text(value.toDisplayDate()),
      ),
    );
  }
}

class _TotalsPreview extends StatelessWidget {
  const _TotalsPreview({
    required this.subtotal,
    required this.taxAmount,
    required this.total,
  });

  final double subtotal;
  final double taxAmount;
  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _row(context, 'Tạm tính', subtotal),
          const SizedBox(height: 6),
          _row(context, 'Thuế', taxAmount),
          const Divider(height: 20),
          _row(context, 'Tổng cộng', total, bold: true),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    double value, {
    bool bold = false,
  }) {
    final theme = Theme.of(context);
    final style = bold
        ? theme.textTheme.titleMedium
        : theme.textTheme.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        MoneyText(value, style: style),
      ],
    );
  }
}

class _DealPickerSheet extends ConsumerWidget {
  const _DealPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final deals = ref.watch(dealListProvider);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Chọn thương vụ', style: theme.textTheme.titleLarge),
            ),
          ),
          Expanded(
            child: AsyncValueWidget<List<Deal>>(
              value: deals,
              onRetry: () => ref.invalidate(dealListProvider),
              data: (items) => items.isEmpty
                  ? const Center(child: Text('Chưa có thương vụ nào'))
                  : ListView.separated(
                      controller: scrollController,
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final deal = items[index];
                        return ListTile(
                          title: Text(deal.title),
                          subtitle: Text(
                            deal.clientName ?? 'Không có khách hàng',
                          ),
                          onTap: () => Navigator.of(context).pop(deal),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
