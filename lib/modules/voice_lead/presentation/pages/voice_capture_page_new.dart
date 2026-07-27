import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/audio/voice_capture_service.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/modules/voice_lead/presentation/providers/voice_lead_provider.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

/// MÀN 06 — Ghi nhanh bằng giọng nói.
///
/// Đối chiếu: khối `<figure class="unit">` chứa `MÀN 06` (dòng 586-632 của
/// `design/solodesk-mobile-ui.html`), gồm cả `<figcaption>`.
///
/// Bốn quyết định trong figcaption, đừng đảo lại khi sửa:
/// - **Đảo sang nền tối** để báo hiệu app đang thu âm mà không cần đọc chữ:
///   `Scaffold` dùng `AppColors.ink` (đúng `#1A0B26` của bản phác thảo) thay vì
///   `AppColors.paper`, và `SoloAppBar` bật `onDark: true`. Đây là màu nền của
///   riêng màn này, không phải đổi `AppTheme` sang chế độ tối — xem doc comment
///   của `AppTheme.light`.
/// - **Các trường AI bóc tách hiện dần theo thời gian thực**: khối "đang chép
///   lời" vẽ câu đang nói dở với dấu `…` mờ hơn phần chữ đã chắc chắn, và dải
///   chip "Khách", "Việc", "~tiền", "Hạn" đứng ngay dưới đại diện cho các
///   trường bóc tách được trong lúc người dùng vẫn đang nói.
/// - **Nút mic to 72pt ở giữa vùng ngón cái, hai lối phụ hai bên**: `_MicButton`
///   nằm giữa `_SideIconButton` gõ tay (trái) và chụp ảnh brief (phải), đúng
///   thứ tự bản phác thảo.
/// - **Không mạng vẫn ghi âm được**: có chủ ý *không* vẽ banner mất mạng ở màn
///   này — bản phác thảo không có phần tử nào cho trạng thái đó ở MÀN 06, ghi
///   âm và hàng đợi đồng bộ chạy nền, không đổi giao diện lúc đang nói. Banner
///   mất mạng (`SoloIcons.wifiOff`) chỉ xuất hiện ở những màn bản phác thảo có
///   vẽ nó; thêm vào đây là bịa thêm chi tiết ngoài bản phác thảo.
///
/// ## Luồng ghi âm
///
/// Vào màn là **ghi ngay**, không có bước chờ bấm mic. Bản phác thảo chỉ vẽ
/// đúng một trạng thái — "đang nghe" — và lối vào duy nhất là nút ＋ giữa thanh
/// tab (`AppShell`), nên ý định người dùng đã rõ từ trước khi màn mở. Dựng thêm
/// một trạng thái chờ là bịa ra chuỗi tiếng Việt mà bản phác thảo không có.
///
/// Ba trạng thái, xem [_Phase]. Chuyển giữa chúng:
/// - mở màn → `_start()` xin quyền micro rồi `startListening` → `recording`
/// - bấm "Dừng và tạo lead" (hoặc nút mic) → `svc.stop()` → engine phát `onDone`
///   → `qualifying` → gọi AI → điều hướng sang MÀN 07
/// - im lặng quá `pauseFor` → engine tự phát `onDone`, đi đúng nhánh trên
///
/// Hai đường dừng phải cùng đi qua `onDone` chứ không nhánh nào tự chuyển trạng
/// thái, nếu không sẽ có hai lối vào `_onDone` và phải viết guard hai chỗ.
/// `SpeechService.stop()` đã được sửa để phát `onDone` sau khi dừng engine —
/// trước đó nó nuốt mất tín hiệu và màn kẹt vĩnh viễn ở `recording`.
///
/// ## Dữ liệu
///
/// Kết quả AI đi qua `voiceLeadProvider` (`VoiceLeadNotifier.qualify`) chứ
/// không gọi thẳng `captureAndQualifyLeadUseCaseProvider`: notifier giữ lại
/// `VoiceLeadDraft` để **MÀN 07 đọc được**. Gọi thẳng use case (như bản cũ đã
/// làm) khiến `voiceLeadProvider` luôn `null` và MÀN 07 luôn ra màn rỗng.
///
/// Chỉ hai chip "Khách" và "Việc" nối được vì đó là hai field duy nhất
/// `VoiceLeadDraft` trả về khớp bản phác thảo; xem `_MockData` cho phần còn
/// thiếu.
class VoiceCapturePage extends ConsumerStatefulWidget {
  const VoiceCapturePage({super.key});

