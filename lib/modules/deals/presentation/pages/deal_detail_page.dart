import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/presentation/controllers/deals_controller.dart';
import 'package:solodesk_mobile/modules/deals/presentation/providers/deals_provider.dart';
import 'package:solodesk_mobile/shared/utils/currency_formatter.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';

/// Deal detail with the value, client and the legal next-stage transition
/// buttons (forward-only pipeline).
class DealDetailPage extends ConsumerWidget {
  const DealDetailPage({super.key, required this.dealId});

  final String dealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deal = ref.watch(dealDetailProvider(dealId));

    ref.listen(dealStageControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết thương vụ')),
      body: AsyncValueWidget<Deal>(
        value: deal,
        onRetry: () => ref.invalidate(dealDetailProvider(dealId)),
        data: (d) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(d.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Chip(label: Text(d.stage.label)),
            const Divider(height: 32),
            _DetailRow(label: 'Khách hàng', value: d.clientName ?? d.clientId),
            _DetailRow(
              label: 'Giá trị ước tính',
              value: d.estimatedValue == null
                  ? '—'
                  : formatVnd(d.estimatedValue!),
            ),
            _DetailRow(
              label: 'Giá trị thực tế',
              value: d.actualValue == null ? '—' : formatVnd(d.actualValue!),
            ),
            _DetailRow(label: 'Ghi chú', value: d.notes ?? '—'),
            const Divider(height: 32),
            _StageTransitions(deal: d),
          ],
        ),
      ),
    );
  }
}

class _StageTransitions extends ConsumerWidget {
  const _StageTransitions({required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextStages = deal.stage.nextStages;
    final isBusy = ref.watch(dealStageControllerProvider).isLoading;

    if (nextStages.isEmpty) {
      return const Text('Thương vụ đã ở trạng thái kết thúc.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chuyển trạng thái',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final target in nextStages)
              FilledButton.tonal(
                onPressed: isBusy
                    ? null
                    : () => ref
                          .read(dealStageControllerProvider.notifier)
                          .transition(
                            dealId: deal.id,
                            currentStage: deal.stage,
                            targetStage: target,
                          ),
                child: Text(target.label),
              ),
          ],
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
