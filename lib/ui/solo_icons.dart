import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';

/// Một hình trong bộ icon: nét vẽ hoặc mảng tô, theo hệ toạ độ 24 × 24 của bản
/// phác thảo.
sealed class SoloShape {
  const SoloShape();
}

/// Đường vẽ theo cú pháp `d` của SVG. Vẽ bằng nét, không tô.
class SoloPath extends SoloShape {
  const SoloPath(this.d, {this.filled = false});

  final String d;
  final bool filled;
}

/// `<circle>` trong bản phác thảo.
class SoloCircle extends SoloShape {
  const SoloCircle(this.cx, this.cy, this.r, {this.filled = false});

  final double cx;
  final double cy;
  final double r;
  final bool filled;
}

/// `<rect rx>` trong bản phác thảo.
class SoloRect extends SoloShape {
  const SoloRect(this.x, this.y, this.w, this.h, this.rx);

  final double x;
  final double y;
  final double w;
  final double h;
  final double rx;
}

/// Định nghĩa một icon: tên để tra ngược về bản phác thảo, và các hình tạo nên nó.
class SoloIconData {
  const SoloIconData(this.name, this.shapes);

  /// Đúng id `<symbol>` trong `design/solodesk-mobile-ui.html`, ví dụ `ic-home`.
  final String name;
  final List<SoloShape> shapes;
}

/// Bộ 20 icon của SoloDesk, chép từ khối `<defs>` trong bản phác thảo.
///
/// **Dùng khi:** cần bất kỳ icon nào trong `lib/ui/` hoặc `lib/features/`.
///
/// **KHÔNG dùng khi:** cần một icon không có trong danh sách này. Đừng lấy tạm
/// `Icons.*` của Material — nét của Material dày và bo khác hẳn, đặt cạnh bộ này
/// sẽ lộ ngay. Thiếu icon thì thêm `<symbol>` vào bản phác thảo trước, rồi mới
/// chép sang đây.
abstract final class SoloIcons {
  static const SoloIconData home = SoloIconData('ic-home', [
    SoloPath('M3.5 10.6 12 3.7l8.5 6.9V20a1 1 0 0 1-1 1h-15a1 1 0 0 1-1-1z'),
    SoloPath('M9.5 21v-6h5v6'),
  ]);

  static const SoloIconData board = SoloIconData('ic-board', [
    SoloRect(3, 4, 5, 16, 1.3),
    SoloRect(9.5, 4, 5, 11, 1.3),
    SoloRect(16, 4, 5, 7, 1.3),
  ]);

  static const SoloIconData plus = SoloIconData('ic-plus', [
    SoloPath('M12 5v14M5 12h14'),
  ]);

  static const SoloIconData folder = SoloIconData('ic-folder', [
    SoloPath(
      'M3 6.5A1.5 1.5 0 0 1 4.5 5h4.2l2 2.4h8.8A1.5 1.5 0 0 1 21 8.9v9.6'
      'a1.5 1.5 0 0 1-1.5 1.5h-15A1.5 1.5 0 0 1 3 18.5z',
    ),
  ]);

  static const SoloIconData user = SoloIconData('ic-user', [
    SoloCircle(12, 8.4, 3.7),
    SoloPath('M4.8 20c.7-3.6 3.7-5.6 7.2-5.6s6.5 2 7.2 5.6'),
  ]);

  static const SoloIconData bell = SoloIconData('ic-bell', [
    SoloPath('M6.2 9.6a5.8 5.8 0 0 1 11.6 0v4.6l1.7 2.2H4.5l1.7-2.2z'),
    SoloPath('M10 20h4'),
  ]);

  static const SoloIconData mic = SoloIconData('ic-mic', [
    SoloRect(9, 2.8, 6, 11.4, 3),
    SoloPath('M5.5 11.4a6.5 6.5 0 0 0 13 0M12 17.9V21'),
  ]);

  static const SoloIconData chevron = SoloIconData('ic-chev', [
    SoloPath('M9.5 5.5 16 12l-6.5 6.5'),
  ]);

