import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/modules/voice_lead/domain/entities/voice_lead_draft.dart';
import 'package:solodesk_mobile/modules/voice_lead/presentation/providers/voice_lead_provider.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/accent_card.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/mono_text.dart';
import 'package:solodesk_mobile/ui/perforated_divider.dart';
import 'package:solodesk_mobile/ui/section_header.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// MÀN 07 — Lead Qualifier — kết quả.
///
/// Đối chiếu: khối `<!-- 07 Kết quả chấm điểm -->` (`<figure class="unit">`,
/// dòng 635–680) trong `design/solodesk-mobile-ui.html`, gồm cả `<figcaption>`.
///
/// Bốn quyết định trong figcaption, đừng đảo lại khi sửa:
/// - Điểm số **đi kèm lý do bằng lời**: vòng điểm 78/100 luôn đứng cạnh nhận
///   định "Lead nóng" và thẻ AI giải thích vì sao — không có con số trần trụi.
/// - AI nêu luôn **điểm còn thiếu** và biến nó thành câu hỏi bấm được:
///   [_QuestionRow] là hàng có thể chạm, không phải chữ tĩnh.
///   AI vẫn không tự gửi gì — chạm vào câu hỏi chỉ mở ra chỗ để người dùng trả
///   lời, đúng quy tắc 5.
/// - Khoảng giá gợi ý neo vào **lịch sử deal đã chốt của chính người dùng**,
///   không phải giá thị trường chung — dòng "Dựa trên 6 deal..." đứng ngay dưới
///   khoảng giá để nói rõ nguồn.
/// - Nút "Soạn báo giá" nối sang tầng AI thứ hai (soạn báo giá ở MÀN 08) chứ
///   không gửi thẳng — bản nháp đó vẫn phải qua người dùng duyệt trước khi gửi
///   khách, đúng quy tắc 5.
///
/// Dữ liệu điểm số/nhận định lấy thật từ [voiceLeadProvider] (kết quả của
/// `CaptureAndQualifyLeadUseCase`, MÀN 06 → 07). Câu hỏi gợi ý và khoảng giá
/// chưa có nguồn dữ liệu thật — xem `_MockData` cuối file.
class LeadScorePage extends ConsumerWidget {
  const LeadScorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(voiceLeadProvider);
    final appearance = ref.watch(appearanceControllerProvider);

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          child: Column(
            children: [
              // Bỏ `const` ở riêng `SoloAppBar` vì `onTap` của nút quay lại là
              // closure; các khối còn lại của màn vẫn giữ `const`.
              SoloAppBar(
                title: 'Kết quả chấm điểm',
                titleSize: SoloAppBar.xs,
                leading: IconButtonBox(
                  SoloIcons.back,
                  label: 'Quay lại',
                  ghost: true,
                  onTap: () => context.pop(),
                ),
              ),
              Expanded(
                child: draft == null
                    ? const _EmptyState()
                    // SingleChildScrollView chứ không phải ListView: màn này
                    // chỉ có vài khối, dựng hết một lượt để test tìm được nội
                    // dung dưới màn.
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          AppGap.screen,
                          0,
                          AppGap.screen,
                          AppGap.screen,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ScoreCard(draft: draft),
                            const SizedBox(height: AppGap.betweenCards),
                            const _AiAssessmentCard(),
                            const SectionHeader(
                              'Cần hỏi lại trước khi báo giá',
                            ),
                            const _QuestionRow(_MockData.question1),
                            const SizedBox(height: AppGap.betweenCards),
                            const _QuestionRow(_MockData.question2),
                            const SizedBox(height: AppGap.card),
                            const _PriceRangeSlip(),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Trạng thái khi vào thẳng màn này mà [voiceLeadProvider] chưa có
/// [VoiceLeadDraft] nào — ví dụ mở lại app hoặc điều hướng trực tiếp mà bỏ qua
/// bước ghi âm ở MÀN 06. Bản phác thảo không vẽ trạng thái này vì luôn giả
/// định đã có kết quả chấm điểm; thêm ở đây chỉ để màn không vỡ khi chưa có
/// dữ liệu, không phải một khối trong bản phác thảo.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppGap.screen),
        child: Text(
          'Chưa có kết quả chấm điểm nào. Quay lại ghi âm khách hàng để AI '
          'chấm điểm trước.',
          style: AppText.sub,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Vòng điểm chấm chất lượng lead, kèm lý do bằng lời ngay bên dưới.
///
/// Nền chuyển sắc và viền hồng nhạt là chủ ý của bản phác thảo cho riêng thẻ
/// này — không phải `SlipCard` vì điểm số không phải tiền (quy tắc 3), nên
/// dựng bằng `DecoratedBox` thay vì bọc `Card` trong `Container`.
///
/// Điểm số và nhận định lấy thật từ [VoiceLeadDraft.qualificationScore] và
/// [VoiceLeadDraft.recommendation] — xem [_verdictFor].
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.draft});

  final VoiceLeadDraft draft;

  @override
  Widget build(BuildContext context) {
    final score = (draft.qualificationScore * 100).round();
    final ratio = draft.qualificationScore.clamp(0.0, 1.0);
    final verdict = _verdictFor(draft.recommendation);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.momoSoft, AppColors.surface],
        ),
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.momoLine),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppGap.xxl,
          horizontal: AppGap.slip,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ScoreRing(score: score, ratio: ratio),
            const SizedBox(height: AppGap.lg),
            Text(
              verdict.headline,
              style: AppText.display,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppGap.xxs),
            Text(
              verdict.subline,
              style: AppText.sub,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Suy ra nhận định bằng lời từ [VoiceLeadDraft.recommendation].
///
/// BE chỉ trả về mã `'hot' | 'warm' | 'cold'` (xem
/// `CaptureAndQualifyLeadUseCase`) — không có câu chữ tiếng Việt sẵn. Bản phác
/// thảo (MÀN 07) chỉ minh hoạ đúng nhánh `'hot'` ("Lead nóng 🔥"); hai nhánh
/// còn lại soạn theo cùng giọng văn tại đây vì dữ liệu thật (`recommendation`)
/// có thể trả về `'warm'`/`'cold'` mà bản phác thảo không vẽ riêng.
({String headline, String subline}) _verdictFor(String recommendation) {
  return switch (recommendation) {
    'hot' => (
      headline: 'Lead nóng 🔥',
      subline: 'Nên phản hồi trong 24 giờ tới',
    ),
    'warm' => (headline: 'Lead ấm', subline: 'Nên phản hồi trong vài ngày tới'),
    _ => (headline: 'Lead nguội', subline: 'Có thể phản hồi khi rảnh'),
  };
}

/// Vòng tròn điểm số, `conic-gradient` trong bản phác thảo.
///
/// Flutter không có `conic-gradient` sẵn: tái tạo bằng hai hình quạt vẽ tay
/// (`CustomPainter`, `useCenter: true`) rồi phủ một vòng tròn trắng nhỏ hơn ở
/// giữa để chỉ còn lại vành khuyên — đúng cách CSS `conic-gradient` +
/// `border-radius:50%` lồng nhau tạo ra hiệu ứng ở bản phác thảo.
class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score, required this.ratio});

  final int score;
  final double ratio;

  /// Đường kính vòng ngoài, đúng bản phác thảo. Không có token `AppGap` hay
  /// `AppRadius` nào khớp một hình vẽ tay chỉ dùng đúng một lần này.
  static const double _outerSize = 112;

  /// Đường kính vòng tròn trắng ở giữa — hiệu số với [_outerSize] chính là bề
  /// dày vành khuyên.
  static const double _innerSize = 88;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _outerSize,
      height: _outerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(_outerSize),
            painter: _ScoreRingPainter(
              ratio: ratio,
              color: AppColors.momo,
              // Bản phác thảo dùng `#F3E5EE` cho rãnh chưa tô — không có token
              // riêng cho màu này, `momoSoft` là màu hồng nhạt gần nhất.
              trackColor: AppColors.momoSoft,
            ),
          ),
          Container(
            width: _innerSize,
            height: _innerSize,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bản phác thảo đặt số này ở 27px — giữa `AppText.numLg`
                  // (21) và `AppText.numHero` (32). Chọn `numHero`, gần hơn
                  // và giữ đúng vai trò "con số chính của cả màn".
                  MonoText(
                    '$score',
                    style: AppText.numHero,
                    color: AppColors.momo,
                  ),
                  const SectionLabel('trên 100'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  const _ScoreRingPainter({
    required this.ratio,
    required this.color,
    required this.trackColor,
  });

  final double ratio;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const start = -math.pi / 2;

    canvas.drawArc(rect, start, 2 * math.pi, true, Paint()..color = trackColor);
    canvas.drawArc(
      rect,
      start,
      2 * math.pi * ratio.clamp(0.0, 1.0),
      true,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) =>
      old.ratio != ratio || old.color != color || old.trackColor != trackColor;
}

/// Nhận định của AI giải thích vì sao lead được chấm điểm như vậy — lý do
/// bằng lời đi kèm con số ở [_ScoreCard] bên trên.
class _AiAssessmentCard extends StatelessWidget {
  const _AiAssessmentCard();

  @override
  Widget build(BuildContext context) {
    return const AccentCard(
      tone: Tone.ai,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusChip('AI nhận định', tone: Tone.ai, icon: SoloIcons.ai),
          SizedBox(height: AppGap.betweenCards),
          Text(_MockData.aiNote, style: AppText.sub),
        ],
      ),
    );
  }
}

