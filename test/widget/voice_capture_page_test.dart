import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/audio/voice_capture_service.dart';
import 'package:solodesk_mobile/modules/voice_lead/application/usecases/capture_and_qualify_lead_usecase.dart';
import 'package:solodesk_mobile/modules/voice_lead/domain/entities/voice_lead_draft.dart';
import 'package:solodesk_mobile/modules/voice_lead/presentation/pages/voice_capture_page_new.dart';
import 'package:solodesk_mobile/modules/voice_lead/presentation/providers/voice_lead_provider.dart';

class _MockVoiceCaptureService extends Mock implements VoiceCaptureService {}

/// Use case giả — ghi lại tham số để test khẳng định đúng transcript được gửi
/// đi, và ném được lỗi để kiểm nhánh hỏng.
class _FakeUseCase extends Fake implements CaptureAndQualifyLeadUseCase {
  _FakeUseCase(this.returnValue);

  final VoiceLeadDraft? returnValue;
  String? capturedText;
  String? capturedClientId;
  int callCount = 0;

  bool get called => callCount > 0;

  @override
  Future<VoiceLeadDraft> call({
    required String transcribedText,
    required String clientId,
    String? serviceCategory,
  }) async {
    callCount++;
    capturedText = transcribedText;
    capturedClientId = clientId;
    if (returnValue != null) return returnValue!;
    throw Exception('no return value');
  }
}

const _draft = VoiceLeadDraft(
  transcribedText: 'Tôi cần thiết kế logo',
  qualificationScore: 0.82,
  recommendation: 'hot',
  suggestedDealTitle: 'Thiết kế logo',
  suggestedClientName: 'Trần Nam',
  createdDealId: 'd1',
);

/// Micro giả điều khiển được: test tự đóng vai engine phát chữ, mức âm và tín
/// hiệu kết thúc.
class _Mic {
  late final _MockVoiceCaptureService mock;
  void Function(String words, bool isFinal)? onResult;
  Future<void> Function()? onDone;
  void Function(double level)? onSoundLevel;
  bool cancelled = false;

  _Mic({bool ready = true}) {
    mock = _MockVoiceCaptureService();
    when(mock.initialize).thenAnswer((_) async => ready);
    when(
      () => mock.startListening(
        onResult: any(named: 'onResult'),
        onDone: any(named: 'onDone'),
        onSoundLevel: any(named: 'onSoundLevel'),
      ),
    ).thenAnswer((invocation) async {
      onResult =
          invocation.namedArguments[#onResult] as void Function(String, bool)?;
      onDone = invocation.namedArguments[#onDone] as Future<void> Function()?;
      onSoundLevel =
          invocation.namedArguments[#onSoundLevel] as void Function(double)?;
    });
    // `SpeechService.stop()` phát `onDone` sau khi dừng engine (xem
    // test/unit/core/services/speech_service_test.dart). Mock phải bắt chước
    // đúng điều đó, nếu không test sẽ xanh trên một hành vi không có thật.
    when(mock.stop).thenAnswer((_) async => onDone?.call());
    when(mock.cancel).thenAnswer((_) async {
      cancelled = true;
    });
  }
}

/// Router bắt đầu ở màn gốc rồi **push** MÀN 06, đúng như app thật: lối vào duy
/// nhất là nút ＋ giữa thanh tab. Dựng thẳng MÀN 06 làm `initialLocation` thì
/// nút quay lại không có gì để pop và `context.pop()` ném.
GoRouter _router() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (ctx, state) => const Scaffold(body: Text('màn gốc')),
    ),
    GoRoute(
      path: '/voice-capture',
      builder: (ctx, state) => const VoiceCapturePage(),
      routes: [
        // Màn đích **phải** đọc `voiceLeadProvider` như MÀN 07 thật. Dựng một
        // Scaffold trơ ở đây sẽ che mất chuyện provider là autoDispose: MÀN 06
        // rời cây, không còn ai nghe, state bị xoá — và test vẫn xanh trong khi
        // app thật mất kết quả.
        GoRoute(
          path: 'score',
          builder: (ctx, state) => Consumer(
            builder: (ctx, ref, _) {
              final draft = ref.watch(voiceLeadProvider);
              return Scaffold(
                body: Text(draft?.suggestedDealTitle ?? 'chưa có kết quả'),
              );
            },
          ),
        ),
      ],
    ),
  ],
);

