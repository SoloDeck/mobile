import 'package:freezed_annotation/freezed_annotation.dart';

/// Lifecycle of a project (dự án). Wire values mirror the backend
/// `ProjectStatus` enum in `contracts/openapi.yaml`.
enum ProjectStatus {
  @JsonValue('planning')
  planning,
  @JsonValue('active')
  active,
  @JsonValue('on_hold')
  onHold,
  @JsonValue('completed')
  completed,
}

extension ProjectStatusX on ProjectStatus {
  /// Snake-case value the backend expects (matches the `@JsonValue` strings),
  /// used when the enum is sent/stored as a raw string.
  String get wireValue => switch (this) {
    ProjectStatus.planning => 'planning',
    ProjectStatus.active => 'active',
    ProjectStatus.onHold => 'on_hold',
    ProjectStatus.completed => 'completed',
  };

  String get label => switch (this) {
    ProjectStatus.planning => 'Lên kế hoạch',
    ProjectStatus.active => 'Đang thực hiện',
    ProjectStatus.onHold => 'Tạm dừng',
    ProjectStatus.completed => 'Hoàn thành',
  };

  static ProjectStatus fromWire(String value) => switch (value) {
    'planning' => ProjectStatus.planning,
    'active' => ProjectStatus.active,
    'on_hold' => ProjectStatus.onHold,
    'completed' => ProjectStatus.completed,
    _ => throw ArgumentError.value(value, 'value', 'Unknown project status'),
  };
}
