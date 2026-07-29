import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal_attachment.dart';
import 'package:solodesk_mobile/modules/deals/presentation/controllers/deal_attachment_controller.dart';
import 'package:solodesk_mobile/modules/deals/presentation/providers/deal_attachments_provider.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';
import 'package:solodesk_mobile/shared/extensions/context_extensions.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/perforated_divider.dart';
import 'package:solodesk_mobile/ui/section_header.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// Tab "Tài liệu" của màn chi tiết thương vụ — danh sách file đính kèm nối
/// `GET/POST/DELETE /deals/{id}/attachments` + `GET
/// /deals/attachments/{id}/download`. Bốn endpoint này KHÔNG có trong
/// `contracts/openapi.yaml` (spec chỉ tả luồng `/deals/{id}/document` một
/// file duy nhất) — shape lấy từ router backend thật, đã được web dùng ở
/// `web/src/services/dealAttachmentsService.ts`.
class DealAttachmentsTab extends ConsumerWidget {
  const DealAttachmentsTab({super.key, required this.dealId});

  final String dealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(dealAttachmentControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        final error = next.error;
        context.showSnackBar(
          error is AppException
              ? error.message
              : 'Có lỗi khi xử lý tệp. Thử lại sau.',
          isError: true,
        );
      }
    });

    final attachmentsAsync = ref.watch(dealAttachmentsProvider(dealId));
    final isBusy = ref.watch(dealAttachmentControllerProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppGap.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            'Tài liệu',
            actionLabel: 'Thêm tệp',
            onAction: isBusy
                ? null
                : () => ref
                      .read(dealAttachmentControllerProvider.notifier)
                      .pickAndUpload(dealId),
          ),
          const SizedBox(height: AppGap.lg),
          AsyncValueWidget<List<DealAttachment>>(
            value: attachmentsAsync,
            onRetry: () => ref.invalidate(dealAttachmentsProvider(dealId)),
            loadingWidget: const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            ),
            data: (attachments) {
              if (attachments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppGap.xl),
                  child: Center(
                    child: Text(
                      'Chưa có tài liệu nào cho thương vụ này.',
                      style: AppText.mut,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppGap.card,
                    vertical: AppGap.sm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < attachments.length; i++) ...[
                        _AttachmentRow(
                          dealId: dealId,
                          attachment: attachments[i],
                          busy: isBusy,
                        ),
                        if (i < attachments.length - 1)
                          const PerforatedDivider(),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AttachmentRow extends ConsumerWidget {
  const _AttachmentRow({
    required this.dealId,
    required this.attachment,
    required this.busy,
  });

  final String dealId;
  final DealAttachment attachment;
  final bool busy;

  Future<void> _download(BuildContext context, WidgetRef ref) async {
    final path = await ref
        .read(dealAttachmentControllerProvider.notifier)
        .downloadAndOpen(attachment);
    if (!context.mounted) return;
    if (path == null) {
      context.showSnackBar('Không mở được tệp này.', isError: true);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xoá tài liệu'),
        content: Text('Xoá "${attachment.filename}"? Không thể khôi phục.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Huỷ bỏ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(dealAttachmentControllerProvider.notifier)
        .delete(dealId: dealId, attachmentId: attachment.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppGap.sm),
      child: Row(
        children: [
          const SoloIcon(
            SoloIcons.file,
            label: null,
            size: SoloIcon.sm,
            color: AppColors.ink3,
          ),
          const SizedBox(width: AppGap.row),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  attachment.filename,
                  style: AppText.bodyStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppGap.xs),
                Text(_formatFileSize(attachment.sizeBytes), style: AppText.mut),
                // Chỉ hiện khi KHÔNG đọc được — mặc định (đọc được) là kỳ vọng
                // bình thường, không cần nhắc.
                if (!attachment.aiReadable) ...[
                  const SizedBox(height: AppGap.xs),
                  const StatusChip('AI chưa đọc được nội dung này'),
                ],
              ],
            ),
          ),
          IconButtonBox(
            SoloIcons.download,
            label: 'Tải về',
            ghost: true,
            onTap: busy ? null : () => _download(context, ref),
          ),
          IconButtonBox(
            SoloIcons.trash,
            label: 'Xoá',
            ghost: true,
            // Không dùng `Tone.money` — tone đó chỉ dành riêng cho ngữ nghĩa
            // tiền bạc (quy tắc 2 AGENTS.md). Xoá là hành động phá huỷ, không
            // phải tiền, nên tô màu lỗi của theme thay vì mượn tone sai nghĩa.
            iconColor: Theme.of(context).colorScheme.error,
            onTap: busy ? null : () => _delete(context, ref),
          ),
        ],
      ),
    );
  }
}

String _formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(1)} MB';
}
