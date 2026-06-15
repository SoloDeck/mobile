import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/mapper/deal_row_mapper.dart';

class DealsLocalDatasource {
  const DealsLocalDatasource(this._database);

  final AppDatabase _database;

  Future<void> upsertDeals(Iterable<Deal> deals) =>
      _database.dealRowsDao.upsertAll(deals.map((deal) => deal.toRow()));

  Future<List<Deal>> listDeals({DealStage? stage}) async {
    final rows = await _database.dealRowsDao.getAll();
    return rows
        .map((row) => row.toDomain())
        .where((deal) => stage == null || deal.stage == stage)
        .toList();
  }
}
