import 'package:solodesk_mobile/modules/analytics/domain/entities/dashboard_summary.dart';
import 'package:solodesk_mobile/modules/analytics/domain/repositories/analytics_repository.dart';

class GetDashboardUseCase {
  const GetDashboardUseCase(this._repository);

  final AnalyticsRepository _repository;

  Future<DashboardSummary> call() => _repository.getDashboard();
}