/// Một điểm còn thiếu, đóng vai câu hỏi bấm được — biến nhận định của AI
/// thành việc làm thay vì để người dùng tự đoán phải hỏi gì.
class _QuestionRow extends StatelessWidget {
  const _QuestionRow(this.question);

  final String question;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // CHƯA NỐI HÀNH ĐỘNG — cố ý để trống: chưa có nơi lưu câu trả lời.
        // `VoiceLeadDraft` không có trường nào cho câu hỏi/câu trả lời, nên
        // hàng vẫn phải bấm được (đúng figcaption) nhưng chưa mở được gì.
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppGap.lg,
            horizontal: AppGap.card,
          ),
          child: Row(
            children: [
              Expanded(child: Text(question, style: AppText.body)),
              const SizedBox(width: AppGap.row),
              const SoloIcon(
                SoloIcons.chevron,
                label: null,
                size: SoloIcon.sm,
                color: AppColors.ink3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Khoảng giá gợi ý, neo vào lịch sử deal đã chốt của chính người dùng — dòng
/// chú thích ngay dưới con số nói rõ nguồn, không phải giá thị trường chung.
///
/// `SlipCard` đúng chỗ: nội dung là tiền (quy tắc 3). Khoảng giá dùng
/// `MonoText` chứ không phải `Money` vì đây là một ước tính, không phải một
/// khoản tiền chính xác.
class _PriceRangeSlip extends StatelessWidget {
  const _PriceRangeSlip();

  @override
  Widget build(BuildContext context) {
    return SlipCard(
      notch: 66,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SectionLabel(_MockData.priceRangeLabel),
          const SizedBox(height: AppGap.sm),
          const MonoText(_MockData.priceRange, style: AppText.numLg),
          const SizedBox(height: AppGap.xxs),
          const Text(_MockData.priceRangeNote, style: AppText.mut),
          const PerforatedDivider(),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  // Sang MÀN 08 để AI soạn bản nháp báo giá — vẫn phải qua
                  // người dùng duyệt trước khi gửi khách, đúng quy tắc 5.
                  onPressed: () => context.push(RouteNames.proposalReview),
                  style: AppTheme.filled(tone: Tone.ai, small: true),
                  icon: const SoloIcon(
                    SoloIcons.file,
                    label: null,
                    size: SoloIcon.xs,
                    color: AppColors.surface,
                  ),
                  label: const Text('Soạn báo giá'),
                ),
              ),
              const SizedBox(width: AppGap.betweenButtons),
              OutlinedButton(
                onPressed: () => context.pop(),
                style: AppTheme.outlined(small: true),
                child: const Text('Để sau'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Chuỗi hiển thị chưa có nguồn dữ liệu thật. `VoiceLeadDraft` (xem
/// `domain/entities/voice_lead_draft.dart`) chỉ mang `transcribedText`,
/// `qualificationScore`, `recommendation`, `suggestedDealTitle`,
/// `suggestedClientName`, `createdDealId` — không có trường nào cho nhận định
/// bằng lời chi tiết, câu hỏi gợi ý, hay khoảng giá. Ghép API thật (nếu BE bổ
/// sung các trường này) chỉ cần thay đúng chỗ tương ứng.
///
/// Là class chứ không phải record vì Dart không cho đọc field của record
/// trong biểu thức `const`, mà widget của màn này phải const được. Tên viết
/// hoa theo lint `camel_case_types` của repo.
abstract final class _MockData {
  /// CHƯA NỐI API — `VoiceLeadDraft` không có trường nhận định giải thích
  /// bằng lời; BE chỉ trả `qualificationScore` và `recommendation`.
  static const String aiNote =
      'Khách nêu rõ số lượng (40 sản phẩm), có ngân sách cụ thể và deadline '
      'gắn với dịp lễ — ba tín hiệu cho thấy đã có kế hoạch chi tiêu. Không '
      'thấy dấu hiệu ép giá. Điểm trừ duy nhất: chưa nói rõ phong cách ảnh và '
      'ai duyệt cuối.';

  /// CHƯA NỐI API — `VoiceLeadDraft` không có danh sách câu hỏi còn thiếu.
  static const String question1 = 'Ảnh dùng cho sàn TMĐT hay in ấn?';

  /// CHƯA NỐI API — `VoiceLeadDraft` không có danh sách câu hỏi còn thiếu.
  static const String question2 = 'Có cần thuê mẫu và bối cảnh không?';

  /// CHƯA NỐI API — `VoiceLeadDraft` không có khoảng giá gợi ý.
  static const String priceRangeLabel = 'Khoảng giá gợi ý cho hạng mục này';

  /// CHƯA NỐI API — `VoiceLeadDraft` không có khoảng giá gợi ý.
  static const String priceRange = '14 – 19 triệu ₫';

  /// CHƯA NỐI API — `VoiceLeadDraft` không có lịch sử deal đã chốt để tính
  /// khoảng giá này từ.
  static const String priceRangeNote =
      'Dựa trên 6 deal chụp sản phẩm bạn đã chốt';
}
