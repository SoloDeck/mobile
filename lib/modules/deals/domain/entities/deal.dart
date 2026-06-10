import 'package:freezed_annotation/freezed_annotation.dart';

part 'deal.freezed.dart';
part 'deal.g.dart';

enum DealStage {
  @JsonValue('new_lead')
  newLead,
  @JsonValue('qualified')
  qualified,
  @JsonValue('proposal_sent')
  proposalSent,
  @JsonValue('in_negotiation')
  inNegotiation,
  @JsonValue('active')
  active,
  @JsonValue('completed_and_billed')
  completedAndBilled,
  @JsonValue('lost')
  lost,
}

extension DealStageX on DealStage {
  bool get isTerminal =>
      this == DealStage.completedAndBilled || this == DealStage.lost;

  bool canTransitionTo(DealStage target) {
    if (isTerminal) return false;
    if (target == DealStage.lost) return true;
    const order = [
      DealStage.newLead,
      DealStage.qualified,
      DealStage.proposalSent,
      DealStage.inNegotiation,
      DealStage.active,
      DealStage.completedAndBilled,
    ];
    final currentIdx = order.indexOf(this);
    final targetIdx = order.indexOf(target);
    return targetIdx == currentIdx + 1;
  }
}

@freezed
abstract class Deal with _$Deal {
  const factory Deal({
    required String id,
    required String title,
    required String clientId,
    required DealStage stage,
    required DateTime createdAt,
    required DateTime updatedAt,
    double? estimatedValue,
    String? currency,
    String? notes,
    DateTime? closedAt,
  }) = _Deal;

  factory Deal.fromJson(Map<String, dynamic> json) => _$DealFromJson(json);
}
