import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/billing_period.dart';

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
    required double priceYearly,
    required String currency,
    required bool canUseAi,
    required bool canExportPdf,
    int? maxClients,
    int? maxDeals,
    required int maxAiGenerationsPerMonth,
  }) = _Plan;
}

extension PlanX on Plan {
  /// Giá theo kỳ thanh toán — [priceYearly] là giá TRỌN NĂM (không phải
  /// giá tháng nhân 12), backend đã trừ sẵn chiết khấu.
  double priceFor(BillingPeriod period) => switch (period) {
    BillingPeriod.monthly => priceMonthly,
    BillingPeriod.yearly => priceYearly,
  };

  /// Phần trăm rẻ hơn khi trả cả năm so với trả 12 tháng lẻ, làm tròn về
  /// số nguyên (ví dụ 28 cho "−28%"). Gói miễn phí (priceMonthly == 0)
  /// không có khái niệm chiết khấu — trả về 0 thay vì chia cho 0.
  int get yearlyDiscountPercent {
    if (priceMonthly == 0) return 0;
    final fullYear = priceMonthly * 12;
    return ((1 - priceYearly / fullYear) * 100).round();
  }

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
