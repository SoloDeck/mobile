import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/audio/voice_capture_service.dart';
import 'package:solodesk_mobile/modules/voice_lead/domain/entities/voice_lead_draft.dart';
import 'package:solodesk_mobile/modules/voice_lead/presentation/pages/voice_capture_page_new.dart';
import 'package:solodesk_mobile/modules/voice_lead/presentation/providers/voice_lead_provider.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

import '../flutter_test_config.dart';

class _MockVoiceCaptureService extends Mock implements VoiceCaptureService {}

/// Micro giả đứng yên: `initialize()` thành công nhưng `startListening` không
/// phát chữ, không phát mức âm, không bao giờ gọi `onDone`.
///
/// Màn ghi âm bắt đầu thu ngay khi mở (xem doc comment của `VoiceCapturePage`),
/// nên **mọi** test dựng màn này phải thay `voiceCaptureServiceProvider` — để
/// nguyên thì `initState` chạm plugin thật và ném `MissingPluginException`.
/// Đứng yên cũng là điều kiện để khung hình khớp ảnh vàng: transcript rỗng nên
/// khối chép lời rơi về câu mẫu, và `_levels` giữ nguyên bộ số bản phác thảo.
_MockVoiceCaptureService _stubbedService() {
  final svc = _MockVoiceCaptureService();
  when(svc.initialize).thenAnswer((_) async => true);
  when(
    () => svc.startListening(
      onResult: any(named: 'onResult'),
      onDone: any(named: 'onDone'),
      onSoundLevel: any(named: 'onSoundLevel'),
    ),
  ).thenAnswer((_) async {});
  when(svc.stop).thenAnswer((_) async {});
  when(svc.cancel).thenAnswer((_) async {});
  return svc;
}