  static const SoloIconData back = SoloIconData('ic-back', [
    SoloPath('M14.5 5.5 8 12l6.5 6.5'),
  ]);

  static const SoloIconData check = SoloIconData('ic-check', [
    SoloPath('M4.5 12.5 9.5 17.5 19.5 6.5'),
  ]);

  static const SoloIconData clock = SoloIconData('ic-clock', [
    SoloCircle(12, 12, 8.5),
    SoloPath('M12 7.2V12l3.2 2.1'),
  ]);

  static const SoloIconData cash = SoloIconData('ic-cash', [
    SoloRect(2.8, 6, 18.4, 12, 2),
    SoloCircle(12, 12, 2.7),
  ]);

  static const SoloIconData file = SoloIconData('ic-file', [
    SoloPath('M6 3.2h7.4L18.5 8v12.8H6z'),
    SoloPath('M13.2 3.2V8h5.1'),
  ]);

  static const SoloIconData image = SoloIconData('ic-image', [
    SoloRect(3, 4.5, 18, 15, 2),
    SoloCircle(8.6, 9.7, 1.6),
    SoloPath('M3.6 17.2 9 12l3.6 3.4L16 12.4l4.4 4.3'),
  ]);

  static const SoloIconData search = SoloIconData('ic-search', [
    SoloCircle(11, 11, 6.6),
    SoloPath('M15.8 15.8 21 21'),
  ]);

  static const SoloIconData send = SoloIconData('ic-send', [
    SoloPath('M21 3 10.5 13.6'),
    SoloPath('M21 3l-6.8 18-3.7-7.4L3 9.9z'),
  ]);

  static const SoloIconData ai = SoloIconData('ic-ai', [
    SoloPath('M12 2.6 14 9l6.4 2-6.4 2-2 6.4-2-6.4L3.6 11 10 9z'),
  ]);

  static const SoloIconData dots = SoloIconData('ic-dots', [
    SoloCircle(5.5, 12, 1.4, filled: true),
    SoloCircle(12, 12, 1.4, filled: true),
    SoloCircle(18.5, 12, 1.4, filled: true),
  ]);

  static const SoloIconData wifiOff = SoloIconData('ic-wifi-off', [
    SoloPath('M3 4l18 16'),
    SoloPath(
      'M5 10.5a13 13 0 0 1 4-2.4M2 7.4A17.5 17.5 0 0 1 8 4'
      'M16 4.6a17.4 17.4 0 0 1 6 2.8M15 8.4a12.8 12.8 0 0 1 4 2.1',
    ),
    SoloPath('M8.8 14.2a7.2 7.2 0 0 1 6.4 0'),
    SoloCircle(12, 18.4, 1.1, filled: true),
  ]);

  static const SoloIconData tag = SoloIconData('ic-tag', [
    SoloPath('M3.5 11.4V4h7.4l9.6 9.6-7.4 7.4z'),
    SoloCircle(7.6, 7.6, 1.4),
  ]);

  static const SoloIconData settings = SoloIconData('ic-settings', [
    SoloCircle(12, 12, 7.5),
    SoloPath(
      'M19.6 12H21.6M17.4 17.4 18.8 18.8M12 19.6V21.6M6.6 17.4 5.2 18.8'
      'M4.4 12H2.4M6.6 6.6 5.2 5.2M12 4.4V2.4M17.4 6.6 18.8 5.2',
    ),
    SoloCircle(12, 12, 2.6),
  ]);

  static const SoloIconData lock = SoloIconData('ic-lock', [
    SoloPath('M7.7 10V7.6A4.3 4.3 0 0 1 16.3 7.6V10'),
    SoloRect(5, 10, 14, 9.5, 2),
    SoloCircle(12, 14.1, 1.3, filled: true),
    SoloPath('M12 15.4V17.2'),
  ]);

