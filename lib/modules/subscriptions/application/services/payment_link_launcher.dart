import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/services/url_opener.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/payment_intent.dart';

part 'payment_link_launcher.g.dart';

/// Mở liên kết thanh toán MoMo theo thứ tự ưu tiên — backend gán CỨNG
/// `type='checkout_url'` cho MỌI trường hợp nên KHÔNG BAO GIỜ switch theo
/// `type`; deeplink `momo://` nằm ở `instructions`, không phải `url`.
///
/// Thứ tự là **payUrl web trước, deeplink sau**: deeplink `momo://` của môi
/// trường sandbox trỏ vào app MoMo production, app không tìm thấy giao dịch
/// và báo "giao dịch đã hết hạn hoặc không tồn tại". Trang payUrl
/// (test-payment.momo.vn / payment.momo.vn) luôn khớp đúng môi trường tạo
/// giao dịch nên đáng tin hơn; deeplink chỉ còn là phương án dự phòng khi
/// không mở được trình duyệt, và QR là chốt chặn cuối.
class PaymentLinkLauncher {
  const PaymentLinkLauncher(this._urlOpener);

  final UrlOpener _urlOpener;

  /// Trả về true nếu mở được một trong hai liên kết (QR không tính vì QR
  /// không "mở" được — QR chỉ hiển thị trong UI, xem [PaymentLinkResult.showQr]).
  Future<PaymentLinkResult> open(PaymentLink link) async {
    if (link.url != null && await _urlOpener.open(link.url!)) {
      return PaymentLinkResult.opened;
    }
    if (link.instructions != null &&
        await _urlOpener.open(link.instructions!)) {
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
