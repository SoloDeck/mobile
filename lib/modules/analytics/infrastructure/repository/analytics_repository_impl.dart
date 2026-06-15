import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/analytics/domain/entities/dashboard_summary.dart';
import 'package:solodesk_mobile/modules/analytics/domain/repositories/analytics_repository.dart';
import 'package:solodesk_mobile/modules/analytics/infrastructure/datasource/analytics_remote_datasource.dart';
import 'package:solodesk_mobile/modules/analytics/infrastructure/mapper/analytics_mapper.dart';

part 'analytics_repository_impl.g.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  const AnalyticsRepositoryImpl(this._remote);

  final AnalyticsRemoteDatasource _remote;

  @override
  Future<DashboardSummary> getDashboard() async {
    final dto = await _remote.getDashboard();
    return dto.toDomain();
  }
}

@Riverpod(keepAlive: true)
AnalyticsRepository analyticsRepository(Ref ref) {
  final client = ref.read(apiClientProvider);
  return AnalyticsRepositoryImpl(AnalyticsRemoteDatasource(client));
}
