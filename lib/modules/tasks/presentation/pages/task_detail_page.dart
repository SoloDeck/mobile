import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/modules/tasks/domain/entities/task.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/priority.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_status.dart';
import 'package:solodesk_mobile/modules/tasks/presentation/controllers/tasks_controller.dart';
import 'package:solodesk_mobile/modules/tasks/presentation/pages/widgets/checklist_widget.dart';
import 'package:solodesk_mobile/modules/tasks/presentation/providers/tasks_provider.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';

/// Task detail — title, metadata, checklist, and status transitions. Loaded by
/// id via `GET /tasks/{id}`.
class TaskDetailPage extends ConsumerWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskDetailProvider(taskId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết công việc')),
      body: AsyncValueWidget<Task>(
        value: task,
        onRetry: () => ref.invalidate(taskDetailProvider(taskId)),
        data: (t) => _TaskBody(task: t),
      ),
    );
  }
}

class _TaskBody extends ConsumerWidget {
  const _TaskBody({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(
      tasksControllerProvider(task.entityType, task.entityId),
    );
    final theme = Theme.of(context);

    ref.listen(
      tasksControllerProvider(task.entityType, task.entityId),
      (previous, next) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.error.toString())),
          );
        }
      },
    );

    Future<void> changeStatus(TaskStatus status) async {
      await ref
          .read(
            tasksControllerProvider(task.entityType, task.entityId).notifier,
          )
          .updateStatus(taskId: task.id, status: status);
      ref.invalidate(taskDetailProvider(task.id));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(task.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            Chip(label: Text(task.status.label)),
            Chip(label: Text('Ưu tiên: ${task.priority.label}')),
          ],
        ),
        if (task.description != null) ...[
          const SizedBox(height: 16),
          Text(task.description!),
        ],
        const Divider(height: 32),
        Text('Checklist', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ChecklistWidget(items: task.checklistItems),
        const Divider(height: 32),
        Text('Chuyển trạng thái', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final status in TaskStatus.values)
              FilledButton.tonal(
                onPressed: status == task.status || controller.isLoading
                    ? null
                    : () => changeStatus(status),
                child: Text(status.label),
              ),
          ],
        ),
      ],
    );
  }
}
