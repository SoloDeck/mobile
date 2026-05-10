import 'package:mobile/domain/models/deal.dart';

/// Interface cho repository quản lý Deal.
abstract class DealRepository {
  /// Lấy tất cả deals.
  Future<List<Deal>> getDeals();

  /// Lấy deals theo giai đoạn pipeline.
  Future<List<Deal>> getDealsByStage(String stageId);

  /// Lấy chi tiết một deal.
  Future<Deal> getDealById(String id);

  /// Cập nhật giai đoạn pipeline của deal.
  Future<Deal> updateDealStage(String dealId, String newStageId);
}
