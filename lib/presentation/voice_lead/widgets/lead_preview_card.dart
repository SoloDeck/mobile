import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/domain/models/lead.dart';

/// Card xem trước thông tin Lead đã trích xuất từ AI.
///
/// Hiển thị đầy đủ output của Lead Qualifier: score badge, rationale,
/// suggested price range, red flags — mirror be-py lead_qualifier/chain.py output.
class LeadPreviewCard extends StatelessWidget {
  const LeadPreviewCard({
    super.key,
    required this.lead,
    required this.onSave,
    required this.onDiscard,
    this.isSaving = false,
  });

  final Lead lead;
  final VoidCallback onSave;
  final VoidCallback onDiscard;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tertiary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.tertiary.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lead mới từ AI',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      'Kiểm tra thông tin trước khi lưu',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Lead score badge
              if (lead.leadScore != null) _LeadScoreBadge(score: lead.leadScore!),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // ── Contact fields ──
          _InfoRow(icon: Icons.person_outlined, label: 'Tên', value: lead.name),
          if (lead.phone != null)
            _InfoRow(icon: Icons.phone_outlined, label: 'SĐT', value: lead.phone!),
          if (lead.email != null)
            _InfoRow(icon: Icons.email_outlined, label: 'Email', value: lead.email!),
          if (lead.company != null)
            _InfoRow(
                icon: Icons.business_outlined,
                label: 'Công ty',
                value: lead.company!),

          // ── AI Qualification section ──
          if (lead.isQualified) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              'Đánh giá AI',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: 10),

            if (lead.projectType != null)
              _InfoRow(
                  icon: Icons.work_outline_rounded,
                  label: 'Loại dự án',
                  value: lead.projectType!),
            if (lead.estimatedScope != null)
              _InfoRow(
                  icon: Icons.straighten_rounded,
                  label: 'Quy mô',
                  value: lead.estimatedScope!),
            if (lead.budgetSignal != null)
              _InfoRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Ngân sách',
                  value: lead.budgetSignal!),
            if (lead.urgency != null)
              _InfoRow(
                  icon: Icons.schedule_outlined,
                  label: 'Khẩn cấp',
                  value: _urgencyLabel(lead.urgency!)),

            // Suggested price range
            if (lead.suggestedPriceMin != null && lead.suggestedPriceMax != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.price_check_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Giá khởi điểm đề xuất',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.primary),
                          ),
                          Text(
                            '${_formatPrice(lead.suggestedPriceMin!)} – ${_formatPrice(lead.suggestedPriceMax!)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Rationale
            if (lead.scoreRationale != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded,
                        size: 16, color: AppColors.textTertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lead.scoreRationale!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              height: 1.5,
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Red flags
            if (lead.redFlags != null && lead.redFlags!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...lead.redFlags!.map(
                (flag) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 16, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          flag,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.warning,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ] else ...[
            if (lead.notes != null && lead.notes!.isNotEmpty)
              _InfoRow(
                  icon: Icons.notes_rounded,
                  label: 'Ghi chú',
                  value: lead.notes!),
          ],

          const SizedBox(height: 20),

          // ── Actions ──
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSaving ? null : onDiscard,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : onSave,
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 20),
                  label: Text(isSaving ? 'Đang lưu...' : 'Lưu Lead'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _urgencyLabel(LeadUrgency urgency) {
    return switch (urgency) {
      LeadUrgency.high => 'Cao — cần xử lý ngay',
      LeadUrgency.medium => 'Trung bình',
      LeadUrgency.low => 'Thấp — không gấp',
    };
  }

  String _formatPrice(int price) {
    if (price >= 1000000) {
      final millions = price / 1000000;
      return '${millions % 1 == 0 ? millions.toInt() : millions.toStringAsFixed(1)} triệu';
    }
    return '${price ~/ 1000}K';
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _LeadScoreBadge extends StatelessWidget {
  const _LeadScoreBadge({required this.score});
  final LeadScore score;

  @override
  Widget build(BuildContext context) {
    final (label, color, bg, icon) = switch (score) {
      LeadScore.hot => (
          'Hot',
          const Color(0xFFDC2626),
          const Color(0xFFFEE2E2),
          Icons.local_fire_department_rounded,
        ),
      LeadScore.warm => (
          'Warm',
          const Color(0xFFD97706),
          const Color(0xFFFEF3C7),
          Icons.thermostat_rounded,
        ),
      LeadScore.cold => (
          'Cold',
          const Color(0xFF2563EB),
          const Color(0xFFDBEAFE),
          Icons.ac_unit_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
