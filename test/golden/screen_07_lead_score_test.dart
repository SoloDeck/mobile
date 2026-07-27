import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/voice_lead/domain/entities/voice_lead_draft.dart';
import 'package:solodesk_mobile/modules/voice_lead/presentation/pages/lead_score_page.dart';
import 'package:solodesk_mobile/modules/voice_lead/presentation/providers/voice_lead_provider.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/accent_card.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/mono_text.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';
import 'package:solodesk_mobile/ui/solo_nav_bar.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

import '../flutter_test_config.dart';

/// Bơm đúng kết quả chấm điểm mà bản phác thảo MÀN 07 vẽ ("78/100", "Lead
/// nóng 🔥") qua `voiceLeadProvider` — điểm số và nhận định trong màn thật lấy
/// từ đây, không còn là hằng số `_Demo`.
const _draft = VoiceLeadDraft(
  transcribedText: 'Khách hỏi chụp 40 sản phẩm cho dịp lễ, ngân sách rõ ràng',
  qualificationScore: 0.78,
  recommendation: 'hot',
  suggestedDealTitle: 'Chụp sản phẩm — 40 mẫu',
  suggestedClientName: 'Khách lẻ',
);

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [voiceLeadProvider.overrideWithValue(_draft)],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LeadScorePage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MÀN 07 — cấu trúc theo figcaption', () {
    testWidgets('điểm số đi kèm lý do bằng lời: điểm, nhận định, và AI ngay '
        'bên dưới', (tester) async {
      await _pump(tester);

      final scoreTop = tester.getTopLeft(find.text('78')).dy;
      final verdictTop = tester.getTopLeft(find.text('Lead nóng 🔥')).dy;
      final aiCardTop = tester.getTopLeft(find.byType(AccentCard)).dy;

      expect(scoreTop, lessThan(verdictTop));
      expect(verdictTop, lessThan(aiCardTop));
      expect(
        find.text(
          'Khách nêu rõ số lượng (40 sản phẩm), có ngân sách cụ thể và '
          'deadline gắn với dịp lễ — ba tín hiệu cho thấy đã có kế hoạch chi '
          'tiêu. Không thấy dấu hiệu ép giá. Điểm trừ duy nhất: chưa nói rõ '
          'phong cách ảnh và ai duyệt cuối.',
        ),
        findsOneWidget,
      );
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

    testWidgets('hai điểm còn thiếu là câu hỏi bấm được, không phải chữ tĩnh', (
      tester,
    ) async {
      await _pump(tester);

      for (final question in [
        'Ảnh dùng cho sàn TMĐT hay in ấn?',
        'Có cần thuê mẫu và bối cảnh không?',
      ]) {
        expect(
          find.ancestor(
            of: find.text(question),
            matching: find.byType(InkWell),
          ),
          findsOneWidget,
          reason: 'câu hỏi "$question" phải bấm được',
        );
      }
    });

    testWidgets('khoảng giá gợi ý neo vào lịch sử deal của người dùng', (
      tester,
    ) async {
      await _pump(tester);

      final priceTop = tester.getTopLeft(find.byType(SlipCard)).dy;
      final noteTop = tester
          .getTopLeft(find.text('Dựa trên 6 deal chụp sản phẩm bạn đã chốt'))
          .dy;
      expect(priceTop, lessThan(noteTop));
    });

    testWidgets('nút "Soạn báo giá" là hành động chính, nằm ở phần dưới màn', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('Soạn báo giá'), findsOneWidget);
      expect(find.text('Để sau'), findsOneWidget);

      final buttonTop = tester
          .getTopLeft(find.widgetWithText(FilledButton, 'Soạn báo giá'))
          .dy;
      final scoreTop = tester.getTopLeft(find.text('78')).dy;
      expect(scoreTop, lessThan(buttonTop));
    });

    testWidgets('hai nút ở dải giá có nối hành động', (tester) async {
      await _pump(tester);
      final soan = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Soạn báo giá'),
      );
      final deSau = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Để sau'),
      );
      expect(soan.onPressed, isNotNull);
      expect(deSau.onPressed, isNotNull);
    });
  });

  group('MÀN 07 — nối dữ liệu thật qua voiceLeadProvider', () {
    testWidgets('điểm số và tỉ lệ vòng tròn tính từ qualificationScore', (
      tester,
    ) async {
      await _pump(tester);
      // 0.78 * 100 = 78, đúng bản phác thảo — nhưng giờ tính từ draft thật.
      expect(find.text('78'), findsOneWidget);
    });

    testWidgets('nhận định "ấm" khi recommendation là warm, không phải hot', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            voiceLeadProvider.overrideWithValue(
              _draft.copyWith(recommendation: 'warm'),
            ),
          ],
          child: const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: LeadScorePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lead ấm'), findsOneWidget);
      expect(find.text('Lead nóng 🔥'), findsNothing);
    });

    // Nhánh thứ ba của `_verdictFor` — trước đây được phủ gián tiếp bởi
    // `_ScoreBadge` ở màn ghi âm cũ; màn đó không còn huy hiệu điểm nên chỗ
    // kiểm chuyển hẳn về đây.
    testWidgets('nhận định "nguội" khi recommendation là cold', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            voiceLeadProvider.overrideWithValue(
              _draft.copyWith(recommendation: 'cold'),
            ),
          ],
          child: const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: LeadScorePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lead nguội'), findsOneWidget);
      expect(find.text('Lead nóng 🔥'), findsNothing);
      expect(find.text('Lead ấm'), findsNothing);
    });

    testWidgets('chưa có draft nào thì hiện trạng thái rỗng, không vỡ layout', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: LeadScorePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('78'), findsNothing);
      expect(find.textContaining('Chưa có kết quả chấm điểm'), findsOneWidget);
    });
  });

  group('MÀN 07 — quy ước màu', () {
    testWidgets('AI nhận định dùng tone tím, không phải tone tiền', (
      tester,
    ) async {
      await _pump(tester);

      final accentCard = tester.widget<AccentCard>(find.byType(AccentCard));
      expect(accentCard.tone, Tone.ai);

      final chip = tester.widget<StatusChip>(find.byType(StatusChip));
      expect(chip.tone, Tone.ai);
    });

    testWidgets('chỉ một tấm phiếu răng cưa, và nó là khoảng giá — tiền', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.byType(SlipCard), findsOneWidget);
    });

    testWidgets('khoảng giá là ước tính nên dùng MonoText, không phải Money', (
      tester,
    ) async {
      await _pump(tester);

      final slip = tester.widget<SlipCard>(find.byType(SlipCard));
      expect(
        find.descendant(
          of: find.byWidget(slip),
          matching: find.byType(MonoText),
        ),
        findsWidgets,
      );
      expect(find.text('14 – 19 triệu ₫'), findsOneWidget);
    });
  });

  group('MÀN 07 — chuỗi hiển thị chép từ bản phác thảo', () {
    testWidgets('nguyên văn tiếng Việt, không diễn giải lại', (tester) async {
      await _pump(tester);

      for (final text in [
        'Kết quả chấm điểm',
        '78',
        // "trên 100" là một `SectionLabel` — tự in hoa, đúng cách `.lbl` hoạt
        // động ở bản phác thảo, nên chuỗi hiển thị trong cây widget là hoa.
        'TRÊN 100',
        'Lead nóng 🔥',
        'Nên phản hồi trong 24 giờ tới',
        'AI nhận định',
        // Hai nhãn mục dưới đây cũng đi qua `SectionLabel`/`SectionHeader`,
        // tự in hoa đúng cách `.lbl`/`.sec .lbl` hoạt động ở bản phác thảo.
        'CẦN HỎI LẠI TRƯỚC KHI BÁO GIÁ',
        'Ảnh dùng cho sàn TMĐT hay in ấn?',
        'Có cần thuê mẫu và bối cảnh không?',
        'KHOẢNG GIÁ GỢI Ý CHO HẠNG MỤC NÀY',
        '14 – 19 triệu ₫',
        'Dựa trên 6 deal chụp sản phẩm bạn đã chốt',
        'Soạn báo giá',
        'Để sau',
      ]) {
        expect(find.text(text), findsWidgets, reason: 'thiếu chuỗi "$text"');
      }
    });
  });

  group('MÀN 07 — quy tắc không được vi phạm', () {
    testWidgets('nền màn là màu giấy, không phải trắng', (tester) async {
      await _pump(tester);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        AppColors.paper,
      );
    });

    testWidgets('không có SoloNavBar — đây là màn con, không phải mục tab', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.byType(SoloNavBar), findsNothing);
    });

    testWidgets('không có thành phần kéo thả nào', (tester) async {
      await _pump(tester);
      expect(find.byType(Draggable<Object>), findsNothing);
      expect(find.byType(ReorderableListView), findsNothing);
    });

    testWidgets('không có khung máy mockup — không .sbar, không .homebar', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.text('9:41'), findsNothing);
    });
  });

  testWidgets('ảnh vàng — màn 07 kết quả chấm điểm lead', (tester) async {
    await _pump(tester);
    await expectLater(
      find.byType(LeadScorePage),
      matchesGoldenFile('goldens/screen_07_lead_score.png'),
    );
  }, skip: !soloFontsLoaded);
}