  @override
  ConsumerState<VoiceCapturePage> createState() => _VoiceCapturePageState();
}

/// Ba trạng thái của phiên ghi. Ít hơn bản cũ (sáu) vì `idle` biến mất do ghi
/// ngay khi mở màn, còn `qualified`/`creating` thay bằng điều hướng sang MÀN 07
/// — không có màn hình nào đứng lại để hiện chúng.
enum _Phase { recording, qualifying, error }

class _VoiceCapturePageState extends ConsumerState<VoiceCapturePage> {
  _Phase _phase = _Phase.recording;
  String _transcript = '';
  String? _errorMessage;

  /// Chiều cao 15 vạch sóng. Khởi tạo đúng bộ số của bản phác thảo nên khung
  /// hình lúc chưa nghe thấy gì trùng khít ảnh vàng; mỗi mức âm mới đẩy một giá
  /// trị vào cuối và bỏ giá trị đầu.
  late final List<double> _levels = List.of(_MockData.waveHeights);

  /// Giữ sẵn service để `dispose()` huỷ được micro — không `ref.read` trong
  /// `dispose` vì lúc đó widget đã rời cây.
  late VoiceCaptureService _captureService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _captureService = ref.read(voiceCaptureServiceProvider);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _captureService.cancel();
    super.dispose();
  }

  /// Xin quyền micro rồi bắt đầu thu. `initialize()` trả `false` cho cả hai
  /// trường hợp "người dùng từ chối quyền" và "máy không có engine nhận dạng" —
  /// service không phân biệt được, nên thông điệp phải phủ cả hai.
  Future<void> _start() async {
    setState(() {
      _phase = _Phase.recording;
      _transcript = '';
      _errorMessage = null;
    });

    final svc = ref.read(voiceCaptureServiceProvider);
    final ready = await svc.initialize();
    if (!mounted) return;
    if (!ready) {
      setState(() {
        _phase = _Phase.error;
        _errorMessage =
            'Không thể khởi tạo microphone. Kiểm tra quyền truy cập.';
      });
      return;
    }

    await svc.startListening(
      onResult: (words, _) {
        if (!mounted) return;
        setState(() => _transcript = words);
      },
      onDone: _onDone,
      onSoundLevel: (level) {
        if (!mounted) return;
        setState(() {
          _levels
            ..removeAt(0)
            ..add(_MockData.minBar + level * _MockData.barRange);
        });
      },
    );
  }

  /// Dừng thu. Cố ý **không** tự đổi trạng thái: `onDone` là lối vào duy nhất
  /// của bước chấm điểm, dù người dùng bấm dừng hay engine tự hết giờ.
  Future<void> _stopAndQualify() => _captureService.stop();

  Future<void> _onDone() async {
    // Engine có thể phát `done` khi màn đã sang trạng thái khác (hoặc phát muộn
    // sau `stop()`); chấm điểm hai lần là tạo hai deal.
    if (_phase != _Phase.recording) return;

    final transcript = _transcript.trim();
    if (transcript.isEmpty) {
      setState(() {
        _phase = _Phase.error;
        _errorMessage = 'Chưa nghe được gì. Thử nói lại.';
      });
      return;
    }

    setState(() => _phase = _Phase.qualifying);

    try {
      await ref
          .read(voiceLeadProvider.notifier)
          .qualify(
            transcribedText: transcript,
            // clientId rỗng cho luồng ghi nhanh — deal được tạo như một lead
            // mới chưa gắn khách hàng nào. Đây là hợp đồng backend, không phải
            // chỗ thiếu sót của màn này.
            clientId: '',
          );
      if (!mounted) return;
      // pushReplacement: quay lại từ MÀN 07 phải về nơi đã mở màn ghi âm, chứ
      // không rơi lại vào một phiên ghi đã kết thúc.
      context.pushReplacement(RouteNames.leadScore);
    } on AIQualificationException catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.error;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.error;
        _errorMessage = 'Có lỗi xảy ra. Vui lòng thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appearance = ref.watch(appearanceControllerProvider);
    final draft = ref.watch(voiceLeadProvider);
    final clientName = draft?.suggestedClientName?.trim();
    final dealTitle = draft?.suggestedDealTitle.trim();
    final fieldClient = (clientName != null && clientName.isNotEmpty)
        ? 'Khách: $clientName'
        : _MockData.fieldClient;
    final fieldTask = (dealTitle != null && dealTitle.isNotEmpty)
        ? 'Việc: $dealTitle'
        : _MockData.fieldTask;

    final isRecording = _phase == _Phase.recording;
    final transcript = _transcript.trim();

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: Scaffold(
        // Màu nền riêng của màn này — không phải theme tối, xem doc comment lớp.
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Column(
            children: [
              SoloAppBar(
                title: _MockData.title,
                onDark: true,
                leading: IconButtonBox(
                  SoloIcons.back,
                  label: 'Quay lại',
                  ghost: true,
                  iconColor: AppColors.surface,
                  onTap: () => context.pop(),
                ),
                actions: [_ListeningChip(_statusLabel)],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppGap.screen,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _MockData.intro,
                        style: AppText.sub.copyWith(color: _DarkPalette.muted),
                      ),
                      const SizedBox(height: AppGap.xxxl),
                      _Waveform(heights: _levels),
                      const SizedBox(height: AppGap.xxl),
                      _TranscriptCard(
                        transcript: transcript.isEmpty ? null : transcript,
                        errorMessage: _errorMessage,
                        pending: isRecording,
                      ),
                      const SizedBox(height: AppGap.card),
                      Wrap(
                        spacing: AppGap.betweenChips,
                        runSpacing: AppGap.betweenChips,
                        children: [
                          _FieldChip(fieldClient, tone: Tone.ai),
                          _FieldChip(fieldTask, tone: Tone.ai),
                          const _FieldChip(
                            _MockData.fieldBudget,
                            tone: Tone.money,
                          ),
                          const _FieldChip(
                            _MockData.fieldDeadline,
                            tone: Tone.warn,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _BottomActions(
                label: _phase == _Phase.error ? _MockData.retry : _MockData.cta,
                busy: _phase == _Phase.qualifying,
                onPrimary: switch (_phase) {
                  _Phase.recording => _stopAndQualify,
                  _Phase.error => _start,
                  _Phase.qualifying => null,
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _statusLabel => switch (_phase) {
    _Phase.recording => _MockData.listening,
    _Phase.qualifying => _MockData.analysing,
    _Phase.error => _MockData.failed,
  };
}

/// Màu riêng cho khối nền tối của MÀN 06. Không có token chính thức cho một
/// màn đảo nền — `lib/theme` chỉ có một bảng màu sáng (xem `AppTheme.light`).
/// Suy ra bằng độ trong của các token đã có (`AppColors.surface`,
/// `AppColors.ai`) thay vì viết cứng `Color(0x…)` mới.
///
/// Nếu có màn thứ hai cũng đảo nền tối, nên nâng bảng này lên `lib/theme` như
/// một `AppColors` biến thể tối, thay vì chép lại private ở từng màn.
abstract final class _DarkPalette {
  /// Đoạn hướng dẫn mờ dưới tiêu đề — gần nhất với `#B9A9C7` của bản phác thảo.
  static final Color muted = AppColors.surface.withValues(alpha: 0.72);

  /// Chữ trong khối "đang chép lời" — gần nhất với `#F3ECF7`.
  static const Color transcript = AppColors.surface;

  /// Nền/viền của các mảng kính mờ (chip "Đang nghe", khối chép lời, hai nút
  /// phụ) — đúng độ trong `rgba(255,255,255,…)` của bản phác thảo.
  static final Color glassSoft = AppColors.surface.withValues(alpha: 0.1);
  static final Color glassSoftBorder = AppColors.surface.withValues(
    alpha: 0.18,
  );
  static final Color cardFill = AppColors.surface.withValues(alpha: 0.07);
  static final Color cardBorder = AppColors.surface.withValues(alpha: 0.14);
  static final Color chipFill = AppColors.surface.withValues(alpha: 0.12);
  static final Color chipBorder = AppColors.surface.withValues(alpha: 0.2);
}

/// Chip trạng thái "Đang nghe" ở góc phải thanh tiêu đề.
///
/// `StatusChip` cố ý không hỗ trợ biến thể nền tối này (xem doc comment của
/// nó) — nền/viền/chữ trong suốt trên nền tối là chuyện riêng của MÀN 06.
class _ListeningChip extends StatelessWidget {
  const _ListeningChip(this.label);

  /// Chữ trong chip đổi theo trạng thái phiên ghi — "Đang nghe" khi thu,
  /// "Đang phân tích" khi chờ AI, "Không ghi được" khi hỏng. Trước đây nó là
  /// nhãn cứng nên chip nói dối mọi lúc trừ lúc đang thu.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppGap.md,
        vertical: AppGap.chipVertical,
      ),
      decoration: BoxDecoration(
        color: _DarkPalette.chipFill,
        borderRadius: AppRadius.chipAll,
        border: Border.all(color: _DarkPalette.chipBorder),
      ),
      child: Text(
        label,
        style: AppText.chip.copyWith(color: _DarkPalette.transcript),
        softWrap: false,
      ),
    );
  }
}

/// Dạng sóng theo mức âm thật, thay cho hoạt ảnh `.wavebar` của bản phác thảo.
/// Chiều rộng vạch (5), khoảng cách (4) và chiều cao khung (78) chép đúng bản
/// phác thảo; không có token `AppGap`/`AppRadius` nào khớp một dải sóng âm nên
/// đặt hằng số riêng ngay trong widget, giống cách `SoloNavBar.height` làm.
///
/// Chiều cao là **dữ liệu truyền vào**, không phải `AnimationController`. Một
/// controller `repeat()` sẽ không bao giờ lắng, và mọi test của màn này đều
/// dùng `pumpAndSettle()` — nó sẽ treo vô hạn. `AnimatedContainer` thì tự lắng
/// khi hết mức âm mới nên vẫn an toàn.
class _Waveform extends StatelessWidget {
  const _Waveform({required this.heights});

  static const double _barWidth = 5;
  static const double _gap = 4;
  static const double _frameHeight = 78;
  static const Duration _settle = Duration(milliseconds: 120);

  final List<double> heights;

  @override
  Widget build(BuildContext context) {
    final bars = <Widget>[];
    for (var i = 0; i < heights.length; i++) {
      if (i > 0) bars.add(const SizedBox(width: _gap));
      bars.add(
        AnimatedContainer(
          duration: _settle,
          curve: Curves.easeOut,
          width: _barWidth,
          height: heights[i],
          decoration: BoxDecoration(
            color: AppColors.ai,
            borderRadius: AppRadius.pillAll,
          ),
        ),
      );
    }

    return Semantics(
      label: 'Dạng sóng của giọng nói đang ghi',
      excludeSemantics: true,
      child: SizedBox(
        height: _frameHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: bars,
        ),
      ),
    );
  }
}

/// Khối "đang chép lời" — câu đang nói dở, hiện dần theo thời gian thực.
///
/// [transcript] là chữ engine nghe được; `null` nghĩa là chưa nghe được gì và
/// khối rơi về câu mẫu của bản phác thảo, để màn lúc vừa mở vẫn đúng hình dáng
/// đã thiết kế thay vì là một ô trống. [pending] bật dấu `…` báo câu còn dở.
/// [errorMessage] thay toàn bộ nội dung khi phiên ghi hỏng — chỗ này là nơi
/// duy nhất trên màn đủ rộng để đọc một câu lỗi.
class _TranscriptCard extends StatelessWidget {
  const _TranscriptCard({
    required this.transcript,
    required this.pending,
    this.errorMessage,
  });

  final String? transcript;
  final bool pending;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final error = errorMessage;
    if (error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppGap.slip),
        decoration: BoxDecoration(
          color: _DarkPalette.cardFill,
          borderRadius: AppRadius.cardAll,
          border: Border.all(color: _DarkPalette.cardBorder),
        ),
        child: Text(
          error,
          key: const Key('voice_error_message'),
          style: AppText.body.copyWith(
            fontSize: 15,
            height: 1.6,
            color: _DarkPalette.transcript,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      // 15 khớp đúng `AppGap.slip`, tái dùng vì đúng số chứ không phải vì đây
      // là `SlipCard` — nội dung không phải tiền nên không được dùng SlipCard
      // (AGENTS.md quy tắc 3-4).
      padding: const EdgeInsets.all(AppGap.slip),
      decoration: BoxDecoration(
        color: _DarkPalette.cardFill,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: _DarkPalette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SectionLabel(_MockData.transcribing, color: AppColors.aiLine),
          const SizedBox(height: AppGap.md),
          Text.rich(
            key: const Key('voice_transcript'),
            TextSpan(
              children: [
                TextSpan(
                  text: transcript == null
                      ? _MockData.transcriptOpen
                      : '${_MockData.quoteOpen}$transcript',
                ),
                if (pending)
                  TextSpan(
                    text: _MockData.transcriptEllipsis,
                    style: TextStyle(
                      color: _DarkPalette.transcript.withValues(alpha: 0.45),
                    ),
                  ),
                const TextSpan(text: _MockData.transcriptClose),
              ],
            ),
            style: AppText.body.copyWith(
              fontSize: 15,
              height: 1.6,
              color: _DarkPalette.transcript,
            ),
          ),
        ],
      ),
    );
  }
}

/// Một trường AI bóc tách được, hiện dần cạnh nhau dưới khối chép lời —
/// "Khách", "Việc", ngân sách, hạn chót. Màu theo [tone]: tím cho nội dung mô
/// tả việc, hồng cho tiền, hổ phách cho hạn — đúng quy ước màu của app, chỉ
/// khác là tô trên nền tối bằng độ trong của chính màu tone đó thay vì
/// `tone.background`/`tone.border` (hai màu đó là cho nền giấy sáng).
class _FieldChip extends StatelessWidget {
  const _FieldChip(this.label, {required this.tone});

  final String label;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppGap.md,
        vertical: AppGap.chipVertical,
      ),
      decoration: BoxDecoration(
        color: tone.accent.withValues(alpha: 0.22),
        borderRadius: AppRadius.chipAll,
        border: Border.all(color: tone.accent.withValues(alpha: 0.5)),
      ),
      // `tone.border` là màu viền chip trên nền giấy sáng; ở đây mượn lại vì
      // nó đã là bản nhạt của [tone] nên đủ sáng để đọc được trên nền tối.
      child: Text(
        label,
        style: AppText.chip.copyWith(color: tone.border),
        softWrap: false,
      ),
    );
  }
}

