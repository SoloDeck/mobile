import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deals_repository.dart';

class ListDealsUseCase {
  const ListDealsUseCase(this._repository);

  final DealsRepository _repository;

  Future<List<Deal>> call({DealStage? stage}) =>
      _repository.listDeals(stage: stage);
}
