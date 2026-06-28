import 'package:flutter/material.dart';
import 'package:solodesk_mobile/modules/projects/domain/value_objects/project_status.dart';

/// Small colored chip showing a project's [ProjectStatus] with Vietnamese label.
class ProjectStatusBadge extends StatelessWidget {
  const ProjectStatusBadge({super.key, required this.status});

  final ProjectStatus status;

  Color _color(ColorScheme scheme) => switch (status) {
    ProjectStatus.planning => scheme.secondary,
    ProjectStatus.active => scheme.primary,
    ProjectStatus.onHold => scheme.tertiary,
    ProjectStatus.completed => scheme.outline,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _color(scheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
