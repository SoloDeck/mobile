import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/clients/application/usecases/get_client_usecase.dart';
import 'package:solodesk_mobile/modules/clients/application/usecases/list_clients_usecase.dart';
import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/repository/clients_repository_impl.dart';

part 'clients_provider.g.dart';

/// All clients owned by the authenticated user.
@riverpod
Future<List<Client>> clientList(Ref ref) {
  final useCase = ListClientsUseCase(ref.watch(clientsRepositoryProvider));
  return useCase();
}

/// A single client by id, used by the detail page.
@riverpod
Future<Client> clientDetail(Ref ref, String id) {
  final useCase = GetClientUseCase(ref.watch(clientsRepositoryProvider));
  return useCase(id);
}