/// Vùng hành động ở đáy: hai lối phụ hai bên nút mic to, rồi nút chính.
/// Nằm ở 1/3 dưới màn, đúng quy tắc bố cục — màn này không cuộn tới đây nên
/// không cần `BottomActionBar` (dải đó fade sang `AppColors.paper`, sai màu
/// nền cho một màn tối).
class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.label,
    required this.busy,
    required this.onPrimary,
  });

  final String label;

  /// Đang chờ AI: khoá cả nút chính lẫn nút mic để không mở hai phiên chấm
  /// điểm chồng nhau — mỗi lần chấm điểm tạo một deal.
  final bool busy;

  final Future<void> Function()? onPrimary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppGap.screen,
        0,
        AppGap.screen,
        AppGap.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _SideIconButton(SoloIcons.file, label: 'Gõ tay'),
              const SizedBox(width: AppGap.xxl),
              // Nút mic làm đúng việc nút chính làm: bản phác thảo vẽ nó ở giữa
              // vùng ngón cái nên đó là chỗ tay chạm tới trước.
              _MicButton(onTap: busy ? null : onPrimary),
              const SizedBox(width: AppGap.xxl),
              const _SideIconButton(SoloIcons.image, label: 'Chụp ảnh brief'),
            ],
          ),
          const SizedBox(height: AppGap.xl),
          FilledButton.icon(
            key: const Key('voice_primary_cta'),
            onPressed: busy ? null : onPrimary,
            style: ButtonStyle(
              backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
              foregroundColor: const WidgetStatePropertyAll(AppColors.ink),
              iconColor: const WidgetStatePropertyAll(AppColors.ink),
              elevation: const WidgetStatePropertyAll(0),
              shadowColor: const WidgetStatePropertyAll(Colors.transparent),
              textStyle: const WidgetStatePropertyAll(AppText.button),
              minimumSize: const WidgetStatePropertyAll(Size(0, 46)),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: AppGap.xl),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
            ),
            icon: const SoloIcon(
              SoloIcons.check,
              label: null,
              size: SoloIcon.sm,
              color: AppColors.ink,
            ),
            label: Text(label),
          ),
        ],
      ),
    );
  }
}

