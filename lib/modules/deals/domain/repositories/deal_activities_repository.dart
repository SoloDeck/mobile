import 'package:solodesk_mobile/modules/deals/domain/entities/deal_activity.dart';

abstract interface class DealActivitiesRepository {
  Future<List<DealActivity>> listActivities(String dealId);
}
