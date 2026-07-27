import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_query.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/mapper/proposal_row_mapper.dart';

class ProposalsLocalDatasource {
  const ProposalsLocalDatasource(this._database);

  final AppDatabase _database;

  Future<void> upsertProposals(List<Proposal> proposals) =>
      _database.proposalRowsDao.upsertAll(proposals.map((p) => p.toRow()));

  /// Trả về báo giá đã cache khớp [filter] — dùng làm fallback ngoại tuyến
  /// cho trang đầu tiên.
  Future<List<Proposal>> listProposals({
    ProposalListFilter filter = const ProposalListFilter(),
  }) async {
    final rows = await _database.proposalRowsDao.getAll();
    return rows.map((r) => r.toDomain()).where(filter.matches).toList();
  }
}
