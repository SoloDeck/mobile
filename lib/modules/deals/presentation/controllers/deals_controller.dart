import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/deals/application/usecases/transition_stage_usecase.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/repository/deals_repository_impl.dart';
import 'package:solodesk_mobile/modules/deals/presentation/providers/deals_provider.dart';

part 'deals_controller.g.dart';

/// Drives stage transitions from the deal detail page. Rejects invalid
/// transitions locally and refreshes the affected providers on success.
@riverpod
class DealStageController extends _$DealStageController {
  @override
  AsyncValue<Deal?> build() => const AsyncValue.data(null);

  Future<Deal?> transition({
    required String dealId,
    required DealStage currentStage,
    required DealStage targetStage,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    final useCase = TransitionStageUseCase(ref.read(dealsRepositoryProvider));
    state = await AsyncValue.guard(
      () => useCase(
        dealId: dealId,
        currentStage: currentStage,
        targetStage: targetStage,
        note: note,
      ),
    );
    if (state.hasValue && state.value != null) {
      ref.invalidate(dealListProvider);
      ref.invalidate(dealDetailProvider(dealId));
    }
    return state.value;
  }
}
