import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/audio/voice_capture_service.dart';
import 'package:solodesk_mobile/modules/voice_lead/application/usecases/capture_and_qualify_lead_usecase.dart';
import 'package:solodesk_mobile/modules/voice_lead/domain/entities/voice_lead_draft.dart';
import 'package:solodesk_mobile/modules/voice_lead/presentation/pages/voice_capture_page.dart';
import 'package:solodesk_mobile/modules/voice_lead/presentation/providers/voice_lead_provider.dart';

class _MockVoiceCaptureService extends Mock implements VoiceCaptureService {}

// Fake use case that satisfies mocktail
class _FakeUseCase extends Fake implements CaptureAndQualifyLeadUseCase {
  final VoiceLeadDraft? returnValue;
  String? capturedText;
  String? capturedClientId;
  bool called = false;

  _FakeUseCase(this.returnValue);

  @override
  Future<VoiceLeadDraft> call({
    required String transcribedText,
    required String clientId,
    String? serviceCategory,
  }) async {
    called = true;
    capturedText = transcribedText;
    capturedClientId = clientId;
    if (returnValue != null) return returnValue!;
    throw Exception('no return value');
  }
}

Widget _buildPage({
  VoiceCaptureService? service,
  CaptureAndQualifyLeadUseCase? useCase,
}) {
  final router = GoRouter(
    initialLocation: '/voice-capture',
    routes: [
      GoRoute(
        path: '/voice-capture',
        builder: (ctx, state) => const VoiceCapturePage(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      if (service != null)
        voiceCaptureServiceProvider.overrideWithValue(service),
      if (useCase != null)
        captureAndQualifyLeadUseCaseProvider.overrideWithValue(useCase),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  late _MockVoiceCaptureService mockSvc;

  setUp(() {
    mockSvc = _MockVoiceCaptureService();
    when(() => mockSvc.cancel()).thenAnswer((_) async {});
    when(() => mockSvc.isListening).thenReturn(false);
    when(() => mockSvc.isAvailable).thenReturn(false);
  });

  testWidgets('shows record button in idle state', (tester) async {
    await tester.pumpWidget(_buildPage(service: mockSvc));
    expect(find.byKey(const Key('record_button')), findsOneWidget);
  });

  testWidgets('record -> transcript displayed after recording', (tester) async {
    when(() => mockSvc.initialize()).thenAnswer((_) async => true);
    when(() => mockSvc.startListening(
          onResult: any(named: 'onResult'),
          onDone: any(named: 'onDone'),
          onSoundLevel: any(named: 'onSoundLevel'),
        )).thenAnswer((inv) async {
      final onResult = inv.namedArguments[#onResult] as void Function(String, bool);
      onResult('Tôi cần thiết kế logo', false);
    });
    when(() => mockSvc.stop()).thenAnswer((_) async {});
    when(() => mockSvc.isListening).thenReturn(true);

    final mockUseCase = _FakeUseCase(null); // not called in this test
    await tester.pumpWidget(_buildPage(service: mockSvc, useCase: mockUseCase));
    await tester.tap(find.byKey(const Key('record_button')));
    // Use pump(duration) instead of pumpAndSettle — the waveform animation runs
    // repeat(reverse:true) while recording, so pumpAndSettle would time out.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Transcript should appear
    expect(find.text('Tôi cần thiết kế logo'), findsOneWidget);
    // Stop button shows
    expect(find.byKey(const Key('stop_button')), findsOneWidget);
  });

  testWidgets('confirm -> dispatches POST (use case called)', (tester) async {
    const kDraft = VoiceLeadDraft(
      transcribedText: 'Logo design needed',
      qualificationScore: 0.9,
      recommendation: 'hot',
      suggestedDealTitle: 'Logo Design',
    );
    void Function()? capturedOnDone;

    when(() => mockSvc.initialize()).thenAnswer((_) async => true);
    when(() => mockSvc.startListening(
          onResult: any(named: 'onResult'),
          onDone: any(named: 'onDone'),
          onSoundLevel: any(named: 'onSoundLevel'),
        )).thenAnswer((inv) async {
      final onResult = inv.namedArguments[#onResult] as void Function(String, bool);
      capturedOnDone = inv.namedArguments[#onDone] as void Function();
      onResult('Logo design needed', true);
    });
    when(() => mockSvc.stop()).thenAnswer((_) async {});
    when(() => mockSvc.isListening).thenReturn(true);

    final mockUseCase = _FakeUseCase(kDraft);

    await tester.pumpWidget(_buildPage(service: mockSvc, useCase: mockUseCase));

    // Start recording
    await tester.tap(find.byKey(const Key('record_button')));
    await tester.pump();

    // Simulate recording done
    capturedOnDone?.call();
    await tester.pumpAndSettle();

    // Should now be in qualified state — find confirm button
    final confirmButton = find.byKey(const Key('confirm_button'));
    expect(confirmButton, findsOneWidget);

    // Tap confirm
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    // Verify use case was called (POST dispatched)
    expect(mockUseCase.called, isTrue);
    expect(mockUseCase.capturedText, 'Logo design needed');
  });

  testWidgets('cancel -> use case not called', (tester) async {
    final mockUseCase = _FakeUseCase(null);

    await tester.pumpWidget(_buildPage(service: mockSvc, useCase: mockUseCase));

    await tester.tap(find.byKey(const Key('cancel_button')));
    await tester.pumpAndSettle();

    expect(mockUseCase.called, isFalse);
  });

  testWidgets('score badge renders Hot/Warm/Cold correctly', (tester) async {
    const kDraft = VoiceLeadDraft(
      transcribedText: 'test',
      qualificationScore: 0.9,
      recommendation: 'hot',
      suggestedDealTitle: 'Deal',
    );
    void Function()? capturedOnDone;

    when(() => mockSvc.initialize()).thenAnswer((_) async => true);
    when(() => mockSvc.startListening(
          onResult: any(named: 'onResult'),
          onDone: any(named: 'onDone'),
          onSoundLevel: any(named: 'onSoundLevel'),
        )).thenAnswer((inv) async {
      final onResult = inv.namedArguments[#onResult] as void Function(String, bool);
      capturedOnDone = inv.namedArguments[#onDone] as void Function();
      onResult('test', true);
    });
    when(() => mockSvc.stop()).thenAnswer((_) async {});
    when(() => mockSvc.isListening).thenReturn(true);

    final mockUseCase = _FakeUseCase(kDraft);

    await tester.pumpWidget(_buildPage(service: mockSvc, useCase: mockUseCase));
    await tester.tap(find.byKey(const Key('record_button')));
    await tester.pump();

    capturedOnDone?.call();
    await tester.pumpAndSettle();

    // Score badge should show 'Hot'
    expect(find.byKey(const Key('score_badge_hot')), findsOneWidget);
    expect(find.text('Hot'), findsOneWidget);
  });
}
