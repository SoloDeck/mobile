import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_status.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_target_type.dart';
import 'package:solodesk_mobile/modules/reminders/infrastructure/dto/reminder_request_dto.dart';
import 'package:solodesk_mobile/modules/reminders/infrastructure/dto/reminder_response_dto.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';
import 'package:solodesk_mobile/shared/models/api_response.dart';

class RemindersRemoteDatasource {
  const RemindersRemoteDatasource(this._client);

  final ApiClient _client;

  /// `GET /reminders` trả `{success, ..., data: [...]}` — KHÔNG có
  /// `pagination`, khác hẳn invoices/proposals. TUYỆT ĐỐI KHÔNG gửi
  /// `page`/`page_size` (API không nhận tham số này).
  Future<List<ReminderResponseDto>> listReminders({
    ReminderStatus? status,
    ReminderTargetType? targetType,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.reminders,
      queryParameters: {
        if (status != null) 'status': status.wireValue,
        if (targetType != null) 'target_type': targetType.wireValue,
      },
    );
    final body = response.data!;
    final items = body['data'] as List<dynamic>;
    return items
        .map((e) => ReminderResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ReminderResponseDto> getReminder(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.reminderById(id),
    );
    return _unwrap(response.data!);
  }

  Future<ReminderResponseDto> createReminder(ReminderRequestDto dto) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.reminders,
      data: dto.toJson(),
    );
    return _unwrap(response.data!);
  }

  Future<ReminderResponseDto> updateReminder(
    String id,
    ReminderRequestDto dto,
  ) async {
    final response = await _client.patch<Map<String, dynamic>>(
      ApiEndpoints.reminderById(id),
      data: dto.toJson(),
    );
    return _unwrap(response.data!);
  }

  /// = DELETE, huỷ mềm ở backend (`status='cancelled'`).
  Future<void> cancelReminder(String id) async {
    await _client.delete<Map<String, dynamic>>(ApiEndpoints.reminderById(id));
  }

  ReminderResponseDto _unwrap(Map<String, dynamic> body) {
    final envelope = ApiResponse.fromJson(
      body,
      (json) => ReminderResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }
}
