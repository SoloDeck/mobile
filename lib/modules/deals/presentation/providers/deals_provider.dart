import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/deals/application/usecases/get_deal_usecase.dart';
import 'package:solodesk_mobile/modules/deals/application/usecases/list_deals_usecase.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/value_objects/pipeline_summary.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/repository/deals_repository_impl.dart';

part 'deals_provider.g.dart';

/// All deals owned by the authenticated user.
@riverpod
Future<List<Deal>> dealList(Ref ref) {
  final useCase = ListDealsUseCase(ref.watch(dealsRepositoryProvider));
  return useCase();
}

/// Deals grouped into one summary card per pipeline stage (count + total value).
@riverpod
Future<List<StageSummary>> dealPipeline(Ref ref) async {
  final deals = await ref.watch(dealListProvider.future);
  return buildPipelineSummary(deals);
}

/// A single deal by id, used by the detail page.
@riverpod
Future<Deal> dealDetail(Ref ref, String id) {
  final useCase = GetDealUseCase(ref.watch(dealsRepositoryProvider));
  return useCase(id);
}
