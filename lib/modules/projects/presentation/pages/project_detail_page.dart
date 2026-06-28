import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/modules/projects/domain/entities/project.dart';
import 'package:solodesk_mobile/modules/projects/presentation/pages/widgets/project_status_badge.dart';
import 'package:solodesk_mobile/modules/projects/presentation/providers/projects_provider.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/presentation/pages/widgets/task_list_widget.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';

/// Project detail with an "Thông tin" (info) tab and a "Công việc" (tasks) tab.
/// The tasks tab reuses [TaskListWidget] keyed on this project.
class ProjectDetailPage extends ConsumerWidget {
  const ProjectDetailPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectDetailProvider(projectId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết dự án'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Thông tin'),
              Tab(text: 'Công việc'),
            ],
          ),
        ),
        body: AsyncValueWidget<Project>(
          value: project,
          onRetry: () => ref.invalidate(projectDetailProvider(projectId)),
          data: (p) => TabBarView(
            children: [
              _ProjectInfo(project: p),
              TaskListWidget(
                entityType: TaskOwner.project,
                entityId: p.id,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectInfo extends StatelessWidget {
  const _ProjectInfo({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(project.name, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        ProjectStatusBadge(status: project.status),
        const Divider(height: 32),
        _Row(label: 'Tiến độ', value: '${project.doneCount}/${project.taskCount}'),
        _Row(label: 'Mô tả', value: project.description ?? '—'),
        _Row(
          label: 'Bắt đầu',
          value: project.startDate == null
              ? '—'
              : _formatDate(project.startDate!),
        ),
        _Row(
          label: 'Kết thúc',
          value:
              project.endDate == null ? '—' : _formatDate(project.endDate!),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
