import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/reminders/domain/entities/reminder.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_channel.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_status.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_target_type.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_type.dart';
import 'package:solodesk_mobile/modules/reminders/infrastructure/datasource/reminders_local_datasource.dart';
import 'package:solodesk_mobile/modules/reminders/infrastructure/datasource/reminders_remote_datasource.dart';
import 'package:solodesk_mobile/modules/reminders/infrastructure/dto/reminder_response_dto.dart';
import 'package:solodesk_mobile/modules/reminders/infrastructure/repository/reminders_repository_impl.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

class _MockRemote extends Mock implements RemindersRemoteDatasource {}

Reminder _reminder(
  String id, {
  DateTime? scheduledAt,
  ReminderStatus status = ReminderStatus.pending,
}) => Reminder(
  id: id,
  ownerUserId: 'owner-1',
  targetType: ReminderTargetType.invoice,
  targetId: 'inv-1',
  reminderType: ReminderType.paymentDue,
  channel: ReminderChannel.zalo,
  status: status,
  scheduledAt: scheduledAt ?? DateTime.utc(2026, 7, 28, 9),
  createdAt: DateTime.utc(2026, 7, 25, 8),
);

ReminderResponseDto _dto(String id, {required DateTime scheduledAt}) =>
    ReminderResponseDto(
      id: id,
      ownerUserId: 'owner-1',
      targetType: 'invoice',
      targetId: 'inv-1',
      reminderType: 'payment_due',
      channel: 'zalo',
      status: 'pending',
      scheduledAt: scheduledAt.toIso8601String(),
      createdAt: '2026-07-25T08:00:00Z',
    );

void main() {
  late AppDatabase database;
  late RemindersLocalDatasource local;
  late _MockRemote remote;
  late RemindersRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    local = RemindersLocalDatasource(database);
    remote = _MockRemote();
    repository = RemindersRepositoryImpl(remote, local);
  });

  tearDown(() => database.close());

  test('listReminders remote OK -> replaceAll thay TOÀN BỘ cache, '
      'không sót dòng cũ nếu remote trả tập nhỏ hơn', () async {
    // Gieo 3 dòng cũ trực tiếp vào Drift.
    await local.replaceAll([
      _reminder('old-1'),
      _reminder('old-2'),
      _reminder('old-3'),
    ]);

    when(
      () => remote.listReminders(
        status: any(named: 'status'),
        targetType: any(named: 'targetType'),
      ),
    ).thenAnswer(
      (_) async => [_dto('new-1', scheduledAt: DateTime.utc(2026, 7, 29))],
    );

    final result = await repository.listReminders();

    expect(result.map((r) => r.id), ['new-1']);

    final cachedRows = await database.reminderRowsDao.getAll();
    expect(cachedRows.map((r) => r.id), ['new-1']);
  });

  test(
    'listReminders remote ném NetworkException -> đọc từ Drift cache',
    () async {
      await local.replaceAll([
        _reminder('cached-1', scheduledAt: DateTime.utc(2026, 7, 26)),
      ]);

      when(
        () => remote.listReminders(
          status: any(named: 'status'),
          targetType: any(named: 'targetType'),
        ),
      ).thenThrow(NetworkException.noConnection());

      final result = await repository.listReminders();

      expect(result, hasLength(1));
      expect(result.single.id, 'cached-1');
    },
  );

  test(
    'listReminders (remote OK) sắp xếp kết quả theo scheduledAt tăng dần',
    () async {
      when(
        () => remote.listReminders(
          status: any(named: 'status'),
          targetType: any(named: 'targetType'),
        ),
      ).thenAnswer(
        (_) async => [
          _dto('later', scheduledAt: DateTime.utc(2026, 8, 1)),
          _dto('earliest', scheduledAt: DateTime.utc(2026, 7, 20)),
          _dto('middle', scheduledAt: DateTime.utc(2026, 7, 27)),
        ],
      );

      final result = await repository.listReminders();

      expect(result.map((r) => r.id), ['earliest', 'middle', 'later']);
    },
  );

  test(
    'listReminders (cache offline) cũng sắp xếp theo scheduledAt tăng dần',
    () async {
      await local.replaceAll([
        _reminder('later', scheduledAt: DateTime.utc(2026, 8, 1)),
        _reminder('earliest', scheduledAt: DateTime.utc(2026, 7, 20)),
        _reminder('middle', scheduledAt: DateTime.utc(2026, 7, 27)),
      ]);

      when(
        () => remote.listReminders(
          status: any(named: 'status'),
          targetType: any(named: 'targetType'),
        ),
      ).thenThrow(NetworkException.noConnection());

      final result = await repository.listReminders();

      expect(result.map((r) => r.id), ['earliest', 'middle', 'later']);
    },
  );
}
