import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/mapper/client_row_mapper.dart';

class ClientsLocalDatasource {
  const ClientsLocalDatasource(this._database);

  final AppDatabase _database;

  Future<void> upsertClients(Iterable<Client> clients) => _database
      .clientRowsDao
      .upsertAll(clients.map((client) => client.toRow()));

  Future<List<Client>> listClients({
    ClientStatus? status,
    String? name,
    String? email,
  }) async {
    final rows = await _database.clientRowsDao.getAll();
    final normalizedName = name?.trim().toLowerCase();
    final normalizedEmail = email?.trim().toLowerCase();

    return rows.map((row) => row.toDomain()).where((client) {
      if (status != null && client.status != status) return false;
      if (normalizedName != null &&
          normalizedName.isNotEmpty &&
          !client.name.toLowerCase().contains(normalizedName)) {
        return false;
      }
      if (normalizedEmail != null &&
          normalizedEmail.isNotEmpty &&
          !(client.email?.toLowerCase().contains(normalizedEmail) ?? false)) {
        return false;
      }
      return true;
    }).toList();
  }
}
