import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deals_repository.dart';
import 'package:solodesk_mobile/modules/voice_lead/domain/entities/voice_lead_draft.dart';
import 'package:solodesk_mobile/modules/voice_lead/infrastructure/datasource/ai_leads_datasource.dart';
import 'package:solodesk_mobile/modules/voice_lead/infrastructure/dto/lead_qualification_request_dto.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

class CaptureAndQualifyLeadUseCase {
  const CaptureAndQualifyLeadUseCase(this._datasource, this._dealsRepository);

  final AiLeadsDatasource _datasource;
  final DealsRepository _dealsRepository;

  Future<VoiceLeadDraft> call({
    required String transcribedText,
    required String clientId,
    String? serviceCategory,
  }) async {
    final result = await _qualify(transcribedText, serviceCategory);

    final deal = await _dealsRepository.createDeal(
      clientId: clientId,
      title: result.suggestedDealTitle,
      source: DealSource.inbound,
      notes: transcribedText,
    );

    return VoiceLeadDraft(
      transcribedText: transcribedText,
      qualificationScore: result.score,
      recommendation: result.recommendation,
      suggestedDealTitle: result.suggestedDealTitle,
      suggestedClientName: result.suggestedClientName,
      createdDealId: deal.id,
    );
  }

  Future<_QualResult> _qualify(String text, String? category) async {
    try {
      final dto = await _datasource.qualify(
        LeadQualificationRequestDto(
          inquiryText: text,
          serviceCategory: category,
        ),
      );
      return (
        score: dto.score,
        recommendation: dto.recommendation,
        suggestedDealTitle: dto.suggestedDealTitle,
        suggestedClientName: dto.suggestedClientName,
      );
    } on Exception catch (e) {
      throw AIQualificationException(
        'Không thể sàng lọc khách hàng tiềm năng: $e',
      );
    }
  }
}

typedef _QualResult = ({
  double score,
  String recommendation,
  String suggestedDealTitle,
  String? suggestedClientName,
});
