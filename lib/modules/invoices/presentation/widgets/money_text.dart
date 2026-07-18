import 'package:flutter/material.dart';
import 'package:solodesk_mobile/shared/utils/currency_formatter.dart';

/// A VND amount rendered with tabular figures so digits stay column-aligned and
/// changing values never shift the layout.
class MoneyText extends StatelessWidget {
  const MoneyText(this.amount, {super.key, this.style, this.color});

  final num amount;
  final TextStyle? style;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.bodyMedium;
    return Text(
      formatVnd(amount),
      style: (base ?? const TextStyle()).copyWith(
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
