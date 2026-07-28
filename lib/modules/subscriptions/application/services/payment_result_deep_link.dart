import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/services/deep_link_service.dart';

part 'payment_result_deep_link.g.dart';

/// Chuỗi CHÍNH XÁC backend chấp nhận làm `return_url` khi tạo checkout, và
/// cũng là scheme + host đã đăng ký ở `AndroidManifest.xml` / `Info.plist`.
/// Đổi ở đây thì phải đổi đồng bộ cả ba nơi lẫn backend.
const paymentResultDeepLink = 'solodesk://payment-result';

/// Lọc luồng deep link chung xuống đúng link kết quả thanh toán.
@riverpod
Stream<Uri> paymentResultDeepLinkStream(Ref ref) => ref
    .watch(deepLinkServiceProvider)
    .onLink
    .where((uri) => uri.scheme == 'solodesk' && uri.host == 'payment-result');
