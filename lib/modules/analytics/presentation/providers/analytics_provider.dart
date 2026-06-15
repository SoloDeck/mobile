import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/analytics/application/usecases/get_dashboard_usecase.dart';
import 'package:solodesk_mobile/modules/analytics/domain/entities/dashboard_summary.dart';
import 'package:solodesk_mobile/modules/analytics/infrastructure/repository/analytics_repository_impl.dart';

part 'analytics_provider.g.dart';

/// Headline workspace totals for the analytics dashboard.
@riverpod
Future<DashboardSummary> dashboardSummary(Ref ref) {
  final useCase = GetDashboardUseCase(ref.watch(analyticsRepositoryProvider));
  return useCase();
}