/// Dựng app rồi mở MÀN 06 như người dùng thật, và chờ `initState` chạy xong
/// `_start()`.
Future<void> _openCapture(
  WidgetTester tester, {
  required VoiceCaptureService service,
  CaptureAndQualifyLeadUseCase? useCase,
  required GoRouter router,
  Widget Function(Widget child)? wrap,
}) async {
  final app = MaterialApp.router(routerConfig: router);
  await tester.pumpWidget(
    wrap != null
        ? wrap(app)
        : ProviderScope(
            overrides: [
              voiceCaptureServiceProvider.overrideWithValue(service),
              if (useCase != null)
                captureAndQualifyLeadUseCaseProvider.overrideWithValue(useCase),
            ],
            child: app,
          ),
  );
  await tester.pumpAndSettle();

  router.push('/voice-capture');
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mở màn là bắt đầu ghi ngay, không chờ bấm mic', (tester) async {
    final mic = _Mic();
    final router = _router();
    addTearDown(router.dispose);

    await _openCapture(tester, service: mic.mock, router: router);

    verify(mic.mock.initialize).called(1);
    verify(
      () => mic.mock.startListening(
        onResult: any(named: 'onResult'),
        onDone: any(named: 'onDone'),
        onSoundLevel: any(named: 'onSoundLevel'),
      ),
    ).called(1);
    expect(find.text('Đang nghe'), findsOneWidget);
  });

  testWidgets('chữ engine nghe được hiện trong khối chép lời', (tester) async {
    final mic = _Mic();
    final router = _router();
    addTearDown(router.dispose);

    await _openCapture(tester, service: mic.mock, router: router);

    mic.onResult!('Tôi cần thiết kế logo', false);
    await tester.pump();

    expect(
      find.textContaining('Tôi cần thiết kế logo', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('bấm Dừng và tạo lead thì chấm điểm rồi sang màn kết quả', (
    tester,
  ) async {
    final mic = _Mic();
    final useCase = _FakeUseCase(_draft);
    final router = _router();
    addTearDown(router.dispose);

    await _openCapture(
      tester,
      service: mic.mock,
      useCase: useCase,
      router: router,
    );

    mic.onResult!('Tôi cần thiết kế logo', true);
    await tester.pump();

    await tester.tap(find.byKey(const Key('voice_primary_cta')));
    await tester.pumpAndSettle();

    verify(mic.mock.stop).called(1);
    expect(useCase.called, isTrue);
    expect(useCase.capturedText, 'Tôi cần thiết kế logo');
    expect(useCase.capturedClientId, '');
    expect(router.state.matchedLocation, '/voice-capture/score');
  });

  // Đây là mắt xích khiến MÀN 07 từng luôn ra màn rỗng: bản cũ gọi thẳng use
  // case nên `voiceLeadProvider` không bao giờ giữ kết quả.
  testWidgets('kết quả chấm điểm nằm lại trong voiceLeadProvider', (
    tester,
  ) async {
    final mic = _Mic();
    final useCase = _FakeUseCase(_draft);
    final router = _router();
    addTearDown(router.dispose);

    final container = ProviderContainer(
      overrides: [
        voiceCaptureServiceProvider.overrideWithValue(mic.mock),
        captureAndQualifyLeadUseCaseProvider.overrideWithValue(useCase),
      ],
    );
    addTearDown(container.dispose);

    await _openCapture(
      tester,
      service: mic.mock,
      router: router,
      wrap: (app) =>
          UncontrolledProviderScope(container: container, child: app),
    );

    expect(container.read(voiceLeadProvider), isNull);

    mic.onResult!('Tôi cần thiết kế logo', true);
    await tester.pump();
    await tester.tap(find.byKey(const Key('voice_primary_cta')));
    await tester.pumpAndSettle();

    // Đọc qua màn đích chứ không qua container: đó mới là câu hỏi thật — MÀN 07
    // có thấy kết quả không.
    expect(find.text('Thiết kế logo'), findsOneWidget);
    expect(find.text('chưa có kết quả'), findsNothing);
  });

  testWidgets('rời màn giữa lúc ghi thì huỷ micro', (tester) async {
    final mic = _Mic();
    final router = _router();
    addTearDown(router.dispose);

    await _openCapture(tester, service: mic.mock, router: router);

    await tester.tap(find.bySemanticsLabel('Quay lại'));
    await tester.pumpAndSettle();

    expect(mic.cancelled, isTrue);
  });

  testWidgets('không xin được quyền micro thì báo lỗi và cho thử lại', (
    tester,
  ) async {
    final mic = _Mic(ready: false);
    final router = _router();
    addTearDown(router.dispose);

    await _openCapture(tester, service: mic.mock, router: router);

    expect(
      find.text('Không thể khởi tạo microphone. Kiểm tra quyền truy cập.'),
      findsOneWidget,
    );
    expect(find.text('Thử lại'), findsOneWidget);
    expect(find.text('Đang nghe'), findsNothing);
  });

  testWidgets('dừng khi chưa nghe được gì thì báo lỗi, không gọi AI', (
    tester,
  ) async {
    final mic = _Mic();
    final useCase = _FakeUseCase(_draft);
    final router = _router();
    addTearDown(router.dispose);

    await _openCapture(
      tester,
      service: mic.mock,
      useCase: useCase,
      router: router,
    );

    // Không phát onResult lần nào — transcript rỗng.
    await tester.tap(find.byKey(const Key('voice_primary_cta')));
    await tester.pumpAndSettle();

    expect(useCase.called, isFalse);
    expect(find.text('Chưa nghe được gì. Thử nói lại.'), findsOneWidget);
    expect(router.state.matchedLocation, '/voice-capture');
  });

  testWidgets('AI hỏng thì ở lại màn và báo lỗi', (tester) async {
    final mic = _Mic();
    final useCase = _FakeUseCase(null); // ném Exception
    final router = _router();
    addTearDown(router.dispose);

    await _openCapture(
      tester,
      service: mic.mock,
      useCase: useCase,
      router: router,
    );

    mic.onResult!('Tôi cần thiết kế logo', true);
    await tester.pump();
    await tester.tap(find.byKey(const Key('voice_primary_cta')));
    await tester.pumpAndSettle();

    expect(find.text('Có lỗi xảy ra. Vui lòng thử lại.'), findsOneWidget);
    expect(router.state.matchedLocation, '/voice-capture');
  });

  // Engine có thể phát `done` muộn sau `stop()`; chấm điểm hai lần là tạo hai
  // deal, vì use case tạo deal ngay trong bước qualify.
  testWidgets('onDone chạy lần hai không chấm điểm lại', (tester) async {
    final mic = _Mic();
    final useCase = _FakeUseCase(_draft);
    final router = _router();
    addTearDown(router.dispose);

    await _openCapture(
      tester,
      service: mic.mock,
      useCase: useCase,
      router: router,
    );

    mic.onResult!('Tôi cần thiết kế logo', true);
    await tester.pump();
    await mic.onDone!();
    await tester.pumpAndSettle();

    expect(useCase.callCount, 1);

    await mic.onDone!();
    await tester.pumpAndSettle();

    // Vẫn đúng một lần chấm điểm sau hai lần onDone.
    expect(useCase.callCount, 1);
  });
}
