import 'package:freezed_annotation/freezed_annotation.dart';

part 'checklist_item.freezed.dart';

/// A single checklist item belonging to a task. Pure domain entity mirroring the
/// backend `ChecklistItemResponse` contract.
@freezed
abstract class ChecklistItem with _$ChecklistItem {
  const factory ChecklistItem({
    required String id,
    required String taskId,
    required String text,
    required bool isDone,
    required int position,
  }) = _ChecklistItem;
}
