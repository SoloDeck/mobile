import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'url_opener.g.dart';

/// Mở một liên kết ra ngoài ứng dụng.
///
/// Tồn tại như một interface vì hai lý do:
///
/// 1. Trong `flutter test` không có plugin nền tảng, gọi thẳng [launchUrl] sẽ
///    ném `MissingPluginException`. Test ghi đè [urlOpenerProvider] bằng bản
///    giả thay vì phải giả lập kênh nền tảng.
/// 2. Tầng nghiệp vụ chỉ cần biết "mở được hay không", không cần biết
///    `url_launcher`.
abstract interface class UrlOpener {
  /// Trả về `true` nếu đã mở được. Không ném khi liên kết hỏng — người gọi
  /// thường có phương án dự phòng để thử tiếp.
  Future<bool> open(String rawUrl);
}

class UrlLauncherUrlOpener implements UrlOpener {
  const UrlLauncherUrlOpener();

  @override
  Future<bool> open(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl.trim());
    // Thiếu scheme thì không phải liên kết mở được — `Uri.tryParse` khá dễ dãi
    // nên phải tự kiểm tra thêm.
    if (uri == null || uri.scheme.isEmpty) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      // Chưa cài ứng dụng đích, hoặc nền tảng từ chối — coi như không mở được
      // để người gọi rơi xuống phương án kế tiếp.
      return false;
    }
  }
}

@Riverpod(keepAlive: true)
UrlOpener urlOpener(Ref ref) => const UrlLauncherUrlOpener();
