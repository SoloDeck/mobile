import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deals_repository.dart';

class GetDealUseCase {
  const GetDealUseCase(this._repository);

  final DealsRepository _repository;

  Future<Deal> call(String id) => _repository.getDeal(id);
}
