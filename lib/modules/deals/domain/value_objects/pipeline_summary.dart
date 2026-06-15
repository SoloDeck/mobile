import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';

/// Aggregated view of the deals sitting in one pipeline stage — backs the
/// pipeline overview's per-stage summary cards (count + total value).
class StageSummary {
  const StageSummary({required this.stage, required this.deals});

  final DealStage stage;
  final List<Deal> deals;

  int get count => deals.length;

  /// Sum of each deal's value, preferring `estimatedValue`, then `actualValue`.
  double get totalValue => deals.fold(
    0,
    (sum, deal) => sum + (deal.estimatedValue ?? deal.actualValue ?? 0),
  );
}

/// Groups deals into one [StageSummary] per pipeline stage, preserving the
/// canonical stage order. Stages with no deals produce an empty summary.
List<StageSummary> buildPipelineSummary(List<Deal> deals) => [
  for (final stage in DealStage.values)
    StageSummary(
      stage: stage,
      deals: deals.where((deal) => deal.stage == stage).toList(),
    ),
];
