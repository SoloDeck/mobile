import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/modules/deals/application/usecases/transition_stage_usecase.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deals_repository.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

class _MockDealsRepository extends Mock implements DealsRepository {}

Deal _deal(DealStage stage) => Deal(
  id: 'deal-1',
  ownerUserId: 'owner-1',
  clientId: 'client-1',
  title: 'Deal',
  stage: stage,
  createdAt: DateTime.utc(2026, 6, 14),
);

void main() {
  late _MockDealsRepository repository;
  late TransitionStageUseCase useCase;

  setUpAll(() => registerFallbackValue(DealStage.newLead));

  setUp(() {
    repository = _MockDealsRepository();
    useCase = TransitionStageUseCase(repository);
  });

  group('TransitionStageUseCase', () {
    test('rejects a non-sequential transition without calling the repo', () {
      expect(
        () => useCase(
          dealId: 'deal-1',
          currentStage: DealStage.newLead,
          targetStage: DealStage.active,
        ),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(
        () => repository.transitionStage(
          id: any(named: 'id'),
          targetStage: any(named: 'targetStage'),
          note: any(named: 'note'),
        ),
      );
    });

    test('rejects any transition out of a terminal stage', () {
      expect(
        () => useCase(
          dealId: 'deal-1',
          currentStage: DealStage.lost,
          targetStage: DealStage.active,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('forwards a valid sequential transition to the repo', () async {
      when(
        () => repository.transitionStage(
          id: any(named: 'id'),
          targetStage: any(named: 'targetStage'),
          note: any(named: 'note'),
        ),
      ).thenAnswer((_) async => _deal(DealStage.qualified));

      final result = await useCase(
        dealId: 'deal-1',
        currentStage: DealStage.newLead,
        targetStage: DealStage.qualified,
      );

      expect(result.stage, DealStage.qualified);
      verify(
        () => repository.transitionStage(
          id: 'deal-1',
          targetStage: DealStage.qualified,
          note: null,
        ),
      ).called(1);
    });
  });
}
