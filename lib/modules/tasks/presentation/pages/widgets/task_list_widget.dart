import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/modules/tasks/domain/entities/task.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/presentation/pages/widgets/task_card.dart';
import 'package:solodesk_mobile/modules/tasks/presentation/providers/tasks_provider.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';

/// Reusable task list for any owner entity. Drop it into a project, deal, or
/// reminder detail screen — it loads its own tasks via the polymorphic
/// (entityType, entityId) family provider, so there is no duplication.
class TaskListWidget extends ConsumerWidget {
  const TaskListWidget({
    super.key,
    required this.entityType,
    required this.entityId,
    this.shrinkWrap = false,
  });

  final TaskOwner entityType;
  final String entityId;

  /// When embedded inside another scroll view (e.g. a detail page), set true.
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider(entityType, entityId));

    return AsyncValueWidget<List<Task>>(
      value: tasks,
      onRetry: () =>
          ref.invalidate(taskListProvider(entityType, entityId)),
      data: (items) {
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Chưa có công việc nào.')),
          );
        }
        return ListView.builder(
          shrinkWrap: shrinkWrap,
          physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
          padding: const EdgeInsets.all(8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final task = items[index];
            return TaskCard(
              task: task,
              onTap: () => context.push('/tasks/${task.id}'),
            );
          },
        );
      },
    );
  }
}
