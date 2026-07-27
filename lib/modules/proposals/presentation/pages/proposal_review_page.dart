import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/time/app_clock.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal_content.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/payment_schedule.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_status.dart';
import 'package:solodesk_mobile/modules/proposals/presentation/controllers/proposal_review_controller.dart';
import 'package:solodesk_mobile/modules/proposals/presentation/providers/proposals_provider.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/bottom_action_bar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/money.dart';
import 'package:solodesk_mobile/ui/mono_text.dart';
import 'package:solodesk_mobile/ui/notice_card.dart';
import 'package:solodesk_mobile/ui/perforated_divider.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/stamp_badge.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// MÀN 08 — Duyệt và gửi báo giá.
///
/// Đối chiếu: khối `MÀN 08` (dòng 683-743) trong
/// `design/solodesk-mobile-ui.html`, gồm cả `<figcaption>`.
///
/// Bốn quyết định trong figcaption, đừng đảo lại khi sửa:
/// - Con dấu **"Bản nháp"** nghiêng đặt trong `SoloAppBar` — `StampBadge.draft`,
///   không thể nhầm bản chưa duyệt với bản đã gửi khách. Trang này chỉ dùng để
///   review bản nháp nên con dấu luôn hiện `StampBadge.draft`, kể cả khi
///   `proposal.status` không còn là `draft` (đọc nhãn trạng thái thật qua
///   `proposal.status.label`).
/// - App **chặn gửi** khi còn biến bắt buộc trống: `NoticeCard` báo rõ "Còn N
///   chỗ trống", ô "Số vòng sửa" hiện "chưa điền" thay vì để trống im lặng, và
///   nút "Duyệt và gửi khách" bị khoá (`onPressed: null`) chừng nào còn thiếu.
/// - Lịch thanh toán vẽ thành dải tỉ lệ theo `data.schedule` — sai tổng phần
///   trăm là thấy ngay bằng mắt, không cần đọc số.
/// - Chip "AI soạn"/"Tự soạn" và "Mẫu: ..." ghi rõ mẫu nào và báo giá này có
///   phải AI sinh không — người dùng hiểu chi phí AI mình đang tiêu (quy tắc 5:
///   AI không tự gửi, mọi thứ đi qua nút "Duyệt và gửi khách").
///
/// Chuyển từ `lib/features/quote_review/quote_review_screen.dart`. Đã nối
/// `proposalReviewProvider` (gộp báo giá + deal + mẫu mặc định + lịch thanh
/// toán + danh sách ô còn trống) — không còn dữ liệu giả.
class ProposalReviewPage extends ConsumerWidget {
  const ProposalReviewPage({required this.proposalId, super.key});

  final String proposalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewAsync = ref.watch(proposalReviewProvider(proposalId));

    return Theme(
      data: AppTheme.light(),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          child: AsyncValueWidget<ProposalReviewData>(
            value: reviewAsync,
            onRetry: () => ref.invalidate(proposalReviewProvider(proposalId)),
            data: (data) => _ProposalReviewBody(data: data),
          ),
        ),
      ),
    );
  }
}

/// Toàn bộ thân màn sau khi `proposalReviewProvider` đã tải xong — AppBar,
/// cảnh báo ô trống, bản xem trước, chip mô hình AI, và dải hành động đáy.
///
/// `ConsumerWidget` (không phải `StatelessWidget`) vì nút "Sửa"/"Điền ngay" mở
/// `FillGapsSheet`, còn nút "Duyệt và gửi khách" gọi thẳng
/// `proposalReviewControllerProvider` — cả hai cần `ref`.
class _ProposalReviewBody extends ConsumerWidget {
  const _ProposalReviewBody({required this.data});

  final ProposalReviewData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposal = data.proposal;
    final content = proposal.content;

