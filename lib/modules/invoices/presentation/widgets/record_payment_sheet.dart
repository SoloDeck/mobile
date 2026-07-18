import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/payment_method.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/controllers/invoice_detail_controller.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/money_text.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';
import 'package:solodesk_mobile/shared/extensions/context_extensions.dart';
import 'package:solodesk_mobile/shared/extensions/datetime_extensions.dart';
import 'package:solodesk_mobile/shared/utils/currency_formatter.dart';

/// Bottom sheet to record a payment against an invoice. Blocks amounts above the
/// outstanding balance inline (mirroring the backend 400) before submitting.
class RecordPaymentSheet extends ConsumerStatefulWidget {
  const RecordPaymentSheet({super.key, required this.invoice});

  final Invoice invoice;

  static Future<void> show(BuildContext context, Invoice invoice) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => RecordPaymentSheet(invoice: invoice),
    );
  }

  @override
  ConsumerState<RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<RecordPaymentSheet> {
  late final TextEditingController _amountCtrl;
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  PaymentMethod _method = PaymentMethod.bankTransfer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.invoice.amountOutstanding.toInt().toString(),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final outstanding = widget.invoice.amountOutstanding;
    setState(() {
      if (amount <= 0) {
        _error = 'Số tiền phải lớn hơn 0';
      } else if (amount > outstanding) {
        _error = 'Vượt quá số còn lại (${formatVnd(outstanding)})';
      } else {
        _error = null;
      }
    });
    if (_error != null) return;

    final result = await ref
        .read(invoiceDetailControllerProvider.notifier)
        .recordPayment(
          id: widget.invoice.id,
          amount: amount,
          amountOutstanding: outstanding,
          paymentDate: _date,
          paymentMethod: _method,
          referenceNote: _noteCtrl.text.trim().isEmpty
              ? null
              : _noteCtrl.text.trim(),
        );
    if (!mounted) return;
    if (result != null) {
      Navigator.of(context).pop();
      context.showSnackBar('Đã ghi nhận thanh toán');
    } else {
      final error = ref.read(invoiceDetailControllerProvider).error;
      setState(() {
        _error = error is AppException
            ? error.message
            : 'Không thể ghi nhận thanh toán';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSubmitting = ref.watch(invoiceDetailControllerProvider).isLoading;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ghi nhận thanh toán', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Còn lại: ', style: theme.textTheme.bodySmall),
                MoneyText(
                  widget.invoice.amountOutstanding,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Số tiền (₫) *',
                errorText: _error,
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Ngày thanh toán'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_date.toDisplayDate()),
                    const Icon(Icons.event_outlined, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PaymentMethod>(
              initialValue: _method,
              decoration: const InputDecoration(labelText: 'Phương thức'),
              items: PaymentMethod.values
                  .map(
                    (method) => DropdownMenuItem(
                      value: method,
                      child: Text(method.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _method = value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (tuỳ chọn)',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isSubmitting ? null : _submit,
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Ghi nhận'),
            ),
          ],
        ),
      ),
    );
  }
}
