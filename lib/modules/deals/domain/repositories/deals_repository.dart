import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';

/// Contract for reading, creating and advancing deals. Implemented in
/// `infrastructure/repository/deals_repository_impl.dart`.
abstract interface class DealsRepository {
  Future<List<Deal>> listDeals({DealStage? stage});

  Future<Deal> getDeal(String id);

  Future<Deal> createDeal({
    required String clientId,
    required String title,
    DealSource? source,
    double? estimatedValue,
    String? currency,
    String? notes,
  });

  Future<Deal> transitionStage({
    required String id,
    required DealStage targetStage,
    String? note,
  });
}
