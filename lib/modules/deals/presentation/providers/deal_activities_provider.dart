import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/deals/application/usecases/list_deal_activities_usecase.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal_activity.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/repository/deal_activities_repository_impl.dart';

part 'deal_activities_provider.g.dart';

@riverpod
Future<List<DealActivity>> dealActivities(Ref ref, String dealId) {
  final useCase = ListDealActivitiesUseCase(
    ref.watch(dealActivitiesRepositoryProvider),
  );
  return useCase(dealId);
}
