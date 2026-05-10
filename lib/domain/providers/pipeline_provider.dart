import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/domain/models/deal.dart';
import 'package:mobile/domain/models/pipeline_stage.dart';
import 'package:mobile/domain/providers/deal_provider.dart';

/// Provider tổng hợp pipeline stages với thống kê deal.
final pipelineStagesProvider =
    FutureProvider<List<PipelineStage>>((ref) async {
  final deals = await ref.watch(dealsProvider.future);

  return AppConstants.pipelineStages.map((stageInfo) {
    final stageDeals =
        deals.where((d) => d.stageId == stageInfo.id).toList();
    final totalValue =
        stageDeals.fold<double>(0, (sum, d) => sum + d.value);

    return PipelineStage(
      id: stageInfo.id,
      name: stageInfo.nameVi,
      order: stageInfo.order,
      dealCount: stageDeals.length,
      totalValue: totalValue,
    );
  }).toList();
});

/// Provider trả về tất cả deals, nhóm theo stage ID.
final dealsByStageMapProvider =
    FutureProvider<Map<String, List<Deal>>>((ref) async {
  final deals = await ref.watch(dealsProvider.future);
  final map = <String, List<Deal>>{};
  for (final deal in deals) {
    map.putIfAbsent(deal.stageId, () => []).add(deal);
  }
  return map;
});