  static const SoloIconData fingerprint = SoloIconData('ic-fingerprint', [
    SoloPath(
      'M5.5 15.5A6.5 7.5 0 0 1 18.5 15.5'
      'M7.3 15A4.7 6 0 0 1 16.7 15'
      'M9 14.4A3 4.6 0 0 1 15 14.4'
      'M10.6 13.7A1.4 3 0 0 1 13.4 13.7',
    ),
    SoloPath('M12 17.6V19.6'),
  ]);

  static const SoloIconData download = SoloIconData('ic-download', [
    SoloPath('M12 3.5V15'),
    SoloPath('M7.3 10.8 12 15.4 16.7 10.8'),
    SoloPath('M4.5 19.6H19.5'),
  ]);

  static const SoloIconData logout = SoloIconData('ic-logout', [
    SoloPath('M13 4.2H7A1.5 1.5 0 0 0 5.5 5.7V18.3A1.5 1.5 0 0 0 7 19.8H13'),
    SoloPath('M9.5 12H20.5M17 8.3 20.5 12 17 15.7'),
  ]);

  static const SoloIconData trash = SoloIconData('ic-trash', [
    SoloPath('M4 6.5H20'),
    SoloPath('M9.5 6.5V5A1 1 0 0 1 10.5 4H13.5A1 1 0 0 1 14.5 5V6.5'),
    SoloPath(
      'M6.3 6.5L7.3 19.6A1.5 1.5 0 0 0 8.8 21H15.2A1.5 1.5 0 0 0 16.7 19.6'
      'L17.7 6.5',
    ),
    SoloPath('M10 10V17.5M14 10V17.5'),
  ]);

  static const SoloIconData link = SoloIconData('ic-link', [
    SoloRect(3, 7.5, 10, 6, 3),
    SoloRect(11, 10.5, 10, 6, 3),
  ]);

  static const SoloIconData language = SoloIconData('ic-language', [
    SoloCircle(12, 12, 8.2),
    SoloPath('M3.8 12H20.2'),
    SoloPath('M12 3.8C8.3 6.8 8.3 17.2 12 20.2C15.7 17.2 15.7 6.8 12 3.8'),
  ]);

  static const SoloIconData currencyDong = SoloIconData('ic-currency-dong', [
    SoloPath('M8 5V19'),
    SoloPath('M8 5H10.5A6.5 6.5 0 0 1 10.5 18H8'),
    SoloPath('M5.3 11.6H14.7'),
  ]);

  static const SoloIconData moon = SoloIconData('ic-moon', [
    SoloPath('M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79Z', filled: true),
  ]);

  /// Tra icon theo id `<symbol>`, để đối chiếu nhanh với bản phác thảo.
  static const Map<String, SoloIconData> byName = {
    'ic-home': home,
    'ic-board': board,
    'ic-plus': plus,
    'ic-folder': folder,
    'ic-user': user,
    'ic-bell': bell,
    'ic-mic': mic,
    'ic-chev': chevron,
    'ic-back': back,
    'ic-check': check,
    'ic-clock': clock,
    'ic-cash': cash,
    'ic-file': file,
    'ic-image': image,
    'ic-search': search,
    'ic-send': send,
    'ic-ai': ai,
    'ic-dots': dots,
    'ic-wifi-off': wifiOff,
    'ic-tag': tag,
    'ic-settings': settings,
    'ic-lock': lock,
    'ic-fingerprint': fingerprint,
    'ic-download': download,
    'ic-logout': logout,
    'ic-trash': trash,
    'ic-link': link,
    'ic-language': language,
    'ic-currency-dong': currencyDong,
    'ic-moon': moon,
  };
}