Future<_MockVoiceCaptureService> _pump(
  WidgetTester tester, {
  VoiceLeadDraft? draft,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final svc = _stubbedService();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        voiceLeadProvider.overrideWithValue(draft),
        voiceCaptureServiceProvider.overrideWithValue(svc),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const VoiceCapturePage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return svc;
}

/// Màu chip trên nền tối tô bằng `tone.accent.withValues(alpha: 0.22)` — dò
/// lại đúng công thức trong `_FieldChip` của màn hình, vì `_FieldChip` là
/// private nên test không import được kiểu, chỉ dò qua `Container` công khai
/// bọc quanh chữ.
Color _chipFillBehind(WidgetTester tester, String text) {
  final container = tester.widget<Container>(
    find.ancestor(of: find.text(text), matching: find.byType(Container)).first,
  );
  return (container.decoration! as BoxDecoration).color!;
}

void main() {
  group('MÀN 06 — cấu trúc theo figcaption', () {
    testWidgets('nền màn đảo sang tối để báo hiệu đang ghi', (tester) async {
      await _pump(tester);

      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        AppColors.ink,
      );
      expect(tester.widget<SoloAppBar>(find.byType(SoloAppBar)).onDark, isTrue);
    });

    testWidgets('nút quay lại có nối hành động', (tester) async {
      await _pump(tester);
      final back = tester.widget<IconButtonBox>(
        find.byWidgetPredicate(
          (w) => w is IconButtonBox && w.label == 'Quay lại',
        ),
      );
      expect(back.onTap, isNotNull);
    });

    testWidgets('các trường bóc tách hiện dưới khối đang chép lời', (
      tester,
    ) async {
      await _pump(tester);

      final transcribingTop = tester.getTopLeft(find.byType(SectionLabel)).dy;
      final fieldTop = tester.getTopLeft(find.text('Khách: Trần Nam')).dy;
      expect(transcribingTop, lessThan(fieldTop));

      // Câu đang nói dở vẫn còn dấu "…" — bóc tách đang chạy chứ chưa xong.
      expect(
        find.textContaining(
          'Anh Nam bên Studio Cỏ cần chụp bốn mươi sản phẩm',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.textContaining('…', findRichText: true), findsOneWidget);
    });

    testWidgets('nút mic 72pt nằm giữa hai lối phụ gõ tay và chụp ảnh', (
      tester,
    ) async {
      await _pump(tester);

      final micIcon = tester.widget<SoloIcon>(
        find.byWidgetPredicate((w) => w is SoloIcon && w.icon == SoloIcons.mic),
      );
      expect(micIcon.size, 30);

      final fileDx = tester
          .getCenter(
            find.byWidgetPredicate(
              (w) => w is SoloIcon && w.icon == SoloIcons.file,
            ),
          )
          .dx;
      final micDx = tester
          .getCenter(
            find.byWidgetPredicate(
              (w) => w is SoloIcon && w.icon == SoloIcons.mic,
            ),
          )
          .dx;
      final imageDx = tester
          .getCenter(
            find.byWidgetPredicate(
              (w) => w is SoloIcon && w.icon == SoloIcons.image,
            ),
          )
          .dx;
      expect(fileDx, lessThan(micDx));
      expect(micDx, lessThan(imageDx));
    });

    testWidgets('không vẽ banner mất mạng — bản phác thảo không có ở màn này', (
      tester,
    ) async {
      await _pump(tester);

      expect(
        find.byWidgetPredicate(
          (w) => w is SoloIcon && w.icon == SoloIcons.wifiOff,
        ),
        findsNothing,
      );
    });
  });

  group('MÀN 06 — quy ước màu', () {
    testWidgets('tiền hồng, khách/việc tím, hạn hổ phách trên nền tối', (
      tester,
    ) async {
      await _pump(tester);

      expect(
        _chipFillBehind(tester, '~15.000.000 ₫'),
        AppColors.momo.withValues(alpha: 0.22),
      );
      expect(
        _chipFillBehind(tester, 'Khách: Trần Nam'),
        AppColors.ai.withValues(alpha: 0.22),
      );
      expect(
        _chipFillBehind(tester, 'Việc: chụp sản phẩm'),
        AppColors.ai.withValues(alpha: 0.22),
      );
      expect(
        _chipFillBehind(tester, 'Hạn: 27/08'),
        AppColors.amber.withValues(alpha: 0.22),
      );
    });

    testWidgets('nút mic dùng màu AI, không phải màu tiền', (tester) async {
      await _pump(tester);

      final micIconWidget = tester.widget<SoloIcon>(
        find.byWidgetPredicate((w) => w is SoloIcon && w.icon == SoloIcons.mic),
      );
      expect(micIconWidget.color, AppColors.surface);

      final micBox = tester.widget<Container>(
        find
            .ancestor(
              of: find.byWidgetPredicate(
                (w) => w is SoloIcon && w.icon == SoloIcons.mic,
              ),
              matching: find.byType(Container),
            )
            .last,
      );
      expect((micBox.decoration! as BoxDecoration).color, AppColors.ai);
    });
  });

  group('MÀN 06 — chuỗi hiển thị chép từ bản phác thảo', () {
    testWidgets('nguyên văn tiếng Việt, không diễn giải lại', (tester) async {
      await _pump(tester);

      for (final text in [
        'Ghi nhanh',
        'Đang nghe',
        'Cứ nói tự nhiên như đang kể lại cho đồng nghiệp. Tên khách, việc '
            'cần làm, ngân sách, deadline — thiếu gì bổ sung sau cũng được.',
        'ĐANG CHÉP LỜI',
        'Khách: Trần Nam',
        'Việc: chụp sản phẩm',
        '~15.000.000 ₫',
        'Hạn: 27/08',
        'Dừng và tạo lead',
      ]) {
        expect(find.text(text), findsWidgets, reason: 'thiếu chuỗi "$text"');
      }
    });
  });

  group('MÀN 06 — nối voiceLeadProvider thật', () {
    testWidgets(
      'chip Khách và Việc lấy từ VoiceLeadDraft khi provider đã có draft',
      (tester) async {
        await _pump(
          tester,
          draft: const VoiceLeadDraft(
            transcribedText: 'Anh Nam bên Studio Cỏ cần chụp bốn mươi sản phẩm',
            qualificationScore: 0.8,
            recommendation: 'hot',
            suggestedDealTitle: 'Chụp sản phẩm Studio Cỏ',
            suggestedClientName: 'Nguyễn Văn A',
          ),
        );

        expect(find.text('Khách: Nguyễn Văn A'), findsOneWidget);
        expect(find.text('Việc: Chụp sản phẩm Studio Cỏ'), findsOneWidget);
        // Không còn hằng số mặc định nữa vì đã có draft thật.
        expect(find.text('Khách: Trần Nam'), findsNothing);
        expect(find.text('Việc: chụp sản phẩm'), findsNothing);
      },
    );

    testWidgets(
      'chip Khách và Việc dùng dữ liệu mặc định khi provider chưa có draft',
      (tester) async {
        await _pump(tester);

        expect(find.text('Khách: Trần Nam'), findsOneWidget);
        expect(find.text('Việc: chụp sản phẩm'), findsOneWidget);
      },
    );
  });

  group('MÀN 06 — quy tắc không được vi phạm', () {
    testWidgets('nền màn tối, không phải màu giấy', (tester) async {
      await _pump(tester);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        isNot(AppColors.paper),
      );
    });

    testWidgets('không có thành phần kéo thả nào', (tester) async {
      await _pump(tester);
      expect(find.byType(Draggable<Object>), findsNothing);
      expect(find.byType(ReorderableListView), findsNothing);
    });
  });

  testWidgets('ảnh vàng — màn 06 ghi nhanh bằng giọng nói', (tester) async {
    await _pump(tester);
    await expectLater(
      find.byType(VoiceCapturePage),
      matchesGoldenFile('goldens/screen_06_voice_capture.png'),
    );
  }, skip: !soloFontsLoaded);
}
