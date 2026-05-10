import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/error_retry_widget.dart';
import 'package:mobile/core/widgets/loading_shimmer.dart';
import 'package:mobile/domain/models/lead.dart';
import 'package:mobile/domain/providers/lead_provider.dart';
import 'package:mobile/presentation/voice_lead/widgets/lead_preview_card.dart';
import 'package:mobile/presentation/voice_lead/widgets/transcript_display.dart';
import 'package:mobile/presentation/voice_lead/widgets/voice_recorder_button.dart';

/// Màn hình Voice-to-Lead: ghi âm giọng nói → AI trích xuất → tạo Lead.
class VoiceLeadScreen extends ConsumerStatefulWidget {
  const VoiceLeadScreen({super.key});

  @override
  ConsumerState<VoiceLeadScreen> createState() => _VoiceLeadScreenState();
}

class _VoiceLeadScreenState extends ConsumerState<VoiceLeadScreen> {
  bool _isListening = false;
  bool _isProcessing = false;
  String _transcript = '';
  Lead? _extractedLead;

  // Trong thực tế sẽ dùng speech_to_text plugin.
  // Hiện tại giả lập bằng mock transcript.
  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _transcript = '';
      _extractedLead = null;
    });

    // Giả lập speech-to-text: sau 3s tự động tạo transcript
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || !_isListening) return;
      setState(() {
        _transcript =
            'Anh Hùng bên công ty TechViet gọi hỏi về dịch vụ thiết kế app, '
            'số điện thoại 0987654321, budget khoảng 80 triệu.';
      });

      // Tự động dừng sau khi có transcript
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _isListening) _stopListening();
      });
    });
  }

  void _stopListening() {
    setState(() => _isListening = false);

    if (_transcript.isNotEmpty) {
      _processTranscript();
    }
  }

  Future<void> _processTranscript() async {
    setState(() => _isProcessing = true);

    final lead = await ref
        .read(leadProvider.notifier)
        .createLeadFromVoice(_transcript);

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _extractedLead = lead;
    });
  }

  void _clearState() {
    setState(() {
      _transcript = '';
      _extractedLead = null;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(leadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Lead'),
        actions: [
          if (_transcript.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: _clearState,
              tooltip: 'Xóa',
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Top: Voice input area ──
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  // Recorder button
                  VoiceRecorderButton(
                    isListening: _isListening,
                    onTap: _isProcessing ? () {} : _toggleListening,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isListening
                        ? 'Đang ghi âm... nhấn để dừng'
                        : 'Nhấn để ghi âm',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),

                  // Transcript display
                  TranscriptDisplay(
                    transcript: _transcript,
                    isListening: _isListening,
                    isProcessing: _isProcessing,
                  ),

                  // AI extracted lead preview
                  if (_extractedLead != null)
                    LeadPreviewCard(
                      lead: _extractedLead!,
                      onSave: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã lưu lead thành công!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        _clearState();
                      },
                      onDiscard: _clearState,
                    ),
                ],
              ),
            ),
          ),

          // ── Bottom: Recent leads ──
          const Divider(height: 1),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    'Leads gần đây',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Expanded(
                  child: leadsAsync.when(
                    loading: () => const LoadingShimmer(itemCount: 2),
                    error: (error, _) => ErrorRetryWidget(
                      message:
                          error.toString().replaceAll('Exception: ', ''),
                      onRetry: () => ref.invalidate(leadProvider),
                    ),
                    data: (leads) => _buildRecentLeads(context, leads),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLeads(BuildContext context, List<Lead> leads) {
    if (leads.isEmpty) {
      return const Center(child: Text('Chưa có lead nào.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: leads.length,
      itemBuilder: (_, index) {
        final lead = leads[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: lead.source == LeadSource.voice
                  ? AppColors.primaryContainer
                  : AppColors.tertiaryContainer,
              child: Icon(
                lead.source == LeadSource.voice
                    ? Icons.mic_rounded
                    : lead.source == LeadSource.webForm
                        ? Icons.language_rounded
                        : Icons.edit_rounded,
                size: 20,
                color: lead.source == LeadSource.voice
                    ? AppColors.primary
                    : AppColors.tertiary,
              ),
            ),
            title: Text(
              lead.name,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: Text(
              lead.notes ?? lead.rawTranscript ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Text(
              _formatDate(lead.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${date.day}/${date.month}';
  }
}
