import 'package:drift/drift.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';

extension DealRowMapper on DealRow {
  Deal toDomain() => Deal(
    id: id,
    ownerUserId: ownerUserId,
    clientId: clientId,
    title: title,
    stage: _stageFromWire(stage),
    createdAt: DateTime.parse(createdAt),
    clientName: clientName,
    source: source == null ? null : DealSource.values.byName(source!),
    estimatedValue: estimatedValue,
    actualValue: actualValue,
    currency: currency,
    notes: notes,
    closedAt: closedAt == null ? null : DateTime.parse(closedAt!),
    updatedAt: updatedAt == null ? null : DateTime.parse(updatedAt!),
  );
}

extension DealToRowMapper on Deal {
  DealRowsCompanion toRow() => DealRowsCompanion(
    id: Value(id),
    ownerUserId: Value(ownerUserId),
    clientId: Value(clientId),
    title: Value(title),
    stage: Value(stage.wireValue),
    createdAt: Value(createdAt.toIso8601String()),
    clientName: Value(clientName),
    source: Value(source?.name),
    estimatedValue: Value(estimatedValue),
    actualValue: Value(actualValue),
    currency: Value(currency),
    notes: Value(notes),
    closedAt: Value(closedAt?.toIso8601String()),
    updatedAt: Value(updatedAt?.toIso8601String()),
  );
}

DealStage _stageFromWire(String value) => switch (value) {
  'new_lead' => DealStage.newLead,
  'qualified' => DealStage.qualified,
  'proposal_sent' => DealStage.proposalSent,
  'in_negotiation' => DealStage.inNegotiation,
  'active' => DealStage.active,
  'completed_and_billed' => DealStage.completedAndBilled,
  'lost' => DealStage.lost,
  _ => throw ArgumentError.value(value, 'value', 'Unknown deal stage'),
};
