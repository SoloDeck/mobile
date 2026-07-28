import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/core/time/app_clock.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deals_repository.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/repository/deals_repository_impl.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal_content.dart';
import 'package:solodesk_mobile/modules/proposals/domain/repositories/proposals_repository.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_query.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_status.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/repository/proposals_repository_impl.dart';
import 'package:solodesk_mobile/modules/proposals/presentation/pages/proposal_review_page.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/templates/domain/entities/template.dart';
import 'package:solodesk_mobile/modules/templates/domain/repositories/templates_repository.dart';
import 'package:solodesk_mobile/modules/templates/domain/value_objects/template_category.dart';
import 'package:solodesk_mobile/modules/templates/infrastructure/repository/templates_repository_impl.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/money.dart';
import 'package:solodesk_mobile/ui/notice_card.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';
import 'package:solodesk_mobile/ui/stamp_badge.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

import '../flutter_test_config.dart';
import '../support/fake_settings_repository.dart';

/// Golden test này chỉ mở MÀN 08 ở chế độ xem — không có bài nào bấm "Duyệt
/// và gửi khách" (nút bị khoá vì còn 2 chỗ trống) hay chuyển trạng thái, nên
/// chỉ `getProposal` cần triển khai thật; các phương thức ghi khác của
/// `ProposalsRepository` không cần.
class _FakeProposalsRepository implements ProposalsRepository {
  const _FakeProposalsRepository(this.proposal);

  final Proposal proposal;

  @override
  Future<Proposal> getProposal(String id) async => proposal;

  @override
  Future<Proposal> sendProposal(String id) => throw UnimplementedError();

  @override
  Future<ProposalListPage> listProposals({
    ProposalListFilter filter = const ProposalListFilter(),
    int page = 1,
    int pageSize = 20,
  }) => throw UnimplementedError();

  @override
  Future<Proposal> createProposal({
    required String dealId,
    required ProposalContent content,
  }) => throw UnimplementedError();

  @override
  Future<Proposal> updateProposalContent({
    required String id,
    required String dealId,
    required ProposalContent content,
  }) => throw UnimplementedError();

  @override
  Future<Proposal> transitionStatus({
    required String id,
    required ProposalStatus target,
  }) => throw UnimplementedError();

  @override
  Future<Proposal> generateFromDeal(String dealId) =>
      throw UnimplementedError();

  @override
  Future<Proposal> regenerateContent(String id) => throw UnimplementedError();

  @override
  Future<List<int>> downloadPdf(String id) => throw UnimplementedError();

  @override
  Future<void> deleteProposal(String id) => throw UnimplementedError();
}

/// Chỉ `getDeal` được gọi — `proposalReviewProvider` cần deal của báo giá để
/// lấy tên khách hàng và tổng tiền dự phòng; các hành động chuyển giai đoạn
/// pipeline không thuộc phạm vi màn này.
class _FakeDealsRepository implements DealsRepository {
  const _FakeDealsRepository(this.deal);

  final Deal deal;

  @override
  Future<Deal> getDeal(String id) async => deal;

  @override
  Future<List<Deal>> listDeals({DealStage? stage}) =>
      throw UnimplementedError();

  @override
  Future<Deal> createDeal({
    required String clientId,
    required String title,
    DealSource? source,
    double? estimatedValue,
    String? currency,
    String? notes,
  }) => throw UnimplementedError();

  @override
  Future<Deal> transitionStage({
    required String id,
    required DealStage targetStage,
    String? note,
  }) => throw UnimplementedError();
}

/// Chỉ `listTemplates` được gọi — `proposalReviewProvider` lọc mẫu mặc định/
/// hệ thống từ danh sách trả về, không đọc/ghi mẫu đơn lẻ nào ở màn này.
class _FakeTemplatesRepository implements TemplatesRepository {
  const _FakeTemplatesRepository(this.templates);

  final List<Template> templates;

  @override
  Future<List<Template>> listTemplates({TemplateCategory? category}) async =>
      templates;

  @override
  Future<Template?> getTemplate(String id) => throw UnimplementedError();

  @override
  Future<Template> copyTemplate(String sourceId) => throw UnimplementedError();

  @override
  Future<void> setDefaultTemplate(String id) => throw UnimplementedError();

  @override
  Future<void> deleteTemplate(String id) => throw UnimplementedError();
}

