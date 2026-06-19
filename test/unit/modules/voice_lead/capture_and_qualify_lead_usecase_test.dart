import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deals_repository.dart';
import 'package:solodesk_mobile/modules/voice_lead/application/usecases/capture_and_qualify_lead_usecase.dart';
import 'package:solodesk_mobile/modules/voice_lead/infrastructure/datasource/ai_leads_datasource.dart';
import 'package:solodesk_mobile/modules/voice_lead/infrastructure/dto/lead_qualification_request_dto.dart';
import 'package:solodesk_mobile/modules/voice_lead/infrastructure/dto/lead_qualification_response_dto.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

class _MockAiLeadsDatasource extends Mock implements AiLeadsDatasource {}

class _MockDealsRepository extends Mock implements DealsRepository {}

void main() {
  late _MockAiLeadsDatasource mockDatasource;
  late _MockDealsRepository mockDealsRepo;
  late CaptureAndQualifyLeadUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      const LeadQualificationRequestDto(inquiryText: ''),
    );
    registerFallbackValue(DealSource.inbound);
  });

  setUp(() {
    mockDatasource = _MockAiLeadsDatasource();
    mockDealsRepo = _MockDealsRepository();
    useCase = CaptureAndQualifyLeadUseCase(mockDatasource, mockDealsRepo);
  });

  const kText = 'Tôi cần thiết kế logo cho công ty';
  const kClientId = 'client-123';

  final kResponse = LeadQualificationResponseDto(
    score: 0.85,
    recommendation: 'hot',
    suggestedDealTitle: 'Logo Design',
    suggestedClientName: 'Công ty ABC',
  );

  final kDeal = Deal(
    id: 'deal-1',
    ownerUserId: 'user-1',
    clientId: kClientId,
    title: 'Logo Design',
    stage: DealStage.newLead,
    createdAt: DateTime(2026),
  );

  group('CaptureAndQualifyLeadUseCase', () {
    test('qualify returns score and creates deal with correct body', () async {
      when(
        () => mockDatasource.qualify(any()),
      ).thenAnswer((_) async => kResponse);
      when(
        () => mockDealsRepo.createDeal(
          clientId: any(named: 'clientId'),
          title: any(named: 'title'),
          source: any(named: 'source'),
          notes: any(named: 'notes'),
          estimatedValue: any(named: 'estimatedValue'),
          currency: any(named: 'currency'),
        ),
      ).thenAnswer((_) async => kDeal);

      final draft = await useCase(
        transcribedText: kText,
        clientId: kClientId,
      );

      expect(draft.qualificationScore, 0.85);
      expect(draft.recommendation, 'hot');
      expect(draft.suggestedDealTitle, 'Logo Design');
      expect(draft.createdDealId, 'deal-1');

      // Verify deal POST has correct body
      verify(
        () => mockDealsRepo.createDeal(
          clientId: kClientId,
          title: 'Logo Design',
          source: DealSource.inbound,
          notes: kText,
          estimatedValue: null,
          currency: null,
        ),
      ).called(1);
    });

    test('AIQualificationException thrown when datasource fails', () async {
      when(
        () => mockDatasource.qualify(any()),
      ).thenThrow(Exception('network'));

      expect(
        () => useCase(transcribedText: kText, clientId: kClientId),
        throwsA(isA<AIQualificationException>()),
      );
    });

    test('transcribedText is sent in request to AI', () async {
      when(
        () => mockDatasource.qualify(any()),
      ).thenAnswer((_) async => kResponse);
      when(
        () => mockDealsRepo.createDeal(
          clientId: any(named: 'clientId'),
          title: any(named: 'title'),
          source: any(named: 'source'),
          notes: any(named: 'notes'),
          estimatedValue: any(named: 'estimatedValue'),
          currency: any(named: 'currency'),
        ),
      ).thenAnswer((_) async => kDeal);

      await useCase(transcribedText: kText, clientId: kClientId);

      final captured =
          verify(() => mockDatasource.qualify(captureAny())).captured;
      final req = captured.first as LeadQualificationRequestDto;
      expect(req.inquiryText, kText);
    });
  });
}
