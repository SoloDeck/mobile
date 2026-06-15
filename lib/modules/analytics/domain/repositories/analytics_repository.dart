import 'package:solodesk_mobile/modules/analytics/domain/entities/dashboard_summary.dart';

/// Contract for reading analytics. Implemented in
/// `infrastructure/repository/analytics_repository_impl.dart`.
abstract interface class AnalyticsRepository {
  Future<DashboardSummary> getDashboard();
}
