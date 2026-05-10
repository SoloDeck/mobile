import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/repositories/mock_deal_repository.dart';
import 'package:mobile/domain/models/deal.dart';
import 'package:mobile/domain/repositories/deal_repository.dart';

/// Provider cho [DealRepository].
final dealRepositoryProvider = Provider<DealRepository>((ref) {
  return MockDealRepository();
});

/// Provider lấy tất cả deals.
final dealsProvider = FutureProvider<List<Deal>>((ref) async {
  final repo = ref.read(dealRepositoryProvider);
  return repo.getDeals();
});

/// Provider lấy deals theo stage.
final dealsByStageProvider =
    FutureProvider.family<List<Deal>, String>((ref, stageId) async {
  final repo = ref.read(dealRepositoryProvider);
  return repo.getDealsByStage(stageId);
});
