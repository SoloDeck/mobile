import 'package:flutter/material.dart';
import 'package:solodesk_mobile/modules/tasks/domain/entities/task.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/priority.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_status.dart';

/// Compact card summarizing a single [Task] — title, status, priority and
/// checklist progress.
class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.onTap});

  final Task task;
  final VoidCallback? onTap;

  Color _priorityColor(ColorScheme scheme) => switch (task.priority) {
    Priority.low => scheme.outline,
    Priority.medium => scheme.primary,
    Priority.high => scheme.error,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doneCount = task.checklistItems.where((c) => c.isDone).length;
    final total = task.checklistItems.length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(task.status.label),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.flag,
                  size: 16,
                  color: _priorityColor(theme.colorScheme),
                ),
                Text(task.priority.label, style: theme.textTheme.labelSmall),
              ],
            ),
            if (total > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Checklist: $doneCount/$total',
                  style: theme.textTheme.labelSmall,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
