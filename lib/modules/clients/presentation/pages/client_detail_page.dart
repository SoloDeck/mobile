import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/presentation/pages/clients_page.dart';
import 'package:solodesk_mobile/modules/clients/presentation/providers/clients_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// Read-only detail view for a single client.
class ClientDetailPage extends ConsumerWidget {
  const ClientDetailPage({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientDetailProvider(clientId));
    final appearance = ref.watch(appearanceControllerProvider);

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: Scaffold(
        appBar: AppBar(title: Text(client.value?.name ?? 'Chi tiết khách hàng')),
        body: AsyncValueWidget<Client>(
          value: client,
          onRetry: () => ref.invalidate(clientDetailProvider(clientId)),
          data: (c) => ListView(
            padding: const EdgeInsets.all(AppGap.screen),
            children: [
              Text(c.name, style: AppText.titleSm),
              const SizedBox(height: AppGap.xs),
              Wrap(
                spacing: AppGap.betweenChips,
                children: [
                  StatusChip(c.type.label, tone: Tone.neutral),
                  StatusChip(c.status.label, tone: _statusTone(c.status)),
                ],
              ),
              const Divider(height: 32),
              _DetailRow(label: 'Email', value: c.email),
              _DetailRow(label: 'Điện thoại', value: c.phone),
              _DetailRow(label: 'Số thương vụ', value: '${c.dealCount}'),
              // Placeholder rows for future money fields (from API)
              if (false) ...[
                _DetailRow(label: 'Công nợ', value: null),
                _DetailRow(label: 'Doanh thu', value: null),
              ],
              _DetailRow(label: 'Mô tả', value: c.description),
              _DetailRow(label: 'Ghi chú', value: c.notes),
            ],
          ),
        ),
      ),
    );
  }

  Tone _statusTone(ClientStatus status) => switch (status) {
    ClientStatus.prospect => Tone.neutral,
    ClientStatus.active => Tone.ok,
    ClientStatus.inactive => Tone.warn,
    ClientStatus.archived => Tone.neutral,
  };
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppGap.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppText.bodyStrong,
            ),
          ),
          Expanded(child: Text(value?.isNotEmpty == true ? value! : '—', style: AppText.body)),
        ],
      ),
    );
  }
}
