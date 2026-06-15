import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/clients/application/usecases/create_client_usecase.dart';
import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/repository/clients_repository_impl.dart';
import 'package:solodesk_mobile/modules/clients/presentation/providers/clients_provider.dart';

part 'clients_controller.g.dart';

/// Drives the create-client form. Holds the most recently created [Client] (or
/// `null` before the first submit) and refreshes the list on success.
@riverpod
class CreateClientController extends _$CreateClientController {
  @override
  AsyncValue<Client?> build() => const AsyncValue.data(null);

  Future<Client?> submit({
    required String name,
    ClientType? type,
    String? email,
    String? phone,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    final useCase = CreateClientUseCase(ref.read(clientsRepositoryProvider));
    state = await AsyncValue.guard(
      () => useCase(
        name: name,
        type: type,
        email: email,
        phone: phone,
        notes: notes,
      ),
    );
    if (state.hasValue && state.value != null) {
      ref.invalidate(clientListProvider);
    }
    return state.value;
  }
}
