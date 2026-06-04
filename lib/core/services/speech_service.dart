import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Wraps [SpeechToText] với locale vi-VN để nhận dạng tiếng Việt + English mix.
class SpeechService {
  final SpeechToText _stt = SpeechToText();
  bool _initialized = false;

  // Callback được set khi gọi startListening, dùng để notify screen khi
  // engine tự dừng (timeout/silence) mà không qua stop().
  void Function()? _onDone;

  bool get isListening => _stt.isListening;
  bool get isAvailable => _initialized;

  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _stt.initialize(
      onError: _handleError,
      onStatus: _handleStatus,
    );
    return _initialized;
  }

  void _handleError(SpeechRecognitionError error) {
    // error_speech_timeout  → user dừng nói / im lặng quá lâu → bình thường,
    //                          engine tự dừng, onStatus('done') sẽ theo sau.
    // error_no_match        → engine không nhận ra nhưng đã thử → cũng bình thường.
    // Các lỗi khác (network, permission…) → bỏ qua, screen tự biết qua isListening.
  }

  void _handleStatus(String status) {
    // 'done' là trạng thái cuối dứt khoát — engine đã dừng hoàn toàn.
    // 'notListening' KHÔNG dùng vì nó cũng fire ngay đầu khi listen() khởi động,
    // sẽ trigger onDone sai thời điểm.
    if (status == 'done') {
      _onDone?.call();
    }
  }

  /// [onResult]  — text partial/final real-time.
  /// [onDone]    — engine đã dừng hẳn (timeout, silence, hoặc isFinal).
  /// [onSoundLevel] — mức âm thanh 0.0–1.0.
  Future<void> startListening({
    required void Function(String words, bool isFinal) onResult,
    required void Function() onDone,
    void Function(double level)? onSoundLevel,
  }) async {
    if (!_initialized) return;
    _onDone = onDone;
    await _stt.listen(
      onResult: (r) => onResult(r.recognizedWords, r.finalResult),
      localeId: 'vi-VN',
      onSoundLevelChange: onSoundLevel != null
          ? (level) => onSoundLevel((level.clamp(-2, 10) + 2) / 12)
          : null,
      listenFor: const Duration(minutes: 3),
      pauseFor: const Duration(seconds: 4),
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
      ),
    );
  }

  Future<void> stop() async {
    _onDone = null;
    await _stt.stop();
  }

  Future<void> cancel() async {
    _onDone = null;
    await _stt.cancel();
  }
}
