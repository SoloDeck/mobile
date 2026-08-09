import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/value_objects/deal_activity_type.dart';

part 'deal_activity.freezed.dart';

/// One append-only entry in a deal's activity timeline.
///
/// Backend never updates these rows after insert — safe to treat as
/// immutable history, not live state.
@freezed
abstract class DealActivity with _$DealActivity {
  const factory DealActivity({
    required String id,
    required String dealId,
    required DealActivityType entryType,
    required String description,
    required DateTime createdAt,
    DealStage? previousStage,
    DealStage? newStage,
  }) = _DealActivity;
}
