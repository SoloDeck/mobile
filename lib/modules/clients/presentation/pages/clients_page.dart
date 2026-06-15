import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/presentation/providers/clients_provider.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';

/// Lists all clients owned by the authenticated freelancer.
class ClientsPage extends ConsumerWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Khách hàng')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('${RouteNames.clients}/new'),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Thêm khách'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(clientListProvider.future),
        child: AsyncValueWidget<List<Client>>(
          value: clients,
          onRetry: () => ref.invalidate(clientListProvider),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Chưa có khách hàng nào')),
                ],
              );
            }
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final client = items[index];
                return ClientListTile(client: client);
              },
            );
          },
        ),
      ),
    );
  }
}

class ClientListTile extends StatelessWidget {
  const ClientListTile({super.key, required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(client.name.isEmpty ? '?' : client.name[0].toUpperCase()),
      ),
      title: Text(client.name),
      subtitle: Text(client.email ?? client.phone ?? 'Không có liên hệ'),
      trailing: Chip(label: Text(client.status.label)),
      onTap: () => context.push('${RouteNames.clients}/${client.id}'),
    );
  }
}

extension ClientStatusLabel on ClientStatus {
  String get label => switch (this) {
    ClientStatus.prospect => 'Tiềm năng',
    ClientStatus.active => 'Đang hợp tác',
    ClientStatus.inactive => 'Tạm dừng',
    ClientStatus.archived => 'Lưu trữ',
  };
}

extension ClientTypeLabel on ClientType {
  String get label => switch (this) {
    ClientType.individual => 'Cá nhân',
    ClientType.company => 'Công ty',
  };
}
