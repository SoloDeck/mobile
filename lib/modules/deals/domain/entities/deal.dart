import 'package:freezed_annotation/freezed_annotation.dart';

part 'deal.freezed.dart';

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

enum DealSource {
  @JsonValue('inbound')
  inbound,
  @JsonValue('referral')
  referral,
  @JsonValue('outreach')
  outreach,
  @JsonValue('platform')
  platform,
  @JsonValue('other')
  other,
}

extension DealStageX on DealStage {
  bool get isTerminal =>
      this == DealStage.completedAndBilled || this == DealStage.lost;

  /// Forward-only pipeline. Any non-terminal stage may move to `lost`; otherwise
  /// only the immediately following stage is reachable. Mirrors the backend's
  /// `Deal.can_transition_to()` rule.
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

  /// The set of stages this deal may legally move to next.
  List<DealStage> get nextStages =>
      DealStage.values.where(canTransitionTo).toList();

  /// Snake-case value the backend expects (matches the `@JsonValue` strings),
  /// used for query parameters where the enum is sent as a raw string.
  String get wireValue => switch (this) {
    DealStage.newLead => 'new_lead',
    DealStage.qualified => 'qualified',
    DealStage.proposalSent => 'proposal_sent',
    DealStage.inNegotiation => 'in_negotiation',
    DealStage.active => 'active',
    DealStage.completedAndBilled => 'completed_and_billed',
    DealStage.lost => 'lost',
  };

  String get label => switch (this) {
    DealStage.newLead => 'Khách mới',
    DealStage.qualified => 'Đã sàng lọc',
    DealStage.proposalSent => 'Đã gửi báo giá',
    DealStage.inNegotiation => 'Đang đàm phán',
    DealStage.active => 'Đang triển khai',
    DealStage.completedAndBilled => 'Hoàn tất & xuất hóa đơn',
    DealStage.lost => 'Đã mất',
  };
}

/// A sales opportunity (thương vụ). Pure domain entity — fields mirror the
/// backend `DealResponse` contract (`/deals`).
@freezed
abstract class Deal with _$Deal {
  const factory Deal({
    required String id,
    required String ownerUserId,
    required String clientId,
    required String title,
    required DealStage stage,
    required DateTime createdAt,
    String? clientName,
    DealSource? source,
    double? estimatedValue,
    double? actualValue,
    @Default('VND') String currency,
    String? notes,
    DateTime? closedAt,
    DateTime? updatedAt,
  }) = _Deal;
}
