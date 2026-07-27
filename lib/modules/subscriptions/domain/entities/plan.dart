import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan.freezed.dart';

/// A subscription plan (gói dịch vụ). Pure domain entity — mirrors the
/// backend `PlanResponse` contract (`GET /subscriptions/plans`, public,
/// không cần đăng nhập).
///
/// Backend không lộ endpoint usage/quota (bảng `usage_records` không có
/// REST) — vì vậy entity này chỉ mang HẠN MỨC (ví dụ "80 lượt/tháng"),
/// KHÔNG có trường số đã dùng.
@freezed
abstract class Plan with _$Plan {
  const factory Plan({
    required String id,
    required String name,
    required String slug,
    required double priceMonthly,
    required String currency,
    required bool canUseAi,
    required bool canExportPdf,
    int? maxClients,
    int? maxDeals,
    required int maxAiGenerationsPerMonth,
  }) = _Plan;
}

extension PlanX on Plan {
  /// null = không giới hạn.
  String get clientsLabel =>
      maxClients == null ? 'Không giới hạn' : '$maxClients khách';

  /// null = không giới hạn.
  String get dealsLabel =>
      maxDeals == null ? 'Không giới hạn' : '$maxDeals thương vụ';

  String get aiQuotaLabel =>
      canUseAi ? 'AI không giới hạn' : '$maxAiGenerationsPerMonth lượt AI';

  String get pdfLabel =>
      canExportPdf ? 'Xuất PDF không đóng dấu' : 'không xuất PDF';
}