/// Đúng 2 chỗ trống: `deliverables` (rỗng) và `revisionRounds` (`null`).
/// `total` không tính là gap vì `deal.estimatedValue` (25.000.000) lấp được
/// nó ở tầng `proposalReviewProvider` — xem `resolveProposalGaps`.
final proposal = Proposal(
  id: 'p-2026-0042',
  dealId: 'deal-1',
  ownerUserId: 'u-1',
  versionNumber: 1,
  status: ProposalStatus.draft,
  aiGenerated: true,
  createdAt: DateTime(2026, 7, 1),
  content: ProposalContent(
    projectOverview:
        'Thiết kế bộ nhận diện thương hiệu cho cửa hàng thời trang.',
    scopeOfWork: const ['Logo', 'Brand guideline'],
    deliverables: const [],
    timeline: '01/07 → 31/07',
    pricing: '25.000.000 ₫ trọn gói',
    paymentTerms: 'Cọc 50%, duyệt nháp 30%, bàn giao 20%',
    assumptions: 'Khách cung cấp đủ nội dung và phản hồi đúng hạn.',
    revisionRounds: null,
    validUntil: DateTime(2026, 8, 8),
    total: null,
  ),
);

/// `estimatedValue` (25.000.000) làm tổng dự phòng vì `actualValue` chưa có —
/// đúng thứ tự ưu tiên `content.total ?? deal.actualValue ?? deal.estimatedValue`
/// của `proposalReviewProvider`.
final deal = Deal(
  id: 'deal-1',
  ownerUserId: 'u-1',
  clientId: 'c-1',
  title: 'Thiết kế bộ nhận diện — Minh An',
  stage: DealStage.proposalSent,
  createdAt: DateTime(2026, 6, 1),
  clientName: 'Cty TNHH Minh An',
  estimatedValue: 25000000,
  currency: 'VND',
);

