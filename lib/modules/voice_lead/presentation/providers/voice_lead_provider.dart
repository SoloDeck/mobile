import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/audio/voice_capture_service.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/repository/deals_repository_impl.dart';
import 'package:solodesk_mobile/modules/voice_lead/application/usecases/capture_and_qualify_lead_usecase.dart';
import 'package:solodesk_mobile/modules/voice_lead/domain/entities/voice_lead_draft.dart';
import 'package:solodesk_mobile/modules/voice_lead/infrastructure/datasource/ai_leads_datasource.dart';

part 'voice_lead_provider.g.dart';

@riverpod
VoiceCaptureService voiceCaptureService(Ref ref) => VoiceCaptureService();

@riverpod
CaptureAndQualifyLeadUseCase captureAndQualifyLeadUseCase(Ref ref) =>
    CaptureAndQualifyLeadUseCase(
      AiLeadsDatasource(ref.watch(apiClientProvider)),
      ref.watch(dealsRepositoryProvider),
    );

@riverpod
class VoiceLeadNotifier extends _$VoiceLeadNotifier {
  @override
  VoiceLeadDraft? build() => null;

  Future<VoiceLeadDraft> qualify({
    required String transcribedText,
    required String clientId,
    String? serviceCategory,
  }) async {
    final useCase = ref.read(captureAndQualifyLeadUseCaseProvider);
    final draft = await useCase(
      transcribedText: transcribedText,
      clientId: clientId,
      serviceCategory: serviceCategory,
    );
    state = draft;
    return draft;
  }
}