    final title = 'Báo giá ${proposal.displayNumber}';
    final stampText = proposal.status.label;
    final gapsCount = data.gaps.length;
    final missingMessage = 'Còn $gapsCount chỗ trống cần điền trước khi gửi';
    final scopeText = content.scopeOfWork.isEmpty
        ? 'chưa điền'
        : content.scopeOfWork.join(' · ');
    final validUntilText = content.validUntil == null
        ? 'chưa điền'
        : 'hiệu lực đến ${_fmtDate(content.validUntil!)}';
    final revisionText = content.revisionRounds == null
        ? 'chưa điền'
        : '${content.revisionRounds} vòng';
    final aiModelLabel = proposal.aiGenerated ? 'AI soạn' : 'Tự soạn';
    final templateLabel = data.template == null
        ? null
        : 'Mẫu: ${data.template!.name}';
    final canSend = data.gaps.isEmpty && proposal.status.canSend;

    void openFillGaps() => _openFillGapsSheet(context, data: data);

    return Column(
      children: [
        SoloAppBar(
          title: title,
          titleSize: SoloAppBar.xs,
          leading: IconButtonBox(
            SoloIcons.back,
            label: 'Quay lại',
            ghost: true,
            onTap: () => context.pop(),
          ),
          actions: [StampBadge.draft(stampText)],
        ),
        Expanded(
          // SingleChildScrollView chứ không phải ListView: nội dung dưới màn
          // vẫn phải tìm được bằng test.
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppGap.screen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MissingFieldsNotice(
                  gapsCount: gapsCount,
                  message: missingMessage,
                  onFillGaps: openFillGaps,
                ),
                const SizedBox(height: AppGap.betweenCards),
                _QuotePreviewCard(
                  headerLine: '${proposal.displayNumber} · $validUntilText',
                  clientName: data.deal.clientName ?? 'Chưa rõ khách hàng',
                  scopeText: scopeText,
                  timelineText: content.timeline ?? 'chưa điền',
                  revisionText: revisionText,
                  revisionIsMissing: content.revisionRounds == null,
                  total: data.total,
                  schedule: data.schedule,
                ),
                const SizedBox(height: AppGap.lg),
                _GenerationMetaRow(
                  aiModelLabel: aiModelLabel,
                  templateLabel: templateLabel,
                ),
                const SizedBox(height: AppGap.card),
              ],
            ),
          ),
        ),
        BottomActionBar(
          caption: 'Đánh dấu đã gửi · kèm link xem bản PDF',
          child: _ApprovalButtonRow(
            onEdit: openFillGaps,
            onSend: canSend
                ? () => ref
                      .read(proposalReviewControllerProvider.notifier)
                      .send(proposal.id, proposal.dealId)
                : null,
          ),
        ),
      ],
    );
  }
}

/// Mở `FillGapsSheet` bằng `showModalBottomSheet` — dùng chung cho nút "Sửa"
/// và chip "Điền ngay" của `_MissingFieldsNotice`.
void _openFillGapsSheet(
  BuildContext context, {
  required ProposalReviewData data,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => FillGapsSheet(
      proposalId: data.proposal.id,
      dealId: data.proposal.dealId,
      current: data.proposal.content,
      showTotalField: data.total == null,
    ),
  );
}

/// Cảnh báo còn ô bắt buộc trống. `NoticeCard` chứ không phải `Card` thường vì
/// đây là điều kiện đang chặn người dùng gửi — họ cần thấy nó trước mọi thứ
/// khác trên màn. Ẩn hoàn toàn khi [gapsCount] bằng 0.
class _MissingFieldsNotice extends StatelessWidget {
  const _MissingFieldsNotice({
    required this.gapsCount,
    required this.message,
    required this.onFillGaps,
  });

  final int gapsCount;
  final String message;
  final VoidCallback onFillGaps;

  @override
  Widget build(BuildContext context) {
    if (gapsCount == 0) return const SizedBox.shrink();

    return NoticeCard(
      tone: Tone.warn,
      icon: SoloIcons.clock,
      message: message,
      trailing: _FillGapsChip(onTap: onFillGaps),
    );
  }
}

/// `StatusChip` không tự có vùng chạm 44pt — bọc `GestureDetector` giống
/// `_CopyTemplateButton` của MÀN 14 để chip "Điền ngay" bấm được thật sự.
class _FillGapsChip extends StatelessWidget {
  const _FillGapsChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Điền các ô còn thiếu',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: const SizedBox(
          height: IconButtonBox.tapTarget,
          child: Center(child: StatusChip('Điền ngay', tone: Tone.warn)),
        ),
      ),
    );
  }
}

