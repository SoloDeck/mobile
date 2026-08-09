import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal_activity.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deal_activities_repository.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/datasource/deal_activities_remote_datasource.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/mapper/deal_activity_mapper.dart';

part 'deal_activities_repository_impl.g.dart';

/// Read-only, no local cache — this is an audit log, not app state worth
/// persisting offline (mirrors `deal_attachments`, not `invoices`).
class DealActivitiesRepositoryImpl implements DealActivitiesRepository {
  const DealActivitiesRepositoryImpl(this._remote);

  final DealActivitiesRemoteDatasource _remote;

  @override
  Future<List<DealActivity>> listActivities(String dealId) async {
    final dtos = await _remote.listActivities(dealId, pageSize: 50);
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}

@Riverpod(keepAlive: true)
DealActivitiesRepository dealActivitiesRepository(Ref ref) {
  final client = ref.read(apiClientProvider);
  return DealActivitiesRepositoryImpl(DealActivitiesRemoteDatasource(client));
}
