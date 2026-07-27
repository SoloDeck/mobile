import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/payment_intent_status.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/dto/payment_intent_dto.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/mapper/subscription_mapper.dart';

/// `payment_link.type` LUÔN LÀ `'checkout_url'` bất kể thực tế (xem docstring
/// của `PaymentLink` domain entity) — `url` và `instructions` cố tình khác
/// nhau ở đây để phát hiện ngay nếu mapper lỡ đọc nhầm/hoán đổi hai trường.
Map<String, dynamic> _paymentIntentJson() => {
  'id': 'pi-1',
  'subscription_id': 'sub-1',
  'plan_id': 'plan-2',
  'provider': 'momo',
  'status': 'pending',
  'amount': '149000.00',
  'currency': 'VND',
  'payment_link': {
    'type': 'checkout_url',
    'url': 'https://payment.momo.vn/v2/gateway/pay?s=abc123',
    'qr_code_url': 'https://payment.momo.vn/qr/abc123.png',
    'instructions': 'momo://app?action=payWithApp&isScanQR=true&sid=abc123',
  },
  'provider_reference': null,
  'paid_at': null,
  'expires_at': '2026-07-27T10:15:00Z',
  'failure_reason': null,
};

void main() {
  group('PaymentIntentDto.fromJson -> toDomain', () {
    test(
      'keeps instructions as the real MoMo deeplink regardless of payment_link.type',
      () {
        final intent = PaymentIntentDto.fromJson(
          _paymentIntentJson(),
        ).toDomain();

        // `type` is carried through unchanged but must never drive behaviour.
        expect(intent.paymentLink.type, 'checkout_url');
        expect(
          intent.paymentLink.instructions,
          'momo://app?action=payWithApp&isScanQR=true&sid=abc123',
        );
        // `url` must stay the distinct value it was given — no swap with
        // `instructions`.
        expect(
          intent.paymentLink.url,
          'https://payment.momo.vn/v2/gateway/pay?s=abc123',
        );
        expect(
          intent.paymentLink.qrCodeUrl,
          'https://payment.momo.vn/qr/abc123.png',
        );

        expect(intent.status, PaymentIntentStatus.pending);
        expect(intent.amount, 149000.0);
        expect(intent.expiresAt, DateTime.parse('2026-07-27T10:15:00Z'));
      },
    );
  });

  test('subscription_mapper.dart never branches on payment_link.type '
      '(instructions is the real deeplink, not a type switch)', () {
    final source = File(
      'lib/modules/subscriptions/infrastructure/mapper/subscription_mapper.dart',
    ).readAsStringSync();

    expect(source.contains("== 'checkout_url'"), isFalse);
  });
}
