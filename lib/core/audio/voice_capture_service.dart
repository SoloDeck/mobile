import 'package:permission_handler/permission_handler.dart';
import 'package:solodesk_mobile/core/services/speech_service.dart';

class VoiceCaptureService {
  VoiceCaptureService({
    SpeechService? speechService,
    Future<bool> Function()? permissionRequester,
  })  : _speech = speechService ?? SpeechService(),
        _permissionRequester =
            permissionRequester ?? _defaultPermissionRequester;

  final SpeechService _speech;
  final Future<bool> Function() _permissionRequester;

  static Future<bool> _defaultPermissionRequester() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  bool get isListening => _speech.isListening;
  bool get isAvailable => _speech.isAvailable;

  Future<bool> requestPermission() => _permissionRequester();

  Future<bool> initialize() async {
    final granted = await requestPermission();
    if (!granted) return false;
    return _speech.initialize();
  }

  Future<void> startListening({
    required void Function(String words, bool isFinal) onResult,
    required void Function() onDone,
    void Function(double level)? onSoundLevel,
  }) =>
      _speech.startListening(
        onResult: onResult,
        onDone: onDone,
        onSoundLevel: onSoundLevel,
      );

  Future<void> stop() => _speech.stop();
  Future<void> cancel() => _speech.cancel();
}
