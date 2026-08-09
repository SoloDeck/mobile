/// Kỳ thanh toán của một gói dịch vụ — khớp `billing_period` backend
/// (`POST /subscriptions/checkout`, Literal `"monthly" | "yearly"`).
enum BillingPeriod { monthly, yearly }

extension BillingPeriodX on BillingPeriod {
  /// Giá trị đúng như wire contract của backend.
  String get wireValue => switch (this) {
    BillingPeriod.monthly => 'monthly',
    BillingPeriod.yearly => 'yearly',
  };

  /// Nhãn tiếng Việt trên chip chọn kỳ ở MÀN 13.
  String get label => switch (this) {
    BillingPeriod.monthly => 'Theo tháng',
    BillingPeriod.yearly => 'Theo năm',
  };

  /// Đuôi đơn vị đứng sau giá: "/ tháng" hoặc "/ năm".
  String get priceSuffix => switch (this) {
    BillingPeriod.monthly => '/ tháng',
    BillingPeriod.yearly => '/ năm',
  };
}
