import 'package:solodesk_mobile/modules/deals/domain/entities/deal_activity.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deal_activities_repository.dart';

class ListDealActivitiesUseCase {
  const ListDealActivitiesUseCase(this._repository);

  final DealActivitiesRepository _repository;

  Future<List<DealActivity>> call(String dealId) =>
      _repository.listActivities(dealId);
}
