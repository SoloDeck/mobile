import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/projects/domain/value_objects/project_status.dart';

part 'project.freezed.dart';

/// A project (dự án) — a body of work optionally linked to a deal. Pure domain
/// entity mirroring the backend `ProjectResponse` contract (`/projects`).
@freezed
abstract class Project with _$Project {
  const factory Project({
    required String id,
    required String ownerId,
    required String name,
    required ProjectStatus status,
    required int taskCount,
    required int doneCount,
    required DateTime createdAt,
    String? dealId,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? updatedAt,
  }) = _Project;
}
