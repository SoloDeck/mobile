// `localeId`/`listenFor`/`pauseFor` đã bị speech_to_text đánh dấu deprecated,
// nhưng `SpeechService.startListening` vẫn truyền chúng (xem
// lib/core/services/speech_service.dart) — stub phải khai đúng bộ tham số của
// lời gọi thật thì mocktail mới khớp. Bỏ deprecation ở đây là chuyện của lib,
// không phải của test.
// ignore_for_file: deprecated_member_use

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/services/speech_service.dart';
import 'package:speech_to_text/speech_to_text.dart';

class _MockSpeechToText extends Mock implements SpeechToText {}

/// `onDone` là tín hiệu duy nhất báo cho màn hình biết phiên ghi âm đã kết
/// thúc. Có hai đường tới nó — người dùng bấm dừng, và engine tự dừng vì im
/// lặng quá lâu — và cả hai phải trông giống hệt nhau với bên gọi.
///
/// Nhóm test này khoá lại một lỗi đã có thật: `stop()` từng gán `_onDone = null`
/// *trước* khi dừng engine, nên đường bấm-dừng-tay im lặng nuốt mất tín hiệu và
/// màn ghi âm kẹt vĩnh viễn ở trạng thái đang thu.
void main() {
  late _MockSpeechToText stt;
  late SpeechService service;
  late SpeechStatusListener emitStatus;

  setUp(() async {
    stt = _MockSpeechToText();

    when(
      () => stt.initialize(
        onError: any(named: 'onError'),
        onStatus: any(named: 'onStatus'),
      ),
    ).thenAnswer((invocation) async {
      // Giữ lại listener để test tự đóng vai engine phát trạng thái.
      emitStatus = invocation.namedArguments[#onStatus] as SpeechStatusListener;
      return true;
    });
    when(
      () => stt.listen(
        onResult: any(named: 'onResult'),
        localeId: any(named: 'localeId'),
        onSoundLevelChange: any(named: 'onSoundLevelChange'),
        listenFor: any(named: 'listenFor'),
        pauseFor: any(named: 'pauseFor'),
        listenOptions: any(named: 'listenOptions'),
      ),
    ).thenAnswer((_) async {});
    when(() => stt.stop()).thenAnswer((_) async {});
    when(() => stt.cancel()).thenAnswer((_) async {});

    service = SpeechService(speechToText: stt);
    await service.initialize();
  });

  group('SpeechService', () {
    test('stop() phát onDone đúng một lần', () async {
      var calls = 0;
      await service.startListening(onResult: (_, _) {}, onDone: () => calls++);

      await service.stop();

      expect(calls, 1);
      verify(() => stt.stop()).called(1);
    });

    test('engine phát done muộn sau stop() thì không chạy lần hai', () async {
      var calls = 0;
      await service.startListening(onResult: (_, _) {}, onDone: () => calls++);

      await service.stop();
      // Android/iOS có thể vẫn phát 'done' sau khi stop() trả về.
      emitStatus('done');

      expect(calls, 1);
    });

    test('cancel() không phát onDone', () async {
      var calls = 0;
      await service.startListening(onResult: (_, _) {}, onDone: () => calls++);

      await service.cancel();
      emitStatus('done');

      expect(calls, 0);
      verify(() => stt.cancel()).called(1);
    });

    test('engine tự dừng thì onDone chạy', () async {
      var calls = 0;
      await service.startListening(onResult: (_, _) {}, onDone: () => calls++);

      emitStatus('done');

      expect(calls, 1);
    });

    test("trạng thái 'notListening' không bị nhầm là kết thúc", () async {
      var calls = 0;
      await service.startListening(onResult: (_, _) {}, onDone: () => calls++);

      // speech_to_text phát 'notListening' ngay lúc listen() khởi động; coi nó
      // là kết thúc sẽ cắt phiên ghi ngay khi vừa bắt đầu.
      emitStatus('notListening');

      expect(calls, 0);
    });

    test('startListening không làm gì khi chưa initialize', () async {
      final fresh = SpeechService(speechToText: stt);

      await fresh.startListening(onResult: (_, _) {}, onDone: () {});

      // listen() chỉ được gọi bởi service đã initialize ở setUp, không phải
      // bởi `fresh`.
      verifyNever(
        () => stt.listen(
          onResult: any(named: 'onResult'),
          localeId: any(named: 'localeId'),
          onSoundLevelChange: any(named: 'onSoundLevelChange'),
          listenFor: any(named: 'listenFor'),
          pauseFor: any(named: 'pauseFor'),
          listenOptions: any(named: 'listenOptions'),
        ),
      );
    });
  });
}
