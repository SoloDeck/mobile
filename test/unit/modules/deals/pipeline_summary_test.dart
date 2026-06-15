import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/value_objects/pipeline_summary.dart';

Deal _deal(String id, DealStage stage, {double? value}) => Deal(
  id: id,
  ownerUserId: 'owner-1',
  clientId: 'client-1',
  title: 'Deal $id',
  stage: stage,
  createdAt: DateTime.utc(2026, 6, 14),
  estimatedValue: value,
);

void main() {
  group('buildPipelineSummary', () {
    test('groups deals by stage with the correct count and total value', () {
      final deals = [
        _deal('1', DealStage.newLead, value: 1000),
        _deal('2', DealStage.newLead, value: 2000),
        _deal('3', DealStage.active, value: 5000),
      ];

      final summaries = buildPipelineSummary(deals);

      final newLead = summaries.firstWhere((s) => s.stage == DealStage.newLead);
      expect(newLead.count, 2);
      expect(newLead.totalValue, 3000);

      final active = summaries.firstWhere((s) => s.stage == DealStage.active);
      expect(active.count, 1);
      expect(active.totalValue, 5000);
    });

    test('emits one summary per stage, in canonical order', () {
      final summaries = buildPipelineSummary([]);

      expect(
        summaries.map((s) => s.stage).toList(),
        DealStage.values,
      );
      expect(summaries.every((s) => s.count == 0), isTrue);
      expect(summaries.every((s) => s.totalValue == 0), isTrue);
    });
  });
}
