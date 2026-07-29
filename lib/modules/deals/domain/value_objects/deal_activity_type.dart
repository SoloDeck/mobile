import 'package:freezed_annotation/freezed_annotation.dart';

/// Kind of entry in a deal's activity log (`entry_type`). Wire values mirror
/// the backend `DealActivityType` enum
/// (`backend/src/modules/deals/domain/entities/deal_activity.py`).
enum DealActivityType {
  @JsonValue('stage_change')
  stageChange,
  @JsonValue('note_added')
  noteAdded,
  @JsonValue('document_attached')
  documentAttached,
  @JsonValue('ai_qualification')
  aiQualification,
}

extension DealActivityTypeX on DealActivityType {
  String get wireValue => switch (this) {
    DealActivityType.stageChange => 'stage_change',
    DealActivityType.noteAdded => 'note_added',
    DealActivityType.documentAttached => 'document_attached',
    DealActivityType.aiQualification => 'ai_qualification',
  };

  static DealActivityType fromWire(String value) => switch (value) {
    'stage_change' => DealActivityType.stageChange,
    'note_added' => DealActivityType.noteAdded,
    'document_attached' => DealActivityType.documentAttached,
    'ai_qualification' => DealActivityType.aiQualification,
    _ => throw ArgumentError.value(value, 'value', 'Unknown deal activity type'),
  };

  String get label => switch (this) {
    DealActivityType.stageChange => 'Đổi giai đoạn',
    DealActivityType.noteAdded => 'Ghi chú mới',
    DealActivityType.documentAttached => 'Đính kèm tài liệu',
    DealActivityType.aiQualification => 'AI chấm điểm',
  };
}