/// Vẽ một icon của bộ SoloDesk.
///
/// **Dùng khi:** cần một icon ở bất kỳ đâu trong tầng giao diện. Ba cỡ khớp
/// đúng `.i` / `.i.sm` / `.i.xs` của bản phác thảo — [md] 20, [sm] 16, [xs] 13.
///
/// **KHÔNG dùng khi:** icon là nút bấm — bọc bằng `IconButtonBox` để có vùng
/// chạm 44 × 44, chứ đừng gắn `GestureDetector` thẳng lên icon 13pt.
///
/// [label] là bắt buộc theo nghĩa thực hành: icon **đứng một mình** phải có nhãn
/// tiếng Việt cho trình đọc màn hình. Chỉ truyền `null` khi icon nằm cạnh chữ đã
/// nói đúng điều đó rồi — khi ấy icon là trang trí và bị loại khỏi cây ngữ nghĩa.
class SoloIcon extends StatelessWidget {
  const SoloIcon(
    this.icon, {
    super.key,
    required this.label,
    this.size = md,
    this.color = AppColors.ink,
    this.strokeWidth = 1.7,
  });

  /// Cỡ mặc định, `.i` trong bản phác thảo.
  static const double md = 20;

  /// `.i.sm` — icon đứng cạnh một dòng chữ.
  static const double sm = 16;

  /// `.i.xs` — icon bên trong chip hoặc nút nhỏ.
  static const double xs = 13;

  final SoloIconData icon;

  /// Nhãn tiếng Việt cho trình đọc màn hình. `null` = icon trang trí.
  final String? label;

  final double size;
  final Color color;

  /// Bề dày nét trong hệ toạ độ 24 × 24, tự co giãn theo [size].
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final painted = CustomPaint(
      size: Size.square(size),
      painter: _SoloIconPainter(
        icon: icon,
        color: color,
        strokeWidth: strokeWidth,
      ),
    );

    if (label == null) {
      return ExcludeSemantics(child: painted);
    }
    return Semantics(label: label, image: true, child: painted);
  }
}

class _SoloIconPainter extends CustomPainter {
  const _SoloIconPainter({
    required this.icon,
    required this.color,
    required this.strokeWidth,
  });

  final SoloIconData icon;
  final Color color;
  final double strokeWidth;

  /// Hệ toạ độ gốc của mọi `<symbol>` trong bản phác thảo.
  static const double _viewBox = 24;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Co giãn cả nét lẫn hình, đúng cách SVG hành xử.
    canvas.scale(size.width / _viewBox, size.height / _viewBox);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (final shape in icon.shapes) {
      switch (shape) {
        case SoloPath(:final d, :final filled):
          canvas.drawPath(_cachedPath(d), filled ? fill : stroke);
        case SoloCircle(:final cx, :final cy, :final r, :final filled):
          canvas.drawCircle(Offset(cx, cy), r, filled ? fill : stroke);
        case SoloRect(:final x, :final y, :final w, :final h, :final rx):
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x, y, w, h),
              Radius.circular(rx),
            ),
            stroke,
          );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SoloIconPainter old) =>
      old.icon != icon || old.color != color || old.strokeWidth != strokeWidth;
}

/// Bộ icon là hằng số nên mỗi chuỗi `d` chỉ cần dựng `Path` đúng một lần cho cả
/// vòng đời app — `paint` chạy lại rất nhiều, phân tích lại chuỗi mỗi lần là phí.
final Map<String, Path> _pathCache = {};

Path _cachedPath(String d) => _pathCache[d] ??= parseSvgPath(d);

