import 'package:freezed_annotation/freezed_annotation.dart';

/// Trạng thái của một payment intent MoMo. Mirrors the backend
/// `PaymentIntentStatus` enum. Payment intent hết hạn sau 15 phút kể từ khi
/// tạo (server tính, client đọc field `expires_at`).
enum PaymentIntentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('succeeded')
  succeeded,
  @JsonValue('failed')
  failed,
  @JsonValue('expired')
  expired,
  @JsonValue('cancelled')
  cancelled,
}

extension PaymentIntentStatusX on PaymentIntentStatus {
  /// Snake-case value the backend expects (matches the `@JsonValue` strings).
  String get wireValue => switch (this) {
    PaymentIntentStatus.pending => 'pending',
    PaymentIntentStatus.processing => 'processing',
    PaymentIntentStatus.succeeded => 'succeeded',
    PaymentIntentStatus.failed => 'failed',
    PaymentIntentStatus.expired => 'expired',
    PaymentIntentStatus.cancelled => 'cancelled',
  };

  String get label => switch (this) {
    PaymentIntentStatus.pending => 'Chờ thanh toán',
    PaymentIntentStatus.processing => 'Đang xử lý',
    PaymentIntentStatus.succeeded => 'Thanh toán thành công',
    PaymentIntentStatus.failed => 'Thanh toán thất bại',
    PaymentIntentStatus.expired => 'Đã hết hạn',
    PaymentIntentStatus.cancelled => 'Đã huỷ',
  };

  /// Trạng thái cuối cùng — không còn thay đổi nữa, vòng lặp poll nên dừng.
  bool get isSettled =>
      this == PaymentIntentStatus.succeeded ||
      this == PaymentIntentStatus.failed ||
      this == PaymentIntentStatus.expired ||
      this == PaymentIntentStatus.cancelled;
}

PaymentIntentStatus paymentIntentStatusFromWire(String value) =>
    switch (value) {
      'pending' => PaymentIntentStatus.pending,
      'processing' => PaymentIntentStatus.processing,
      'succeeded' => PaymentIntentStatus.succeeded,
      'failed' => PaymentIntentStatus.failed,
      'expired' => PaymentIntentStatus.expired,
      'cancelled' => PaymentIntentStatus.cancelled,
      _ => throw ArgumentError.value(
        value,
        'value',
        'Unknown payment intent status',
      ),
    };
