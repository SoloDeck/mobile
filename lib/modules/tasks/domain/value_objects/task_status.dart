import 'package:freezed_annotation/freezed_annotation.dart';

/// Workflow state of a task. Wire values mirror the backend `TaskStatus` enum.
enum TaskStatus {
  @JsonValue('todo')
  todo,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('review')
  review,
  @JsonValue('done')
  done,
}

extension TaskStatusX on TaskStatus {
  String get wireValue => switch (this) {
    TaskStatus.todo => 'todo',
    TaskStatus.inProgress => 'in_progress',
    TaskStatus.review => 'review',
    TaskStatus.done => 'done',
  };

  String get label => switch (this) {
    TaskStatus.todo => 'Cần làm',
    TaskStatus.inProgress => 'Đang làm',
    TaskStatus.review => 'Đang duyệt',
    TaskStatus.done => 'Hoàn thành',
  };

  static TaskStatus fromWire(String value) => switch (value) {
    'todo' => TaskStatus.todo,
    'in_progress' => TaskStatus.inProgress,
    'review' => TaskStatus.review,
    'done' => TaskStatus.done,
    _ => throw ArgumentError.value(value, 'value', 'Unknown task status'),
  };
}
