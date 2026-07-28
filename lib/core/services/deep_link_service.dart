import 'package:app_links/app_links.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'deep_link_service.g.dart';

/// Luồng mọi deep link nhận được khi app đang chạy (warm resume).
///
/// Tồn tại như một interface vì hai lý do, giống [UrlOpener]:
///
/// 1. Trong `flutter test` không có plugin nền tảng — gọi thẳng `AppLinks()`
///    và lắng nghe stream của nó sẽ ném `MissingPluginException`. Test ghi đè
///    provider bằng một `Stream` giả.
/// 2. Tầng nghiệp vụ chỉ cần biết "có link mới", không cần biết `app_links`.
abstract interface class DeepLinkService {
  Stream<Uri> get onLink;
}

class AppLinksDeepLinkService implements DeepLinkService {
  AppLinksDeepLinkService() : _appLinks = AppLinks();

  final AppLinks _appLinks;

  @override
  Stream<Uri> get onLink => _appLinks.uriLinkStream;
}

@Riverpod(keepAlive: true)
DeepLinkService deepLinkService(Ref ref) => AppLinksDeepLinkService();
