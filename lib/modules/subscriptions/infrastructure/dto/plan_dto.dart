import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_dto.freezed.dart';
part 'plan_dto.g.dart';

/// Backend Decimal money fields (`price_monthly`, `amount`) có thể serialize
/// thành số JSON HOẶC chuỗi — parse cả hai dạng.
double decimalFromJson(dynamic v) =>
    v is num ? v.toDouble() : double.parse(v as String);

/// Wire shape của một gói dịch vụ — khớp `PlanResponse` backend
/// (`GET /subscriptions/plans`).
@freezed
abstract class PlanDto with _$PlanDto {
  const factory PlanDto({
    required String id,
    required String name,
    required String slug,
    @JsonKey(name: 'price_monthly', fromJson: decimalFromJson)
    required double priceMonthly,
    required String currency,
    @JsonKey(name: 'can_use_ai') required bool canUseAi,
    @JsonKey(name: 'can_export_pdf') required bool canExportPdf,
    @JsonKey(name: 'max_clients') int? maxClients,
    @JsonKey(name: 'max_deals') int? maxDeals,
    @JsonKey(name: 'max_ai_generations_per_month')
    required int maxAiGenerationsPerMonth,
  }) = _PlanDto;

  factory PlanDto.fromJson(Map<String, dynamic> json) =>
      _$PlanDtoFromJson(json);
}
