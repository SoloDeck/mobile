import 'package:freezed_annotation/freezed_annotation.dart';

/// Polymorphic owner type of a task (`entity_type`). A task is attached to a
/// project, a deal, or a reminder. Wire values mirror the backend `TaskOwner`
/// enum.
enum TaskOwner {
  @JsonValue('project')
  project,
  @JsonValue('deal')
  deal,
  @JsonValue('reminder')
  reminder,
}

extension TaskOwnerX on TaskOwner {
  String get wireValue => switch (this) {
    TaskOwner.project => 'project',
    TaskOwner.deal => 'deal',
    TaskOwner.reminder => 'reminder',
  };

  static TaskOwner fromWire(String value) => switch (value) {
    'project' => TaskOwner.project,
    'deal' => TaskOwner.deal,
    'reminder' => TaskOwner.reminder,
    _ => throw ArgumentError.value(value, 'value', 'Unknown task owner'),
  };
}
