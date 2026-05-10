import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/domain/models/proposal.dart';

/// Card hiển thị thông tin một Proposal.
class ProposalCard extends StatefulWidget {
  const ProposalCard({
    super.key,
    required this.proposal,
    required this.onApproveAndSend,
    this.isSending = false,
  });

  final Proposal proposal;
  final VoidCallback onApproveAndSend;
  final bool isSending;

  @override
  State<ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends State<ProposalCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.proposal;
    final isPending = p.status == ProposalStatus.draft ||
                      p.status == ProposalStatus.approved;

    return Card(
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${p.customerName} • ${p.dealTitle}',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: p.status),
                ],
              ),

              // ── Expanded content ──
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    p.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),

                // ── Action button ──
                if (isPending) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          widget.isSending ? null : widget.onApproveAndSend,
                      icon: widget.isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 20),
                      label: Text(
                          widget.isSending ? 'Đang gửi...' : 'Duyệt & Gửi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tertiary,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                ],

                if (p.sentAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 16, color: AppColors.success),
                      const SizedBox(width: 6),
                      Text(
                        'Đã gửi ${_formatDate(p.sentAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.success,
                            ),
                      ),
                    ],
                  ),
                ],
              ],

              // ── Expand indicator ──
              if (!_isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Xem chi tiết',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                      const Icon(Icons.expand_more, size: 18,
                          color: AppColors.primary),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final ProposalStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, bgColor) = switch (status) {
      ProposalStatus.draft => ('Bản nháp', AppColors.warning, AppColors.warningBg),
      ProposalStatus.approved => ('Đã duyệt', AppColors.info, AppColors.infoBg),
      ProposalStatus.sent => ('Đã gửi', AppColors.success, AppColors.successBg),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