/// Lối phụ hai bên nút mic — `.iconbtn` tô kính mờ trên nền tối, không phải
/// biến thể có sẵn của `IconButtonBox` (nó chỉ đổi màu theo `Tone`, không có
/// tone nào là "kính mờ trên nền tối").
class _SideIconButton extends StatelessWidget {
  const _SideIconButton(this.icon, {required this.label});

  static const double _size = 38;
  static const double _tapTarget = 44;

  final SoloIconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        // CHƯA NỐI — "Gõ tay" cần một màn nhập lead thủ công và "Chụp ảnh
        // brief" cần luồng tải ảnh; repo chưa có cái nào. Giữ nút để đúng bố
        // cục bản phác thảo, đừng nối bừa sang màn tạo khách hàng: đó là việc
        // khác.
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: _tapTarget,
          height: _tapTarget,
          child: Center(
            child: Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                color: _DarkPalette.glassSoft,
                borderRadius: BorderRadius.circular(AppRadius.iconButton),
                border: Border.all(color: _DarkPalette.glassSoftBorder),
              ),
              child: Center(
                child: SoloIcon(icon, label: null, color: AppColors.surface),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nút mic 72pt, đặt chính giữa vùng ngón cái. 72 và bo góc 26 là hình dáng
/// riêng của nút này, không khớp cỡ nào trong `AppRadius`/`Avatar` — nếu có
/// màn thứ hai cần đúng hình này thì nên thêm token, còn hiện tại đặt hằng số
/// tại chỗ, giống cách `SoloNavBar` tự định nghĩa `_fabSize`.
class _MicButton extends StatelessWidget {
  const _MicButton({required this.onTap});

  static const double _size = 72;
  static const double _radius = 26;
  static const double _ringSpread = 8;

  /// `null` khi đang chờ AI — nút vẫn vẽ nguyên hình dáng nhưng không nhận
  /// chạm, vì chấm điểm hai lần là tạo hai deal.
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      // Nhãn nói hành động sẽ xảy ra khi chạm, không nói trạng thái hiện tại —
      // trình đọc màn hình đọc nút là để biết bấm vào thì được gì.
      label: onTap == null ? 'Đang xử lý' : 'Dừng ghi và tạo lead',
      child: GestureDetector(
        key: const Key('voice_mic_button'),
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            color: AppColors.ai,
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: [
              BoxShadow(
                color: AppColors.ai.withValues(alpha: 0.22),
                spreadRadius: _ringSpread,
              ),
            ],
          ),
          child: const Center(
            child: SoloIcon(
              SoloIcons.mic,
              label: null,
              size: 30,
              color: AppColors.surface,
            ),
          ),
        ),
      ),
    );
  }
}

