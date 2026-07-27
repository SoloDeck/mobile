import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_channel.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_tone.dart';

part 'reminder_draft.freezed.dart';

/// Trạng thái soạn thảo thuần client — KHÔNG có bản ghi backend tương ứng cho
/// tới khi bấm "Gửi ngay". [tone] chỉ ảnh hưởng tới nội dung soạn ra, không
/// bao giờ gửi lên backend.
@freezed
abstract class ReminderDraft with _$ReminderDraft {
  const factory ReminderDraft({
    @Default(ReminderTone.polite) ReminderTone tone,
    @Default(ReminderChannel.zalo) ReminderChannel channel,
    @Default('') String body,
    @Default(true) bool attachPaymentLink,
    // null = tắt "tự nhắc lại"; ví dụ 3 = bật, sau 3 ngày.
    int? repeatAfterDays,
  }) = _ReminderDraft;
}

extension ReminderDraftX on ReminderDraft {
  /// "Tự nhắc lại" đang bật khi có số ngày lặp lại.
  bool get repeatEnabled => repeatAfterDays != null;
}
