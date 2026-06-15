import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_lead_draft.freezed.dart';

/// Result of the voice-to-lead qualification flow.
@freezed
abstract class VoiceLeadDraft with _$VoiceLeadDraft {
  const factory VoiceLeadDraft({
    required String transcribedText,
    required double qualificationScore,
    required String recommendation, // 'hot' | 'warm' | 'cold'
    required String suggestedDealTitle,
    String? suggestedClientName,
    String? createdDealId,
  }) = _VoiceLeadDraft;
}
