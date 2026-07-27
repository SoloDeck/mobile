import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_clock.g.dart';

/// Nguồn thời gian duy nhất của tầng nghiệp vụ.
///
/// Nhiều màn hiển thị thời gian tương đối — "Trễ 6 ngày", "sửa 3 ngày trước",
/// "hiệu lực đến 08/08/2026". Gọi thẳng [DateTime.now] trong widget khiến các
/// chuỗi đó đổi theo ngày chạy test, nên mọi chỗ tính thời gian tương đối phải
/// đi qua provider này để test ghim được một mốc cố định:
///
/// ```dart
/// appClockProvider.overrideWithValue(() => DateTime(2026, 7, 25))
/// ```
@Riverpod(keepAlive: true)
DateTime Function() appClock(Ref ref) => DateTime.now;