/// Bản xem trước gửi khách. `Card` thường, không phải `SlipCard`: nội dung là
/// một tài liệu để đọc như bản nháp, không phải chứng từ tiền phải đòi — xem
/// ghi chú "MÀN 05 và MÀN 08" trong doc comment của `PerforatedDivider`.
class _QuotePreviewCard extends StatelessWidget {
  const _QuotePreviewCard({
    required this.headerLine,
    required this.clientName,
    required this.scopeText,
    required this.timelineText,
    required this.revisionText,
    required this.revisionIsMissing,
    required this.total,
    required this.schedule,
  });

  final String headerLine;
  final String clientName;
  final String scopeText;
  final String timelineText;
  final String revisionText;
  final bool revisionIsMissing;
  final double? total;
  final PaymentSchedule schedule;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppGap.slip,
              AppGap.slip,
              AppGap.slip,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SectionLabel('Xem trước bản gửi khách'),
                const SizedBox(height: AppGap.md),
                const Text('ĐỀ XUẤT DỊCH VỤ', style: _titleStyle),
                const SizedBox(height: AppGap.xxs),
                MonoText(headerLine, style: _monoMutStyle),
                const PerforatedDivider(),
                _PreviewRow(
                  label: 'Khách hàng',
                  value: Text(clientName, style: _boldValueStyle),
                ),
                const SizedBox(height: AppGap.sm),
                _PreviewRow(
                  label: 'Phạm vi',
                  value: Text(scopeText, style: _boldValueStyle),
                ),
                const SizedBox(height: AppGap.sm),
                _PreviewRow(label: 'Thời gian', value: MonoText(timelineText)),
                const SizedBox(height: AppGap.sm),
                _PreviewRow(
                  label: 'Số vòng sửa',
                  value: StatusChip(
                    revisionText,
                    tone: revisionIsMissing ? Tone.warn : Tone.neutral,
                  ),
                ),
                const SizedBox(height: AppGap.sm),
                _PreviewRow(
                  label: 'Tổng cộng',
                  value: total != null
                      ? Money(total!, style: AppText.numMd)
                      : const StatusChip('chưa điền', tone: Tone.warn),
                ),
              ],
            ),
          ),
          _PaymentScheduleSection(schedule: schedule),
        ],
      ),
    );
  }

  static const TextStyle _titleStyle = TextStyle(
    fontFamily: AppFontFamily.display,
    fontWeight: FontWeight.w800,
    fontSize: 19,
    letterSpacing: 19 * -0.02,
    color: AppColors.ink,
  );

  // Không viết `AppText.mut.copyWith(fontFamily: ...)` vì kết quả không còn
  // là hằng số biên dịch. Giữ đúng các trị số của `AppText.mut`, chỉ đổi họ
  // chữ sang mono như bản phác thảo (`.mut` + `font-family:var(--mono)`).
  static const TextStyle _monoMutStyle = TextStyle(
    fontFamily: AppFontFamily.mono,
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.ink3,
  );

  static const TextStyle _boldValueStyle = TextStyle(
    fontFamily: AppFontFamily.body,
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.ink,
  );
}

/// Một dòng "nhãn mờ bên trái — giá trị đậm bên phải" trong bản xem trước,
/// `.between` trong bản phác thảo. Để private vì mới chỉ dùng ở màn này.
class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppText.mut),
        const SizedBox(width: AppGap.row),
        // Bọc `Expanded` + căn phải thay vì `mainAxisAlignment.spaceBetween`:
        // giá trị vẫn đứng ở mép phải như bản phác thảo, nhưng có chỗ để xuống
        // dòng thay vì tràn Row khi đo bằng phông chữ dự phòng của môi trường
        // test (chưa nạp được ba phông thật).
        Expanded(
          child: Align(alignment: Alignment.centerRight, child: value),
        ),
      ],
    );
  }
}

/// Khối "Lịch thanh toán" — nền giấy tách khỏi phần thân trắng phía trên bằng
/// một đường kẻ, đúng cách bản phác thảo phân tách hai khối trong cùng một
/// `.card`. Bao nhiêu đợt trong [schedule] thì render bấy nhiêu — không còn
/// cố định ba đợt.
class _PaymentScheduleSection extends StatelessWidget {
  const _PaymentScheduleSection({required this.schedule});