/// Dữ liệu tĩnh dùng khi màn chưa có `VoiceLeadDraft` từ `voiceLeadProvider`
/// (trước khi ghi âm/qualify), cộng với các trường bản phác thảo có nhưng
/// `VoiceLeadDraft` chưa trả về.
abstract final class _MockData {
  static const String title = 'Ghi nhanh';
  static const String listening = 'Đang nghe';

  /// Hai nhãn chip dưới đây không có trong bản phác thảo — nó chỉ vẽ trạng thái
  /// đang nghe. Viết theo cùng giọng: động từ chủ động, câu ngắn.
  static const String analysing = 'Đang phân tích';
  static const String failed = 'Không ghi được';

  /// Nhãn nút chính khi phiên ghi hỏng, thay cho [cta].
  static const String retry = 'Thử lại';

  static const String intro =
      'Cứ nói tự nhiên như đang kể lại cho đồng nghiệp. Tên khách, việc cần '
      'làm, ngân sách, deadline — thiếu gì bổ sung sau cũng được.';
  static const String transcribing = 'đang chép lời';
  static const String transcriptOpen =
      '“Anh Nam bên Studio Cỏ cần chụp bốn mươi sản phẩm, ngân sách khoảng '
      'mười lăm triệu, cần xong trước rằm tháng tám';
  static const String transcriptEllipsis = '…';
  static const String transcriptClose = '”';

