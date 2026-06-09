import 'package:intl/intl.dart';

String formatVnd(num amount) =>
    NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);

String formatCurrency(num amount, String currency) =>
    NumberFormat.currency(symbol: currency).format(amount);