  final PaymentSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final stages = schedule.stages;
    final Widget statusChip = schedule.isComplete
        ? const StatusChip('Đủ 100%', tone: Tone.ok)
        : StatusChip(
            'Còn thiếu ${100 - schedule.totalPercent}%',
            tone: Tone.warn,
          );

    return Container(
      margin: const EdgeInsets.only(top: AppGap.card),
      padding: const EdgeInsets.symmetric(
        horizontal: AppGap.slip,
        vertical: AppGap.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const SectionLabel('Lịch thanh toán'), statusChip],
          ),
          const SizedBox(height: AppGap.md),
          _PaymentScheduleBar(schedule: schedule),
          const SizedBox(height: AppGap.sm),
          Row(
            children: [
              for (var i = 0; i < stages.length; i++)
                Expanded(
                  child: Text(
                    '${stages[i].label} ${stages[i].percent}%',
                    style: AppText.mut,
                    // Đợt đầu căn trái, đợt cuối căn phải, các đợt ở giữa (kể
                    // cả khi nhiều hơn 3 đợt) căn giữa — đúng bố cục ba đoạn
                    // gốc, tổng quát hoá cho số đợt bất kỳ.
                    textAlign: i == 0
                        ? TextAlign.left
                        : i == stages.length - 1
                        ? TextAlign.right
                        : TextAlign.center,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dải tỉ lệ nhiều đoạn của lịch thanh toán, `.bar` gồm các `<i>` cùng màu
/// hồng nhưng khác độ trong. Không dùng `ProgressBar` (chỉ tô một khối) hay
/// `StageBar` (bo tròn cả hai đầu mỗi đoạn dù có khe hở) — dải này chỉ bo hai
/// đầu ngoài cùng của cả dải, đúng CSS gốc.
///
/// Private vì kiểu nhiều đoạn tỉ lệ cùng màu chỉ xuất hiện ở màn này; nếu có
/// màn khác cũng cần thì nâng lên `lib/ui/`.
class _PaymentScheduleBar extends StatelessWidget {
  const _PaymentScheduleBar({required this.schedule});

  final PaymentSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final stages = schedule.stages;

    return SizedBox(
      height: AppGap.xxl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < stages.length; i++) ...[
            if (i > 0) const SizedBox(width: AppGap.xxs),
            Expanded(
              flex: stages[i].percent,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.momo.withValues(
                    alpha: schedule.opacityAt(i),
                  ),
                  borderRadius: BorderRadius.horizontal(
                    left: i == 0
                        ? const Radius.circular(AppRadius.stamp)
                        : Radius.zero,
                    right: i == stages.length - 1
                        ? const Radius.circular(AppRadius.stamp)
                        : Radius.zero,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Hai chip cuối thân màn: có phải AI soạn không, và mẫu đang dùng (nếu có).
/// Nói rõ chi phí AI đang tiêu, đúng bullet cuối của figcaption.
///
/// `Wrap` chứ không phải `Row`: mỗi chip tự co theo chữ (`softWrap: false`
/// bên trong `StatusChip`) nên khi phông chữ dự phòng đo rộng hơn phông thật,
/// hai chip cộng lại có thể vượt bề ngang 354pt còn lại — `Wrap` cho phép chip
/// thứ hai rơi xuống dòng dưới thay vì đẩy tràn `Row`.
class _GenerationMetaRow extends StatelessWidget {
  const _GenerationMetaRow({
    required this.aiModelLabel,
    required this.templateLabel,
  });

  final String aiModelLabel;

  /// `null` khi không tìm được mẫu mặc định/hệ thống nào — không hiện chip.
  final String? templateLabel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppGap.betweenChips,
      runSpacing: AppGap.xs,
      children: [
        StatusChip(aiModelLabel, tone: Tone.ai, icon: SoloIcons.ai),
        if (templateLabel != null) StatusChip(templateLabel!),
      ],
    );
  }
}

/// Hàng nút của dải hành động đáy: "Sửa" phụ, "Duyệt và gửi khách" chính.
///
/// Nút chính bị khoá (`onPressed: null`) khi còn ô bắt buộc trống — đúng bullet
/// thứ hai của figcaption: app chặn gửi thay vì để người dùng gửi thiếu rồi
/// báo lỗi sau.
class _ApprovalButtonRow extends StatelessWidget {
  const _ApprovalButtonRow({required this.onEdit, required this.onSend});

  final VoidCallback onEdit;

  /// `null` khi còn ô bắt buộc trống hoặc báo giá không còn ở trạng thái có
  /// thể gửi (`proposal.status.canSend`).
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: onEdit,
          style: AppTheme.outlined(),
          child: const Text('Sửa'),
        ),
        const SizedBox(width: AppGap.betweenButtons),
        Expanded(
          child: FilledButton.icon(
            onPressed: onSend,
            style: AppTheme.filled(),
            icon: const SoloIcon(
              SoloIcons.send,
              label: null,
              size: SoloIcon.sm,
              color: AppColors.surface,
            ),
            label: const Text('Duyệt và gửi khách'),
          ),
        ),
      ],
    );
  }
}

/// Bảng nhập nhanh 3 khoá riêng của mobile (`revision_rounds`, `valid_until`,
/// `total`) — mở từ chip "Điền ngay" hoặc nút "Sửa". Không làm đẹp: không có
/// trong bản phác thảo gốc nên không bị golden test kiểm tra hình dạng.
class FillGapsSheet extends ConsumerStatefulWidget {
  const FillGapsSheet({
    super.key,
    required this.proposalId,
    required this.dealId,
    required this.current,
    required this.showTotalField,
  });

  final String proposalId;
  final String dealId;
  final ProposalContent current;

  /// Chỉ hiện ô "Tổng cộng" khi tổng hiện tại chưa xác định được từ đâu cả
  /// (`ProposalReviewData.total == null`) — nếu deal đã có giá trị thì không
  /// cần bắt người dùng nhập lại.
  final bool showTotalField;

  @override
  ConsumerState<FillGapsSheet> createState() => _FillGapsSheetState();
}

class _FillGapsSheetState extends ConsumerState<FillGapsSheet> {
  late final TextEditingController _revisionController;
  late final TextEditingController _totalController;
  DateTime? _validUntil;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _revisionController = TextEditingController(
      text: widget.current.revisionRounds?.toString() ?? '',
    );
    _totalController = TextEditingController(
      text: widget.current.total?.toStringAsFixed(0) ?? '',
    );
    _validUntil = widget.current.validUntil;
  }

  @override
  void dispose() {
    _revisionController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _pickValidUntil() async {
    final now = ref.read(appClockProvider)();
    final picked = await showDatePicker(
      context: context,
      initialDate: _validUntil ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null && mounted) setState(() => _validUntil = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final revisionRounds = int.tryParse(_revisionController.text.trim());
    final total = widget.showTotalField
        ? double.tryParse(_totalController.text.trim())
        : null;
    await ref
        .read(proposalReviewControllerProvider.notifier)
        .fillGaps(
          id: widget.proposalId,
          dealId: widget.dealId,
          current: widget.current,
          revisionRounds: revisionRounds,
          validUntil: _validUntil,
          total: total,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppGap.screen,
        AppGap.lg,
        AppGap.screen,
        MediaQuery.of(context).viewInsets.bottom + AppGap.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Điền thông tin còn thiếu'),
          const SizedBox(height: AppGap.lg),
          TextField(
            controller: _revisionController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Số vòng sửa'),
          ),
          const SizedBox(height: AppGap.md),
          OutlinedButton(
            onPressed: _pickValidUntil,
            style: AppTheme.outlined(),
            child: Text(
              _validUntil == null
                  ? 'Chọn hiệu lực đến'
                  : 'Hiệu lực đến ${_fmtDate(_validUntil!)}',
            ),
          ),
          if (widget.showTotalField) ...[
            const SizedBox(height: AppGap.md),
            TextField(
              controller: _totalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tổng cộng'),
            ),
          ],
          const SizedBox(height: AppGap.lg),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: AppTheme.filled(),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

/// `dd/MM/yyyy`, viết tay để không phụ thuộc `intl` locale đã nạp hay chưa.
String _fmtDate(DateTime d) {
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  return '$day/$month/${d.year}';
}
