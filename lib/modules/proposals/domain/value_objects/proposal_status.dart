import 'package:freezed_annotation/freezed_annotation.dart';

/// Trạng thái vòng đời của báo giá (proposal). Mirrors the backend
/// `ProposalStatus` enum.
enum ProposalStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('sent')
  sent,
  @JsonValue('accepted')
  accepted,
  @JsonValue('rejected')
  rejected,
  @JsonValue('expired')
  expired,
  @JsonValue('superseded')
  superseded,
}

extension ProposalStatusX on ProposalStatus {
  /// Snake-case value backend mong đợi (khớp chuỗi `@JsonValue`).
  String get wireValue => switch (this) {
    ProposalStatus.draft => 'draft',
    ProposalStatus.sent => 'sent',
    ProposalStatus.accepted => 'accepted',
    ProposalStatus.rejected => 'rejected',
    ProposalStatus.expired => 'expired',
    ProposalStatus.superseded => 'superseded',
  };

  String get label => switch (this) {
    ProposalStatus.draft => 'Bản nháp',
    ProposalStatus.sent => 'Đã gửi',
    ProposalStatus.accepted => 'Đã chấp nhận',
    ProposalStatus.rejected => 'Đã từ chối',
    ProposalStatus.expired => 'Hết hạn',
    ProposalStatus.superseded => 'Bản cũ',
  };

  /// Chỉ bản nháp mới được sửa nội dung.
  bool get canEdit => this == ProposalStatus.draft;

  /// Chỉ bản nháp mới được gửi đi.
  bool get canSend => this == ProposalStatus.draft;

  /// Trạng thái cuối — không còn hành động chuyển trạng thái nào khác.
  bool get isTerminal =>
      this == ProposalStatus.accepted ||
      this == ProposalStatus.rejected ||
      this == ProposalStatus.expired ||
      this == ProposalStatus.superseded;

  /// Máy trạng thái phía backend: `draft` -> `{sent}`; `sent` ->
  /// `{accepted, rejected, expired}`; các trạng thái còn lại (đã là trạng
  /// thái cuối) -> rỗng.
  Set<ProposalStatus> get allowedTargets => switch (this) {
    ProposalStatus.draft => const {ProposalStatus.sent},
    ProposalStatus.sent => const {
      ProposalStatus.accepted,
      ProposalStatus.rejected,
      ProposalStatus.expired,
    },
    ProposalStatus.accepted ||
    ProposalStatus.rejected ||
    ProposalStatus.expired ||
    ProposalStatus.superseded => const {},
  };
}

ProposalStatus proposalStatusFromWire(String value) => switch (value) {
  'draft' => ProposalStatus.draft,
  'sent' => ProposalStatus.sent,
  'accepted' => ProposalStatus.accepted,
  'rejected' => ProposalStatus.rejected,
  'expired' => ProposalStatus.expired,
  'superseded' => ProposalStatus.superseded,
  _ => throw ArgumentError.value(value, 'value', 'Unknown proposal status'),
};
