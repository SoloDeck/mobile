import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_summary.freezed.dart';

/// Headline workspace totals shown on the analytics dashboard. Pure domain
/// entity — mirrors the backend `DashboardResponse` contract
/// (`/analytics/dashboard`).
@freezed
abstract class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    required int totalClients,
    required int activeDeals,
    required double totalRevenue,
    required int pendingInvoices,
  }) = _DashboardSummary;
}
