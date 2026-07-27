import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal_content.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_status.dart';

part 'proposal.freezed.dart';

/// Một báo giá (proposal) gắn với một deal. Entity domain thuần — trường mirror
/// theo `ProposalResponse` phía backend (`/proposals`).
@freezed
abstract class Proposal with _$Proposal {
  const factory Proposal({
    required String id,
    required String dealId,
    required String ownerUserId,
    required int versionNumber,
    required ProposalStatus status,
    required ProposalContent content,
    required bool aiGenerated,
    required DateTime createdAt,
    String? shareToken,
    DateTime? shareExpiresAt,
    DateTime? sentAt,
    DateTime? respondedAt,
    DateTime? updatedAt,
  }) = _Proposal;
}

extension ProposalX on Proposal {
  /// Số hiển thị trên MÀN 08, dạng `'BG-<năm tạo>-<4 ký tự cuối id>'`.
  /// Ví dụ id `'p-2026-0042'`, tạo năm 2026 -> `'BG-2026-0042'`.
  String get displayNumber {
    final last4 = id.length >= 4 ? id.substring(id.length - 4) : id;
    return 'BG-${createdAt.year}-$last4';
  }
}
