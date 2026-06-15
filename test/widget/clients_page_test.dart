import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/domain/repositories/clients_repository.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/repository/clients_repository_impl.dart';
import 'package:solodesk_mobile/modules/clients/presentation/pages/clients_page.dart';

class _FakeClientsRepository implements ClientsRepository {
  _FakeClientsRepository(this.clients);

  final List<Client> clients;

  @override
  Future<List<Client>> listClients({
    ClientStatus? status,
    String? name,
    String? email,
  }) async => clients;

  @override
  Future<Client> getClient(String id) async =>
      clients.firstWhere((c) => c.id == id);

  @override
  Future<Client> createClient({
    required String name,
    ClientType? type,
    String? email,
    String? phone,
    String? notes,
  }) async => clients.first;
}

void main() {
  testWidgets('ClientsPage renders the client list', (tester) async {
    final clients = [
      Client(
        id: 'c1',
        ownerUserId: 'owner-1',
        name: 'Anh Tú',
        type: ClientType.individual,
        status: ClientStatus.active,
        dealCount: 1,
        createdAt: DateTime.utc(2026, 6, 14),
        email: 'tu@example.com',
      ),
      Client(
        id: 'c2',
        ownerUserId: 'owner-1',
        name: 'Công ty ABC',
        type: ClientType.company,
        status: ClientStatus.prospect,
        dealCount: 0,
        createdAt: DateTime.utc(2026, 6, 14),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientsRepositoryProvider.overrideWithValue(
            _FakeClientsRepository(clients),
          ),
        ],
        child: const MaterialApp(home: ClientsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Anh Tú'), findsOneWidget);
    expect(find.text('Công ty ABC'), findsOneWidget);
    expect(find.text('tu@example.com'), findsOneWidget);
  });
}
