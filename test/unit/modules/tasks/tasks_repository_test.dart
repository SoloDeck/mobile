import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/priority.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_status.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/datasource/tasks_local_datasource.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/datasource/tasks_remote_datasource.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/dto/create_task_request_dto.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/dto/task_response_dto.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/repository/tasks_repository_impl.dart';

class _MockTasksRemoteDatasource extends Mock
    implements TasksRemoteDatasource {}

TaskResponseDto _taskDto({String id = 't1', String entityId = 'p1'}) =>
    TaskResponseDto(
      id: id,
      entityType: TaskOwner.project,
      entityId: entityId,
      title: 'Viết tài liệu',
      priority: Priority.medium,
      status: TaskStatus.todo,
      createdAt: '2026-06-14T08:00:00.000Z',
    );

void main() {
  setUpAll(() {
    registerFallbackValue(const CreateTaskRequestDto(title: 'fallback'));
    registerFallbackValue(TaskOwner.project);
  });

  late AppDatabase database;
  late TasksLocalDatasource local;
  late _MockTasksRemoteDatasource remote;
  late TasksRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    local = TasksLocalDatasource(database);
    remote = _MockTasksRemoteDatasource();
    repository = TasksRepositoryImpl(remote, local);
  });

  tearDown(() => database.close());

  test(
    'listByEntity calls remote datasource with correct entityType and entityId',
    () async {
      when(
        () => remote.listByEntity(
          entityType: TaskOwner.project,
          entityId: 'p1',
          status: null,
        ),
      ).thenAnswer((_) async => [_taskDto()]);

      final result = await repository.listByEntity(
        entityType: TaskOwner.project,
        entityId: 'p1',
      );

      expect(result.single.id, 't1');
      verify(
        () => remote.listByEntity(
          entityType: TaskOwner.project,
          entityId: 'p1',
          status: null,
        ),
      ).called(1);
    },
  );

  test('createTask calls remote datasource with correct body', () async {
    when(
      () => remote.createTask(
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        request: any(named: 'request'),
      ),
    ).thenAnswer((_) async => _taskDto());

    await repository.createTask(
      entityType: TaskOwner.project,
      entityId: 'p1',
      title: 'Viết tài liệu',
      priority: Priority.high,
    );

    final captured = verify(
      () => remote.createTask(
        entityType: TaskOwner.project,
        entityId: 'p1',
        request: captureAny(named: 'request'),
      ),
    ).captured.single as CreateTaskRequestDto;

    expect(captured.title, 'Viết tài liệu');
    expect(captured.priority, Priority.high);
  });
}
