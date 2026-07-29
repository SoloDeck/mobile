import 'package:solodesk_mobile/modules/deals/domain/entities/deal_activity.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/dto/deal_activity_response_dto.dart';

extension DealActivityResponseDtoMapper on DealActivityResponseDto {
  DealActivity toDomain() => DealActivity(
    id: id,
    dealId: dealId,
    entryType: entryType,
    description: description,
    createdAt: DateTime.parse(createdAt),
    previousStage: previousStage,
    newStage: newStage,
  );
}
