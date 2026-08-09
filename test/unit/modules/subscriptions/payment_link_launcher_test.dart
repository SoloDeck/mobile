import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/core/services/url_opener.dart';
import 'package:solodesk_mobile/modules/subscriptions/application/services/payment_link_launcher.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/payment_intent.dart';

const _url = 'https://test-payment.momo.vn/v2/gateway/pay?s=abc123';
const _instructions = 'momo://app?action=payWithApp&sid=abc123';
const _qrCodeUrl = 'https://test-payment.momo.vn/qr/abc123.png';

/// Ghi lại URL của mỗi lần gọi [open] theo đúng thứ tự, trả kết quả theo
/// kịch bản đã cấu hình sẵn (một phần tử `bool` cho mỗi lần gọi).
class _RecordingUrlOpener implements UrlOpener {
  _RecordingUrlOpener(this._results);

  final List<bool> _results;
  final List<String> calls = [];

  @override
  Future<bool> open(String rawUrl) async {
    calls.add(rawUrl);
    return _results[calls.length - 1];
  }
}

const _fullLink = PaymentLink(
  type: 'checkout_url',
  url: _url,
  qrCodeUrl: _qrCodeUrl,
  instructions: _instructions,
);

void main() {
  test('tries the web payUrl (url) FIRST and stops there when it opens', () async {
    final opener = _RecordingUrlOpener([true]);
    final result = await PaymentLinkLauncher(opener).open(_fullLink);

    // payUrl trước deeplink: deeplink momo:// sandbox mở app MoMo production
    // và bị báo "giao dịch đã hết hạn hoặc không tồn tại" (Bug 4).
    expect(opener.calls, [_url]);
    expect(result, PaymentLinkResult.opened);
  });

  test('falls back to the momo:// deeplink when the payUrl fails', () async {
    final opener = _RecordingUrlOpener([false, true]);
    final result = await PaymentLinkLauncher(opener).open(_fullLink);

    expect(opener.calls, [_url, _instructions]);
    expect(result, PaymentLinkResult.opened);
  });

  test('falls back to the QR code last, without a third open() call', () async {
    final opener = _RecordingUrlOpener([false, false]);
    final result = await PaymentLinkLauncher(opener).open(_fullLink);

    expect(opener.calls, [_url, _instructions]);
    expect(result, PaymentLinkResult.showQr);
  });

  test('skips a missing url and goes straight to the deeplink', () async {
    final opener = _RecordingUrlOpener([true]);
    final result = await PaymentLinkLauncher(opener).open(
      const PaymentLink(
        type: 'checkout_url',
        url: null,
        qrCodeUrl: _qrCodeUrl,
        instructions: _instructions,
      ),
    );

    expect(opener.calls, [_instructions]);
    expect(result, PaymentLinkResult.opened);
  });

  test('reports unavailable when nothing opens and there is no QR', () async {
    final opener = _RecordingUrlOpener([false, false]);
    final result = await PaymentLinkLauncher(opener).open(
      const PaymentLink(
        type: 'checkout_url',
        url: _url,
        qrCodeUrl: null,
        instructions: _instructions,
      ),
    );

    expect(opener.calls, [_url, _instructions]);
    expect(result, PaymentLinkResult.unavailable);
  });
}
