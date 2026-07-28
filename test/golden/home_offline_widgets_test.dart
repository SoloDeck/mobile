import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/home/presentation/widgets/dashed_card.dart';
import 'package:solodesk_mobile/modules/home/presentation/widgets/offline_banner.dart';
import 'package:solodesk_mobile/modules/home/presentation/widgets/pending_chip.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

import '../flutter_test_config.dart';

Widget _host(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light(),
  home: Material(
    color: AppColors.paper,
    child: Padding(padding: const EdgeInsets.all(AppGap.xl), child: child),
  ),
);

void main() {
  group('OfflineBanner — trích từ MÀN 15', () {
    testWidgets('hiện đúng chuỗi báo mất mạng và nhãn chờ gửi truyền vào', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const OfflineBanner(
            message: 'Đang ngoại tuyến · dữ liệu lúc 08:14',
            pendingLabel: '3 chờ gửi',
          ),
        ),
      );

      expect(find.text('Đang ngoại tuyến · dữ liệu lúc 08:14'), findsOneWidget);
      expect(find.text('3 chờ gửi'), findsOneWidget);
    });

    testWidgets(
      'icon mất kết nối có nhãn tiếng Việt cho người dùng khuyết tật',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const OfflineBanner(
              message: 'Đang ngoại tuyến · dữ liệu lúc 08:14',
              pendingLabel: '3 chờ gửi',
            ),
          ),
        );

        final icon = tester.widget<SoloIcon>(find.byType(SoloIcon));
        expect(icon.icon, SoloIcons.wifiOff);
        expect(icon.label, 'Mất kết nối mạng');
      },
    );

    testWidgets('nền là màu mực, không phải màu giấy hay trắng', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const OfflineBanner(
            message: 'Đang ngoại tuyến · dữ liệu lúc 08:14',
            pendingLabel: '3 chờ gửi',
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('Đang ngoại tuyến · dữ liệu lúc 08:14'),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(container.color, AppColors.ink);
    });

    testWidgets('chip chờ gửi nằm bên trong dải báo, không phải cạnh nó', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const OfflineBanner(
            message: 'Đang ngoại tuyến · dữ liệu lúc 08:14',
            pendingLabel: '3 chờ gửi',
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(OfflineBanner),
          matching: find.byType(PendingChip),
        ),
        findsOneWidget,
      );
    });
  });

  group('PendingChip — chip nền tối dùng lại được', () {
    testWidgets('chữ không xuống dòng', (tester) async {
      await tester.pumpWidget(
        _host(
          const ColoredBox(
            color: AppColors.ink,
            child: PendingChip('3 chờ gửi'),
          ),
        ),
      );
      expect(tester.widget<Text>(find.text('3 chờ gửi')).softWrap, isFalse);
    });

    testWidgets('nền trắng trong suốt, không phải một tone của StatusChip', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const ColoredBox(
            color: AppColors.ink,
            child: PendingChip('3 chờ gửi'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('3 chờ gửi'),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, AppColors.surface.withValues(alpha: 0.16));
    });
  });

  group('DashedCard — khung viền đứt nét dùng lại được', () {
    testWidgets('bọc đúng nội dung con truyền vào', (tester) async {
      await tester.pumpWidget(
        _host(const DashedCard(child: Text('Chưa gửi được tin nhắn nào'))),
      );
      expect(find.text('Chưa gửi được tin nhắn nào'), findsOneWidget);
    });

    testWidgets('vẽ bằng DashedRRectPainter, không mượn viền Card thường', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const DashedCard(child: Text('Chưa gửi được tin nhắn nào'))),
      );

      final painted = tester.widget<CustomPaint>(find.byType(CustomPaint));
      expect(painted.painter, isA<DashedRRectPainter>());
      expect(find.byType(Card), findsNothing);
    });
  });

  testWidgets(
    'ảnh vàng — dải báo ngoại tuyến, chip chờ gửi, khung viền đứt nét',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 420));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _host(
          Column(
            key: const Key('golden-root'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              OfflineBanner(
                message: 'Đang ngoại tuyến · dữ liệu lúc 08:14',
                pendingLabel: '3 chờ gửi',
              ),
              SizedBox(height: AppGap.card),
              DashedCard(child: Text('Chưa gửi được tin nhắn nào')),
            ],
          ),
        ),
      );

      await expectLater(
        find.byKey(const Key('golden-root')),
        matchesGoldenFile('goldens/home_offline_widgets.png'),
      );
    },
    skip: !soloFontsLoaded,
  );
}