  /// Dấu mở ngoặc kép đứng riêng, để ghép trước chữ engine nghe được.
  /// [transcriptOpen] đã gồm sẵn dấu này nên chỉ dùng khi thay bằng chữ thật.
  static const String quoteOpen = '“';

  /// Biên chiều cao một vạch sóng, suy từ [waveHeights]: thấp nhất 20, cao nhất
  /// 66. Mức âm 0–1 từ `VoiceCaptureService` ánh xạ vào đúng dải này để sóng
  /// thật không vượt khỏi hình dáng bản phác thảo.
  static const double minBar = 20;
  static const double barRange = 46;

  /// CHƯA NỐI API — dùng làm khách hàng mặc định khi `voiceLeadProvider`
  /// còn `null` (chưa ghi âm xong / chưa qualify). Khi có `VoiceLeadDraft`,
  /// `VoiceCapturePage` thay bằng `draft.suggestedClientName` thật.
  static const String fieldClient = 'Khách: Trần Nam';

  /// CHƯA NỐI API — dùng làm việc cần làm mặc định khi `voiceLeadProvider`
  /// còn `null`. Khi có `VoiceLeadDraft`, thay bằng `draft.suggestedDealTitle`
  /// thật.
  static const String fieldTask = 'Việc: chụp sản phẩm';

  /// CHƯA NỐI API — `VoiceLeadDraft` (domain/entities/voice_lead_draft.dart)
  /// chưa có field ngân sách; backend AI qualify hiện chỉ trả điểm, tiêu đề
  /// gợi ý và tên khách gợi ý. Giữ số tĩnh cho tới khi hợp đồng API bổ sung.
  static const String fieldBudget = '~15.000.000 ₫';

  /// CHƯA NỐI API — `VoiceLeadDraft` chưa có field hạn chót, lý do như trên.
  static const String fieldDeadline = 'Hạn: 27/08';

  static const String cta = 'Dừng và tạo lead';

  /// Chiều cao 15 vạch sóng, chép đúng `--h` của bản phác thảo.
  static const List<double> waveHeights = [
    22,
    46,
    30,
    58,
    38,
    66,
    26,
    50,
    34,
    60,
    24,
    44,
    32,
    54,
    20,
  ];
}
