import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_status.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_target_type.dart';
import 'package:solodesk_mobile/modules/reminders/infrastructure/datasource/reminders_remote_datasource.dart';
import 'package:solodesk_mobile/modules/reminders/infrastructure/dto/reminder_request_dto.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  late _MockApiClient client;
  late RemindersRemoteDatasource datasource;

  setUp(() {
    client = _MockApiClient();
    datasource = RemindersRemoteDatasource(client);
  });

  Map<String, dynamic> reminderJson(String id) => {
    'id': id,
    'owner_user_id': 'owner-1',
    'target_type': 'invoice',
    'target_id': 'inv-1',
    'reminder_type': 'payment_due',
    'channel': 'zalo',
    'status': 'pending',
    'scheduled_at': '2026-07-28T09:00:00Z',
    'created_at': '2026-07-25T08:00:00Z',
  };

  Response<Map<String, dynamic>> resp(Map<String, dynamic> data) =>
      Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: ApiEndpoints.reminders),
        data: {
          'success': true,
          'code': 200,
          'timestamp': '2026-07-25T08:00:00Z',
          ...data,
        },
      );

  group('listReminders', () {
    test('đọc body[\'data\'] as List và trả về đúng danh sách', () async {
      when(
        () => client.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => resp({
          'data': [reminderJson('r-1'), reminderJson('r-2')],
        }),
      );

      final result = await datasource.listReminders();

      expect(result, hasLength(2));
      expect(result.map((e) => e.id), ['r-1', 'r-2']);
    });

    test('KHÔNG gửi page/page_size trong queryParameters', () async {
      when(
        () => client.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => resp({
          'data': [reminderJson('r-1')],
        }),
      );

      await datasource.listReminders(
        status: ReminderStatus.pending,
        targetType: ReminderTargetType.invoice,
      );

      final params =
          verify(
                () => client.get<Map<String, dynamic>>(
                  ApiEndpoints.reminders,
                  queryParameters: captureAny(named: 'queryParameters'),
                ),
              ).captured.single
              as Map<String, dynamic>;

      expect(params.containsKey('page'), isFalse);
      expect(params.containsKey('page_size'), isFalse);
      expect(params['status'], 'pending');
      expect(params['target_type'], 'invoice');
    });

    test('không truyền filter thì queryParameters rỗng', () async {
      when(
        () => client.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => resp({'data': <dynamic>[]}));

      await datasource.listReminders();

      final params =
          verify(
                () => client.get<Map<String, dynamic>>(
                  ApiEndpoints.reminders,
                  queryParameters: captureAny(named: 'queryParameters'),
                ),
              ).captured.single
              as Map<String, dynamic>;

      expect(params, isEmpty);
    });
  });

  test('getReminder GET /reminders/{id} và giải nén envelope', () async {
    when(
      () => client.get<Map<String, dynamic>>(any()),
    ).thenAnswer((_) async => resp({'data': reminderJson('r-1')}));

    final result = await datasource.getReminder('r-1');

    expect(result.id, 'r-1');
    verify(
      () => client.get<Map<String, dynamic>>(ApiEndpoints.reminderById('r-1')),
    ).called(1);
  });

  test('createReminder POST /reminders với body đúng', () async {
    when(
      () => client.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
    ).thenAnswer((_) async => resp({'data': reminderJson('r-1')}));

    final result = await datasource.createReminder(
      const ReminderRequestDto(
        targetType: 'invoice',
        targetId: 'inv-1',
        reminderType: 'payment_due',
        channel: 'zalo',
        scheduledAt: '2026-07-28T09:00:00Z',
      ),
    );

    expect(result.id, 'r-1');
    final captured =
        verify(
              () => client.post<Map<String, dynamic>>(
                ApiEndpoints.reminders,
                data: captureAny(named: 'data'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(captured['target_type'], 'invoice');
    expect(captured['target_id'], 'inv-1');
  });

  test('updateReminder PATCH /reminders/{id} với body đúng', () async {
    when(
      () => client.patch<Map<String, dynamic>>(any(), data: any(named: 'data')),
    ).thenAnswer((_) async => resp({'data': reminderJson('r-1')}));

    final result = await datasource.updateReminder(
      'r-1',
      const ReminderRequestDto(
        targetType: 'invoice',
        targetId: 'inv-1',
        reminderType: 'payment_due',
        channel: 'email',
        scheduledAt: '2026-07-29T09:00:00Z',
      ),
    );

    expect(result.id, 'r-1');
    final captured =
        verify(
              () => client.patch<Map<String, dynamic>>(
                ApiEndpoints.reminderById('r-1'),
                data: captureAny(named: 'data'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(captured['channel'], 'email');
  });

  test('cancelReminder DELETE /reminders/{id}', () async {
    when(
      () => client.delete<Map<String, dynamic>>(any()),
    ).thenAnswer((_) async => resp({}));

    await datasource.cancelReminder('r-1');

    verify(
      () =>
          client.delete<Map<String, dynamic>>(ApiEndpoints.reminderById('r-1')),
    ).called(1);
  });
}
