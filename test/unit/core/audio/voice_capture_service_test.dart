import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/audio/voice_capture_service.dart';
import 'package:solodesk_mobile/core/services/speech_service.dart';

class _MockSpeechService extends Mock implements SpeechService {}

void main() {
  late _MockSpeechService mockSpeech;
  late VoiceCaptureService service;

  setUp(() {
    mockSpeech = _MockSpeechService();
    service = VoiceCaptureService(
      speechService: mockSpeech,
      permissionRequester: () async => true, // always granted in tests
    );
  });

  group('VoiceCaptureService', () {
    test('initialize returns false when permission denied', () async {
      final svc = VoiceCaptureService(
        speechService: mockSpeech,
        permissionRequester: () async => false,
      );
      final result = await svc.initialize();
      expect(result, isFalse);
      verifyNever(() => mockSpeech.initialize());
    });

    test('initialize calls speech initialize when permission granted', () async {
      when(() => mockSpeech.initialize()).thenAnswer((_) async => true);
      final result = await service.initialize();
      expect(result, isTrue);
      verify(() => mockSpeech.initialize()).called(1);
    });

    test('isListening delegates to speech service', () {
      when(() => mockSpeech.isListening).thenReturn(false);
      expect(service.isListening, isFalse);
    });

    test('isAvailable delegates to speech service', () {
      when(() => mockSpeech.isAvailable).thenReturn(true);
      expect(service.isAvailable, isTrue);
    });

    test('stop delegates to speech service', () async {
      when(() => mockSpeech.stop()).thenAnswer((_) async {});
      await service.stop();
      verify(() => mockSpeech.stop()).called(1);
    });

    test('cancel delegates to speech service', () async {
      when(() => mockSpeech.cancel()).thenAnswer((_) async {});
      await service.cancel();
      verify(() => mockSpeech.cancel()).called(1);
    });

    test('startListening delegates to speech service', () async {
      when(() => mockSpeech.startListening(
            onResult: any(named: 'onResult'),
            onDone: any(named: 'onDone'),
            onSoundLevel: any(named: 'onSoundLevel'),
          )).thenAnswer((_) async {});

      await service.startListening(
        onResult: (_, __) {},
        onDone: () {},
      );

      verify(() => mockSpeech.startListening(
            onResult: any(named: 'onResult'),
            onDone: any(named: 'onDone'),
            onSoundLevel: any(named: 'onSoundLevel'),
          )).called(1);
    });
  });
}
