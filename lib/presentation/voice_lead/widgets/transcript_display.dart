import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

/// Hiển thị transcript real-time khi ghi âm.
class TranscriptDisplay extends StatelessWidget {
  const TranscriptDisplay({
    super.key,
    required this.transcript,
    required this.isListening,
    required this.isProcessing,
  });

  final String transcript;
  final bool isListening;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    if (transcript.isEmpty && !isListening && !isProcessing) {
      return _buildEmptyState(context);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isListening ? AppColors.primary : AppColors.border,
          width: isListening ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                isListening
                    ? Icons.hearing_rounded
                    : isProcessing
                        ? Icons.auto_awesome_rounded
                        : Icons.text_snippet_outlined,
                size: 18,
                color: isListening ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                isListening
                    ? 'Đang nghe...'
                    : isProcessing
                        ? 'Đang xử lý AI...'
                        : 'Nội dung ghi âm',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isListening
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (isListening || isProcessing) ...[
                const Spacer(),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Transcript text
          Text(
            transcript.isEmpty ? 'Hãy bắt đầu nói...' : transcript,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: transcript.isEmpty
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.mic_none_rounded,
            size: 32,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút micro để bắt đầu ghi âm',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textTertiary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