final template = Template(
  id: 'sys-proposal-standard',
  name: 'Báo giá tiêu chuẩn',
  category: TemplateCategory.proposal,
  body: 'Báo giá tiêu chuẩn cho {{client_name}}.',
  isSystem: true,
  isDefault: false,
  createdAt: DateTime(2026, 1, 1),
);

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        proposalsRepositoryProvider.overrideWithValue(
          _FakeProposalsRepository(proposal),
        ),
        dealsRepositoryProvider.overrideWithValue(_FakeDealsRepository(deal)),
        templatesRepositoryProvider.overrideWithValue(
          _FakeTemplatesRepository([template]),
        ),
        appClockProvider.overrideWithValue(() => DateTime(2026, 7, 25)),
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ProposalReviewPage(proposalId: 'p-2026-0042'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MÀN 08 — cấu trúc theo figcaption', () {
    testWidgets('con dấu Bản nháp nghiêng nằm trong thanh tiêu đề', (
      tester,
    ) async {
      await _pump(tester);

      final stamp = tester.widget<StampBadge>(find.byType(StampBadge));
      expect(stamp.text, 'Bản nháp');
      expect(stamp.tone, Tone.ai);
    });

    testWidgets('cảnh báo còn ô trống đứng trên cùng thân màn', (tester) async {
      await _pump(tester);

      final notice = tester.widget<NoticeCard>(find.byType(NoticeCard));
      expect(notice.tone, Tone.warn);
      expect(find.text('Điền ngay'), findsOneWidget);

      // Cảnh báo phải nằm trên tấm thẻ xem trước, đúng thứ tự bản phác thảo.
      final noticeTop = tester.getTopLeft(find.byType(NoticeCard)).dy;
      final cardTop = tester.getTopLeft(find.byType(Card).first).dy;
      expect(noticeTop, lessThan(cardTop));
    });

    testWidgets('nút Duyệt và gửi khách bị khoá vì còn 2 chỗ trống', (
      tester,
    ) async {
      await _pump(tester);

      final sendButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(sendButton.onPressed, isNull);

      final editButton = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      expect(editButton.onPressed, isNotNull);
    });

    testWidgets('dải lịch thanh toán chia đúng ba đợt cộng đủ 100%', (
      tester,
    ) async {
      await _pump(tester);

      final weightedFlex = tester
          .widgetList<Expanded>(find.byType(Expanded))
          .map((e) => e.flex)
          .where((flex) => flex > 1)
          .toList();

      expect(weightedFlex, [50, 30, 20]);
      expect(weightedFlex.reduce((a, b) => a + b), 100);
    });

    testWidgets('ghi rõ mẫu AI và thời gian soạn', (tester) async {
      await _pump(tester);

      expect(find.text('AI soạn'), findsOneWidget);
      expect(find.text('Mẫu: Báo giá tiêu chuẩn'), findsOneWidget);
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
  });

  group('MÀN 08 — quy ước màu', () {
    testWidgets('cảnh báo còn ô trống dùng tone hổ phách, không phải hồng', (
      tester,
    ) async {
      await _pump(tester);

      final notice = tester.widget<NoticeCard>(find.byType(NoticeCard));
      expect(notice.tone, Tone.warn);
    });

    testWidgets('tổng cộng của báo giá dùng tone tiền như bản phác thảo', (
      tester,
    ) async {
      await _pump(tester);

      final money = tester.widget<Money>(find.byType(Money));
      expect(money.tone, Tone.money);
    });

    testWidgets('ba đoạn lịch thanh toán cùng một sắc hồng, khác độ trong', (
      tester,
    ) async {
      await _pump(tester);

      final expectedColors = [
        0.9,
        0.62,
        0.35,
      ].map((alpha) => AppColors.momo.withValues(alpha: alpha)).toList();

      // `.where` lọc theo `color.a > 0` để loại bỏ các `DecoratedBox` trong
      // suốt mà framework tự chèn (ripple, overlay của nút…) — chỉ giữ đúng
      // ba đoạn tô màu momo của dải lịch thanh toán.
      final actualColors = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((box) => box.decoration)
          .whereType<BoxDecoration>()
          .map((decoration) => decoration.color)
          .where((color) => color != null && color.a > 0 && color.a < 1.0)
          .toList();

      expect(actualColors, expectedColors);
    });

    testWidgets(
      'không có tấm phiếu răng cưa nào — đây không phải tiền phải đòi',
      (tester) async {
        await _pump(tester);
        // MÀN 08 dùng Card, không phải SlipCard, cho bản xem trước — quyết định
        // đã chốt trong doc comment của PerforatedDivider.
        expect(find.byType(SlipCard), findsNothing);
      },
    );
  });

  group('MÀN 08 — chuỗi hiển thị chép từ bản phác thảo', () {
    testWidgets('nguyên văn tiếng Việt, không diễn giải lại', (tester) async {
      await _pump(tester);

      for (final text in [
        'Báo giá BG-2026-0042',
        // `StampBadge` tự in hoa (`text.toUpperCase()`), nên chuỗi hiển thị
        // thật trên màn là "BẢN NHÁP", không phải "Bản nháp".
        'BẢN NHÁP',
        'Còn 2 chỗ trống cần điền trước khi gửi',
        'Điền ngay',
        'XEM TRƯỚC BẢN GỬI KHÁCH',
        'ĐỀ XUẤT DỊCH VỤ',
        'BG-2026-0042 · hiệu lực đến 08/08/2026',
        'Khách hàng',
        'Cty TNHH Minh An',
        'Phạm vi',
        'Logo · Brand guideline',
        'Thời gian',
        '01/07 → 31/07',
        'Số vòng sửa',
        'chưa điền',
        'Tổng cộng',
        'LỊCH THANH TOÁN',
        'Đủ 100%',
        'Cọc 50%',
        'Duyệt nháp 30%',
        'Bàn giao 20%',
        'AI soạn',
        'Mẫu: Báo giá tiêu chuẩn',
        'Sửa',
        'Duyệt và gửi khách',
        'Đánh dấu đã gửi · kèm link xem bản PDF',
      ]) {
        expect(find.text(text), findsWidgets, reason: 'thiếu chuỗi "$text"');
      }
    });

    testWidgets('số tiền định dạng theo cách người Việt viết', (tester) async {
      await _pump(tester);
      expect(find.text('25.000.000 ₫'), findsOneWidget);
    });
  });

  group('MÀN 08 — quy tắc không được vi phạm', () {
    testWidgets('nền màn là màu giấy, không phải trắng', (tester) async {
      await _pump(tester);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        AppColors.paper,
      );
    });

    testWidgets('không có thành phần kéo thả nào', (tester) async {
      await _pump(tester);
      expect(find.byType(Draggable<Object>), findsNothing);
      expect(find.byType(ReorderableListView), findsNothing);
    });

    testWidgets(
      'nút chính là StatusChip loại chip, không phải chip "đang chọn"',
      (tester) async {
        await _pump(tester);
        final chips = tester.widgetList<StatusChip>(find.byType(StatusChip));
        expect(chips.every((chip) => chip.tone != Tone.solid), isTrue);
      },
    );
  });

  testWidgets('ảnh vàng — màn 08 duyệt và gửi báo giá', (tester) async {
    await _pump(tester);
    await expectLater(
      find.byType(ProposalReviewPage),
      matchesGoldenFile('goldens/screen_08_quote_review.png'),
    );
  }, skip: !soloFontsLoaded);
}
