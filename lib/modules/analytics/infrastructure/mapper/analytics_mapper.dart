import 'package:solodesk_mobile/modules/analytics/domain/entities/dashboard_summary.dart';
import 'package:solodesk_mobile/modules/analytics/infrastructure/dto/dashboard_response_dto.dart';

extension DashboardResponseDtoMapper on DashboardResponseDto {
  DashboardSummary toDomain() => DashboardSummary(
    totalClients: totalClients,
    activeDeals: activeDeals,
    totalRevenue: totalRevenue,
    pendingInvoices: pendingInvoices,
  );
}
