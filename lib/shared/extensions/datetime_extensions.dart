import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String toDisplayDate() => DateFormat('dd/MM/yyyy').format(this);
  String toDisplayDateTime() => DateFormat('dd/MM/yyyy HH:mm').format(this);
  String toApiString() => toUtc().toIso8601String();
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

extension StringDateX on String {
  DateTime toDateTime() => DateTime.parse(this);
}
