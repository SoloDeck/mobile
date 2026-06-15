import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deals_repository.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

/// Advances a deal to the next pipeline stage. Invalid transitions are rejected
/// locally (via [DealStageX.canTransitionTo]) before any network call, so the UI
/// gives immediate feedback and never sends a request the backend would reject.
class TransitionStageUseCase {
  const TransitionStageUseCase(this._repository);

  final DealsRepository _repository;

  Future<Deal> call({
    required String dealId,
    required DealStage currentStage,
    required DealStage targetStage,
    String? note,
  }) {
    if (!currentStage.canTransitionTo(targetStage)) {
      throw ValidationException(
        'Không thể chuyển từ "${currentStage.label}" sang "${targetStage.label}"',
      );
    }
    return _repository.transitionStage(
      id: dealId,
      targetStage: targetStage,
      note: note,
    );
  }
}
