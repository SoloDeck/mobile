import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal_content.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_status.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/dto/proposal_response_dto.dart';

extension ProposalResponseDtoMapper on ProposalResponseDto {
  Proposal toDomain() => Proposal(
    id: id,
    dealId: dealId,
    ownerUserId: ownerUserId,
    versionNumber: versionNumber,
    status: proposalStatusFromWire(status),
    content: ProposalContentX.fromMap(content),
    aiGenerated: aiGenerated,
    createdAt: DateTime.parse(createdAt),
    shareToken: shareToken,
    shareExpiresAt: shareExpiresAt == null
        ? null
        : DateTime.parse(shareExpiresAt!),
    sentAt: sentAt == null ? null : DateTime.parse(sentAt!),
    respondedAt: respondedAt == null ? null : DateTime.parse(respondedAt!),
    updatedAt: updatedAt == null ? null : DateTime.parse(updatedAt!),
  );
}
