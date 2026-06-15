import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/presentation/pages/clients_page.dart';
import 'package:solodesk_mobile/modules/clients/presentation/providers/clients_provider.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';

/// Read-only detail view for a single client.
class ClientDetailPage extends ConsumerWidget {
  const ClientDetailPage({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientDetailProvider(clientId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết khách hàng')),
      body: AsyncValueWidget<Client>(
        value: client,
        onRetry: () => ref.invalidate(clientDetailProvider(clientId)),
        data: (c) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              c.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text(c.type.label)),
                Chip(label: Text(c.status.label)),
              ],
            ),
            const Divider(height: 32),
            _DetailRow(label: 'Email', value: c.email),
            _DetailRow(label: 'Điện thoại', value: c.phone),
            _DetailRow(label: 'Số thương vụ', value: '${c.dealCount}'),
            _DetailRow(label: 'Mô tả', value: c.description),
            _DetailRow(label: 'Ghi chú', value: c.notes),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value?.isNotEmpty == true ? value! : '—')),
        ],
      ),
    );
  }
}
