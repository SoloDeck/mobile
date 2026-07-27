import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ba họ chữ của bản phác thảo và các file mà `assets/fonts/` cần có.
///
/// Tên họ phải khớp từng ký tự với `AppFontFamily` trong
/// `lib/theme/app_text.dart`, nếu không golden sẽ chụp bằng font thay thế mà
/// không báo gì.
const Map<String, List<String>> _soloFontFiles = {
  'Bricolage Grotesque': [
    'BricolageGrotesque-Regular.ttf',
    'BricolageGrotesque-Bold.ttf',
    'BricolageGrotesque-ExtraBold.ttf',
  ],
  'Be Vietnam Pro': [
    'BeVietnamPro-Regular.ttf',
    'BeVietnamPro-Medium.ttf',
    'BeVietnamPro-SemiBold.ttf',
    'BeVietnamPro-Bold.ttf',
  ],
  'IBM Plex Mono': [
    'IBMPlexMono-Regular.ttf',
    'IBMPlexMono-Medium.ttf',
    'IBMPlexMono-SemiBold.ttf',
  ],
};

/// `true` khi đủ cả ba họ chữ thật đã được nạp vào engine test.
///
/// Golden test **phải** treo `skip: !soloFontsLoaded` lên phần so ảnh. Chụp ảnh
/// vàng bằng font thay thế là tự tay tạo ra một ảnh sai rồi khoá nó lại làm
/// chuẩn — ảnh vàng chỉ có giá trị nếu lần đầu tiên nó đúng.
bool soloFontsLoaded = false;

/// Lý do bỏ qua phần so ảnh, in ra để không ai phải đoán.
String soloFontSkipReason = '';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadSoloFonts();
  return testMain();
}

/// Nạp font thẳng từ `assets/fonts/` bằng `dart:io`.
///
/// Cố ý **không** đọc qua `rootBundle`: làm vậy sẽ buộc phải khai báo `fonts:`
/// trong `pubspec.yaml`, mà khai báo trỏ tới file chưa tồn tại thì cả bộ test
/// hỏng ở khâu đóng gói asset. Cách này để bộ test chạy được ngay từ bây giờ và
/// tự động dùng font thật khi file có mặt.
Future<void> _loadSoloFonts() async {
  final dir = Directory('assets/fonts');
  if (!dir.existsSync()) {
    soloFontSkipReason =
        'chưa có thư mục assets/fonts/ — xem assets/fonts/README.md';
    return;
  }

  final missing = <String>[];
  for (final entry in _soloFontFiles.entries) {
    final loader = FontLoader(entry.key);
    var loadedAny = false;

    for (final fileName in entry.value) {
      final file = File('${dir.path}/$fileName');
      if (!file.existsSync()) {
        missing.add(fileName);
        continue;
      }
      final bytes = await file.readAsBytes();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
      loadedAny = true;
    }

    if (loadedAny) await loader.load();
  }

  if (missing.isEmpty) {
    soloFontsLoaded = true;
    return;
  }

  soloFontSkipReason =
      'thiếu ${missing.length} file font trong assets/fonts/: '
      '${missing.take(3).join(', ')}${missing.length > 3 ? '…' : ''}';
}
