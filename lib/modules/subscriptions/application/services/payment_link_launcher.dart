import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/services/url_opener.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/payment_intent.dart';

part 'payment_link_launcher.g.dart';

/// Mở liên kết thanh toán MoMo theo thứ tự ưu tiên — backend gán CỨNG
/// `type='checkout_url'` cho MỌI trường hợp nên KHÔNG BAO GIỜ switch theo
/// `type`; deeplink thật nằm ở `instructions`, không phải `url`.
class PaymentLinkLauncher {
  const PaymentLinkLauncher(this._urlOpener);

  final UrlOpener _urlOpener;

  /// Trả về true nếu mở được một trong ba (deeplink/url/QR không tính vì QR
  /// không "mở" được — QR chỉ hiển thị trong UI, xem [PaymentLinkResult.showQr]).
  Future<PaymentLinkResult> open(PaymentLink link) async {
    if (link.instructions != null &&
        await _urlOpener.open(link.instructions!)) {
      return PaymentLinkResult.opened;
    }
    if (link.url != null && await _urlOpener.open(link.url!)) {
      return PaymentLinkResult.opened;
    }
    if (link.qrCodeUrl != null) return PaymentLinkResult.showQr;
    return PaymentLinkResult.unavailable;
  }
}

enum PaymentLinkResult { opened, showQr, unavailable }

@Riverpod(keepAlive: true)
PaymentLinkLauncher paymentLinkLauncher(Ref ref) =>
    PaymentLinkLauncher(ref.read(urlOpenerProvider));
