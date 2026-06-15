import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/dto/deal_response_dto.dart';

extension DealResponseDtoMapper on DealResponseDto {
  Deal toDomain() => Deal(
    id: id,
    ownerUserId: ownerUserId,
    clientId: clientId,
    title: title,
    stage: stage,
    clientName: clientName,
    source: source,
    estimatedValue: estimatedValue,
    actualValue: actualValue,
    currency: currency,
    notes: notes,
    closedAt: closedAt == null ? null : DateTime.parse(closedAt!),
    createdAt: DateTime.parse(createdAt),
    updatedAt: updatedAt == null ? null : DateTime.parse(updatedAt!),
  );
}
