import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_response_dto.freezed.dart';
part 'dashboard_response_dto.g.dart';

/// Backend serializes the Decimal `total_revenue` as a JSON string; parse
/// defensively so either a number or a string is accepted.
double doubleFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

/// Wire shape returned by `GET /analytics/dashboard`.
@freezed
abstract class DashboardResponseDto with _$DashboardResponseDto {
  const factory DashboardResponseDto({
    @JsonKey(name: 'total_clients') required int totalClients,
    @JsonKey(name: 'active_deals') required int activeDeals,
    @JsonKey(name: 'total_revenue', fromJson: doubleFromJson)
    required double totalRevenue,
    @JsonKey(name: 'pending_invoices') required int pendingInvoices,
  }) = _DashboardResponseDto;

  factory DashboardResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardResponseDtoFromJson(json);
}
