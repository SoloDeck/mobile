import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/reminders/domain/entities/reminder.dart';
import 'package:solodesk_mobile/modules/reminders/domain/repositories/reminders_repository.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_channel.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_query.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_target_type.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_type.dart';
import 'package:solodesk_mobile/modules/reminders/infrastructure/datasource/reminders_local_datasource.dart';
import 'package:solodesk_mobile/modules/reminders/infrastructure/datasource/reminders_remote_datasource.dart';
import 'package:solodesk_mobile/modules/reminders/infrastructure/dto/reminder_request_dto.dart';
import 'package:solodesk_mobile/modules/reminders/infrastructure/mapper/reminder_mapper.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

part 'reminders_repository_impl.g.dart';

class RemindersRepositoryImpl implements RemindersRepository {
  const RemindersRepositoryImpl(this._remote, this._local);

  final RemindersRemoteDatasource _remote;
  final RemindersLocalDatasource _local;

  @override
  Future<List<Reminder>> listReminders({
    ReminderListFilter filter = const ReminderListFilter(),
  }) async {
    try {
      final dtos = await _remote.listReminders(
        status: filter.status,
        targetType: filter.targetType,
      );
      final reminders = dtos.map((dto) => dto.toDomain()).toList();
      await _local.replaceAll(reminders);
      // Backend không sort — sắp xếp theo mốc hẹn tăng dần ở đây.
      reminders.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      return reminders;
    } on NetworkException {
      final cached = await _local.listReminders(filter: filter);
      cached.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      return cached;
    }
  }

  @override
  Future<Reminder?> getReminder(String id) async {
    try {
      final dto = await _remote.getReminder(id);
      return dto.toDomain();
    } on NotFoundException {
      return null;
    }
  }

  @override
  Future<Reminder> createReminder({
    required ReminderTargetType targetType,
    required String targetId,
    required ReminderType reminderType,
    required ReminderChannel channel,
    required DateTime scheduledAt,
    String? messagePreview,
  }) async {
    final dto = await _remote.createReminder(
      ReminderRequestDto(
        targetType: targetType.wireValue,
        targetId: targetId,
        reminderType: reminderType.wireValue,
        channel: channel.wireValue,
        scheduledAt: scheduledAt.toIso8601String(),
        messagePreview: messagePreview,
      ),
    );
    // KHÔNG tự set status — backend luôn ép 'pending' khi tạo mới.
    return dto.toDomain();
  }

  @override
  Future<Reminder> updateReminder({
    required String id,
    DateTime? scheduledAt,
    String? messagePreview,
    ReminderChannel? channel,
  }) async {
    // PATCH vẫn đòi đủ field — đọc bản ghi hiện tại để giữ nguyên
    // target_type/target_id/reminder_type, chỉ ghi đè field được truyền vào.
    final current = await _remote.getReminder(id);
    final updated = await _remote.updateReminder(
      id,
      ReminderRequestDto(
        targetType: current.targetType,
        targetId: current.targetId,
        reminderType: current.reminderType,
        channel: channel?.wireValue ?? current.channel,
        scheduledAt: scheduledAt?.toIso8601String() ?? current.scheduledAt,
        messagePreview: messagePreview ?? current.messagePreview,
      ),
    );
    return updated.toDomain();
  }

  @override
  Future<void> cancelReminder(String id) async {
    // Huỷ mềm — KHÔNG xoá khỏi Drift cache, vẫn nên hiện trong danh sách với
    // status='cancelled' ở lần đồng bộ sau.
    await _remote.cancelReminder(id);
  }
}

@Riverpod(keepAlive: true)
RemindersRepository remindersRepository(Ref ref) {
  final client = ref.read(apiClientProvider);
  final database = ref.read(appDatabaseProvider);
  return RemindersRepositoryImpl(
    RemindersRemoteDatasource(client),
    RemindersLocalDatasource(database),
  );
}
