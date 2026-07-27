import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal_content.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_status.dart';

extension ProposalRowMapper on ProposalRow {
  Proposal toDomain() => Proposal(
    id: id,
    dealId: dealId,
    ownerUserId: ownerUserId,
    versionNumber: versionNumber,
    status: proposalStatusFromWire(status),
    content: ProposalContentX.fromMap(
      jsonDecode(contentJson) as Map<String, dynamic>,
    ),
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

extension ProposalToRowMapper on Proposal {
  // `clientName` không nằm trong entity `Proposal` (entity domain không biết
  // gì về deal/client) nên cột này luôn ghi null khi cache — chấp nhận được ở
  // phase này vì danh sách ngoại tuyến vẫn hiển thị đúng số báo giá và trạng
  // thái, chỉ thiếu tên khách.
  ProposalRowsCompanion toRow() => ProposalRowsCompanion(
    id: Value(id),
    dealId: Value(dealId),
    ownerUserId: Value(ownerUserId),
    versionNumber: Value(versionNumber),
    status: Value(status.wireValue),
    contentJson: Value(jsonEncode(content.toMap())),
    aiGenerated: Value(aiGenerated),
    createdAt: Value(createdAt.toIso8601String()),
    shareToken: Value(shareToken),
    shareExpiresAt: Value(shareExpiresAt?.toIso8601String()),
    sentAt: Value(sentAt?.toIso8601String()),
    respondedAt: Value(respondedAt?.toIso8601String()),
    updatedAt: Value(updatedAt?.toIso8601String()),
  );
}
