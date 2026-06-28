import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/tasks/domain/entities/task.dart';
import 'package:solodesk_mobile/modules/tasks/domain/repositories/tasks_repository.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/priority.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_status.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/repository/tasks_repository_impl.dart';
import 'package:solodesk_mobile/modules/tasks/presentation/pages/widgets/task_list_widget.dart';

class _FakeTasksRepository implements TasksRepository {
  _FakeTasksRepository(this.tasks);

  final List<Task> tasks;

  @override
  Future<List<Task>> listByEntity({
    required TaskOwner entityType,
    required String entityId,
    TaskStatus? status,
  }) async => tasks;

  @override
  Future<Task> getTask(String id) async => tasks.firstWhere((t) => t.id == id);

  @override
  Future<Task> createTask({
    required TaskOwner entityType,
    required String entityId,
    required String title,
    String? description,
    Priority? priority,
    DateTime? deadline,
  }) async => tasks.first;

  @override
  Future<Task> updateStatus({
    required String taskId,
    required TaskStatus status,
  }) async => tasks.firstWhere((t) => t.id == taskId);
}

Task _task(String id, String title) => Task(
  id: id,
  entityType: TaskOwner.project,
  entityId: 'p1',
  title: title,
  priority: Priority.medium,
  status: TaskStatus.todo,
  createdAt: DateTime.utc(2026, 6, 14),
);

Widget _wrap(List<Task> tasks) => ProviderScope(
  overrides: [
    tasksRepositoryProvider.overrideWithValue(_FakeTasksRepository(tasks)),
  ],
  child: const MaterialApp(
    home: Scaffold(
      body: TaskListWidget(entityType: TaskOwner.project, entityId: 'p1'),
    ),
  ),
);

void main() {
  testWidgets('TaskListWidget renders task cards from provider', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap([_task('t1', 'Viết tài liệu'), _task('t2', 'Gọi khách hàng')]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Viết tài liệu'), findsOneWidget);
    expect(find.text('Gọi khách hàng'), findsOneWidget);
  });

  testWidgets('TaskListWidget shows empty state when no tasks', (tester) async {
    await tester.pumpWidget(_wrap([]));
    await tester.pumpAndSettle();

    expect(find.text('Chưa có công việc nào.'), findsOneWidget);
  });
}
