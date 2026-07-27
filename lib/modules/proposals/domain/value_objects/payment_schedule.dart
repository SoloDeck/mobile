/// Một đợt thanh toán được suy ra (hoặc mặc định) từ `content.paymentTerms`.
class PaymentStage {
  const PaymentStage({required this.label, required this.percent});

  final String label;
  final int percent;
}

/// Lịch thanh toán hiển thị trên MÀN 08. `payment_terms` phía backend là
/// CHUỖI TỰ DO (không phải mảng đợt có cấu trúc), nên mobile phải tự suy ra
/// các đợt bằng regex; nếu không suy ra được (hoặc suy ra vô lý) thì rơi về
/// [standard] — lịch 3 đợt mặc định 50/30/20 dùng làm bản nháp gợi ý.
class PaymentSchedule {
  const PaymentSchedule._(this.stages, {required this.isFallback});

  final List<PaymentStage> stages;

  /// `true` khi đây là lịch mặc định (không suy ra được từ văn bản thật).
  final bool isFallback;

  static const standard = PaymentSchedule._([
    PaymentStage(label: 'Cọc', percent: 50),
    PaymentStage(label: 'Duyệt nháp', percent: 30),
    PaymentStage(label: 'Bàn giao', percent: 20),
  ], isFallback: true);

  /// Suy ra các đợt thanh toán từ chuỗi tự do, ví dụ
  /// `'Cọc 50%, duyệt nháp 30%, bàn giao 20%'`. Rơi về [standard] khi
  /// `paymentTerms` trống, tìm được dưới 2 đợt, hoặc tổng % vượt quá 100
  /// (dữ liệu vô lý — không tin được).
  factory PaymentSchedule.parse(String? paymentTerms) {
    if (paymentTerms == null || paymentTerms.trim().isEmpty) return standard;
    final matches = RegExp(
      r'([^,;\n.]{0,24}?)\s*(\d{1,3})\s*%',
    ).allMatches(paymentTerms).take(4).toList();
    if (matches.length < 2) return standard;
    final stages = matches
        .map(
          (m) => PaymentStage(
            label: _capitalize(m.group(1)!.trim()),
            percent: int.parse(m.group(2)!),
          ),
        )
        .toList();
    final sum = stages.fold<int>(0, (a, s) => a + s.percent);
    if (sum > 100) return standard;
    return PaymentSchedule._(stages, isFallback: false);
  }

  int get totalPercent => stages.fold<int>(0, (a, s) => a + s.percent);

  bool get isComplete => totalPercent == 100;

  /// TRA CỨU CỐ ĐỊNH, KHÔNG PHẢI CÔNG THỨC — phải khớp đúng các giá trị bản
  /// phác thảo gốc dùng (0.9, 0.62, 0.35 cho 3 đợt), không có quan hệ tuyến
  /// tính với "weight"/index nào cả, nên KHÔNG được thay bằng công thức suy
  /// ra.
  static const List<double> _opacityRamp = [0.9, 0.62, 0.35, 0.2];

  double opacityAt(int i) => i < _opacityRamp.length ? _opacityRamp[i] : 0.2;
}

String _capitalize(String s) =>
    s.isEmpty ? s : (s[0].toUpperCase() + s.substring(1));
