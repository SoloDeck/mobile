import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solodesk_mobile/modules/invoices/domain/repositories/invoices_repository.dart';
import 'package:solodesk_mobile/modules/invoices/presentation/widgets/money_text.dart';

/// Editable list of invoice line items. Each row captures description, quantity
/// and unit price and shows the live line amount; the widget reports the current
/// set of non-empty rows via [onChanged] so the parent can preview the subtotal.
class LineItemEditor extends StatefulWidget {
  const LineItemEditor({
    super.key,
    required this.initialItems,
    required this.onChanged,
  });

  final List<LineItemInput> initialItems;
  final ValueChanged<List<LineItemInput>> onChanged;

  @override
  State<LineItemEditor> createState() => _LineItemEditorState();
}

class _LineItemRow {
  _LineItemRow({
    String description = '',
    String quantity = '1',
    String unitPrice = '',
  }) : descriptionCtrl = TextEditingController(text: description),
       quantityCtrl = TextEditingController(text: quantity),
       unitPriceCtrl = TextEditingController(text: unitPrice);

  final TextEditingController descriptionCtrl;
  final TextEditingController quantityCtrl;
  final TextEditingController unitPriceCtrl;

  double get quantity => double.tryParse(quantityCtrl.text.trim()) ?? 0;
  double get unitPrice => double.tryParse(unitPriceCtrl.text.trim()) ?? 0;
  double get amount => quantity * unitPrice;

  void dispose() {
    descriptionCtrl.dispose();
    quantityCtrl.dispose();
    unitPriceCtrl.dispose();
  }
}

class _LineItemEditorState extends State<LineItemEditor> {
  late final List<_LineItemRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.initialItems.isEmpty
        ? [_LineItemRow()]
        : widget.initialItems
              .map(
                (item) => _LineItemRow(
                  description: item.description,
                  quantity: _asField(item.quantity),
                  unitPrice: _asField(item.unitPrice),
                ),
              )
              .toList();
    for (final row in _rows) {
      _attach(row);
    }
  }

  void _attach(_LineItemRow row) {
    row.descriptionCtrl.addListener(_emit);
    row.quantityCtrl.addListener(_emit);
    row.unitPriceCtrl.addListener(_emit);
  }

  void _emit() {
    setState(() {});
    widget.onChanged(_inputs());
  }

  List<LineItemInput> _inputs() {
    final result = <LineItemInput>[];
    for (var i = 0; i < _rows.length; i++) {
      final row = _rows[i];
      if (row.descriptionCtrl.text.trim().isEmpty) continue;
      result.add(
        LineItemInput(
          description: row.descriptionCtrl.text.trim(),
          quantity: row.quantity,
          unitPrice: row.unitPrice,
          sortOrder: i,
        ),
      );
    }
    return result;
  }

  void _addRow() {
    final row = _LineItemRow();
    _attach(row);
    setState(() => _rows.add(row));
    widget.onChanged(_inputs());
  }

  void _removeRow(int index) {
    final removed = _rows.removeAt(index);
    setState(() {});
    removed.dispose();
    widget.onChanged(_inputs());
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  /// Renders a whole number without a trailing `.0` so the field reads cleanly.
  static String _asField(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _rows.length; i++)
          _RowEditor(
            key: ObjectKey(_rows[i]),
            row: _rows[i],
            canRemove: _rows.length > 1,
            onRemove: () => _removeRow(i),
          ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Thêm hạng mục'),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 44),
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _RowEditor extends StatelessWidget {
  const _RowEditor({
    super.key,
    required this.row,
    required this.canRemove,
    required this.onRemove,
  });

  final _LineItemRow row;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.descriptionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    isDense: true,
                  ),
                ),
              ),
              if (canRemove)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Xoá hạng mục',
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: row.quantityCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'SL',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: row.unitPriceCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Đơn giá (₫)',
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Thành tiền', style: theme.textTheme.bodySmall),
              MoneyText(row.amount, style: theme.textTheme.titleSmall),
            ],
          ),
        ],
      ),
    );
  }
}