/// Dựng `Path` từ thuộc tính `d` của SVG.
///
/// Chỉ hỗ trợ đúng tập lệnh mà 20 icon trong bản phác thảo dùng:
/// `M m L l H h V v C c S s A a Z z`. Gặp lệnh lạ thì ném lỗi ngay thay vì vẽ
/// sai lặng lẽ — icon vẽ thiếu một nét rất khó phát hiện bằng mắt.
@visibleForTesting
Path parseSvgPath(String d) {
  final path = Path();
  final tokens = _tokenize(d);

  var current = Offset.zero;
  var subpathStart = Offset.zero;
  Offset? lastCubicControl;
  var index = 0;
  var command = '';

  double next() => tokens[index++] as double;

  while (index < tokens.length) {
    final token = tokens[index];
    if (token is String) {
      command = token;
      index++;
    } else if (command == 'M') {
      // Toạ độ thừa sau moveto được hiểu là lineto, đúng chuẩn SVG.
      command = 'L';
    } else if (command == 'm') {
      command = 'l';
    }

    switch (command) {
      case 'M':
        current = Offset(next(), next());
        subpathStart = current;
        path.moveTo(current.dx, current.dy);
        lastCubicControl = null;
      case 'm':
        current += Offset(next(), next());
        subpathStart = current;
        path.moveTo(current.dx, current.dy);
        lastCubicControl = null;
      case 'L':
        current = Offset(next(), next());
        path.lineTo(current.dx, current.dy);
        lastCubicControl = null;
      case 'l':
        current += Offset(next(), next());
        path.lineTo(current.dx, current.dy);
        lastCubicControl = null;
      case 'H':
        current = Offset(next(), current.dy);
        path.lineTo(current.dx, current.dy);
        lastCubicControl = null;
      case 'h':
        current += Offset(next(), 0);
        path.lineTo(current.dx, current.dy);
        lastCubicControl = null;
      case 'V':
        current = Offset(current.dx, next());
        path.lineTo(current.dx, current.dy);
        lastCubicControl = null;
      case 'v':
        current += Offset(0, next());
        path.lineTo(current.dx, current.dy);
        lastCubicControl = null;
      case 'C' || 'c':
        final relative = command == 'c';
        final base = relative ? current : Offset.zero;
        final c1 = base + Offset(next(), next());
        final c2 = base + Offset(next(), next());
        final end = base + Offset(next(), next());
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        lastCubicControl = c2;
        current = end;
      case 'S' || 's':
        final relative = command == 's';
        final base = relative ? current : Offset.zero;
        // Điểm điều khiển đầu là phản chiếu của điểm điều khiển cuối trước đó.
        final c1 = lastCubicControl == null
            ? current
            : current * 2 - lastCubicControl;
        final c2 = base + Offset(next(), next());
        final end = base + Offset(next(), next());
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        lastCubicControl = c2;
        current = end;
      case 'A' || 'a':
        final relative = command == 'a';
        final rx = next();
        final ry = next();
        final rotation = next();
        final largeArc = next() != 0;
        final clockwise = next() != 0;
        final end = relative
            ? current + Offset(next(), next())
            : Offset(next(), next());
        path.arcToPoint(
          end,
          radius: Radius.elliptical(rx, ry),
          rotation: rotation,
          largeArc: largeArc,
          clockwise: clockwise,
        );
        current = end;
        lastCubicControl = null;
      case 'Z' || 'z':
        path.close();
        current = subpathStart;
        lastCubicControl = null;
      default:
        throw FormatException('Lệnh SVG chưa hỗ trợ: "$command" trong "$d"');
    }
  }

  return path;
}

/// Tách chuỗi `d` thành lệnh (`String`) và số (`double`).
List<Object> _tokenize(String d) {
  final tokens = <Object>[];
  final buffer = StringBuffer();

  void flush() {
    if (buffer.isEmpty) return;
    final text = buffer.toString();
    final value = double.tryParse(text);
    if (value == null) {
      throw FormatException('Không đọc được số "$text" trong "$d"');
    }
    tokens.add(value);
    buffer.clear();
  }

  for (var i = 0; i < d.length; i++) {
    final char = d[i];
    final code = d.codeUnitAt(i);

    final isLetter =
        (code >= 0x41 && code <= 0x5A) || (code >= 0x61 && code <= 0x7A);
    if (isLetter) {
      flush();
      tokens.add(char);
      continue;
    }
    if (char == ' ' || char == ',' || char == '\n' || char == '\t') {
      flush();
      continue;
    }
    // Dấu trừ bắt đầu một số mới, trừ khi nó là dấu mũ của ký hiệu khoa học.
    if (char == '-' && buffer.isNotEmpty && !buffer.toString().endsWith('e')) {
      flush();
    }
    // Dấu chấm thứ hai cũng bắt đầu một số mới: "1.5.5" là hai số.
    if (char == '.' && buffer.toString().contains('.')) {
      flush();
    }
    buffer.write(char);
  }
  flush();

  return tokens;
}
