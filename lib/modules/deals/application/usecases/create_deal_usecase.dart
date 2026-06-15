import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deals_repository.dart';

class CreateDealUseCase {
  const CreateDealUseCase(this._repository);

  final DealsRepository _repository;

  Future<Deal> call({
    required String clientId,
    required String title,
    DealSource? source,
    double? estimatedValue,
    String? currency,
    String? notes,
  }) => _repository.createDeal(
    clientId: clientId,
    title: title,
    source: source,
    estimatedValue: estimatedValue,
    currency: currency,
    notes: notes,
  );
}
