import 'package:freezed_annotation/freezed_annotation.dart';

/// Task priority. Wire values mirror the backend `Priority` enum.
enum Priority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
}

extension PriorityX on Priority {
  String get wireValue => switch (this) {
    Priority.low => 'low',
    Priority.medium => 'medium',
    Priority.high => 'high',
  };

  String get label => switch (this) {
    Priority.low => 'Thấp',
    Priority.medium => 'Trung bình',
    Priority.high => 'Cao',
  };

  static Priority fromWire(String value) => switch (value) {
    'low' => Priority.low,
    'medium' => Priority.medium,
    'high' => Priority.high,
    _ => throw ArgumentError.value(value, 'value', 'Unknown priority'),
  };
}
