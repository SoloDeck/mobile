import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/deals/application/usecases/create_deal_usecase.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/repository/deals_repository_impl.dart';
import 'package:solodesk_mobile/modules/deals/presentation/providers/deals_provider.dart';

part 'create_deal_manual_controller.g.dart';

/// Drives the manual ("Gõ tay") lead-entry form. Holds the most recently
/// created [Deal] (or `null` before the first submit) and refreshes the
/// pipeline list on success.
@riverpod
class CreateDealManualController extends _$CreateDealManualController {
  @override
  AsyncValue<Deal?> build() => const AsyncValue.data(null);

  Future<Deal?> submit({
    required String clientId,
    required String title,
    DealSource? source,
    double? estimatedValue,
    String? currency,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    final useCase = CreateDealUseCase(ref.read(dealsRepositoryProvider));
    state = await AsyncValue.guard(
      () => useCase(
        clientId: clientId,
        title: title,
        source: source,
        estimatedValue: estimatedValue,
        currency: currency,
        notes: notes,
      ),
    );
    if (state.hasValue && state.value != null) {
      ref.invalidate(dealListProvider);
    }
    return state.value;
  }
}
