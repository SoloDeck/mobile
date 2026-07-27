import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/time/app_clock.dart';
import 'package:solodesk_mobile/modules/invoices/domain/entities/invoice.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_channel.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_tone.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_type.dart';
import 'package:solodesk_mobile/modules/reminders/presentation/controllers/reminder_compose_controller.dart';
import 'package:solodesk_mobile/modules/reminders/presentation/providers/reminders_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/accent_card.dart';
import 'package:solodesk_mobile/ui/avatar.dart';
import 'package:solodesk_mobile/ui/bottom_action_bar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/money.dart';
import 'package:solodesk_mobile/ui/perforated_divider.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/stamp_badge.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// MÀN 12 — Nhắc thu tiền.
///
/// Đối chiếu: khối `<figure class="unit">` của `MÀN 12` (dòng 965-1020) trong
/// `design/solodesk-mobile-ui.html`, gồm cả `<figcaption>`.
///
/// Bốn quyết định trong figcaption, đừng đảo lại khi sửa:
/// - **Ba mức giọng văn** ("Thân mật" / "Lịch sự" / "Dứt khoát") thay vì chỉ hai
///   "trang trọng / thân mật" — vì đòi nợ lần bảy khác hẳn lần đầu. Dải chip
///   `Giọng văn` cho chọn đủ ba mức, "Lịch sự" là mặc định của
///   [ReminderDraft.tone] (`StatusChip(tone: Tone.solid)` khi đang chọn),
///   khớp nền mực đậm trong bản phác thảo.
/// - Bản nhắc do AI soạn **kèm sẵn link MoMo**: bỏ đi bước khách phải hỏi lại số
///   tài khoản — công tắc "Đính kèm link MoMo" ở [_ToggleCard] mặc định bật
///   (`ReminderDraft.attachPaymentLink` mặc định `true`).
/// - Câu chữ AI soạn nêu rõ **số tiền và ngày**, đồng thời **mở đường lùi** (xuất
///   hoá đơn, dời lịch) để giữ quan hệ — do `ReminderMessageComposer` soạn từ
///   hoá đơn thật, xem `domain/services/reminder_message_composer.dart`.
/// - **Chọn kênh gửi ở ngay trên nút gửi**: chip "Zalo OA" ở [_ChannelChipRow]
///   đang chọn theo mặc định (`ReminderDraft.channel` = `ReminderChannel.zalo`,
///   tone ngọc, dấu tick), "Email dự phòng" chỉ là chip trung tính đứng cạnh —
///   phương án dự phòng, không phải lựa chọn ngang hàng.
///
/// Nút "Gửi ngay" ở đây không vi phạm quy tắc 5 (AI không tự gửi): toàn bộ màn
/// này chính là bước con người xem và **sửa được** ("Sửa được" cạnh chip "AI
/// soạn", nút "Sửa lời" ở dải hành động) trước khi bấm gửi — đây đã là bước
/// duyệt, không phải gửi thẳng từ hậu trường.
///
/// ## Dữ liệu
///
/// [invoiceId] xác định hoá đơn cần nhắc. `reminderComposeDataProvider` tải
/// hoá đơn thật (`invoiceDetailProvider` của module invoices) và soạn sẵn một
/// bản nháp bằng giọng "Lịch sự"; `reminderComposeControllerProvider` giữ
/// trạng thái soạn thảo (giọng văn, kênh, công tắc, nội dung đã sửa tay) cho
/// tới khi bấm "Gửi ngay".
class ReminderComposePage extends ConsumerWidget {
  const ReminderComposePage({required this.invoiceId, super.key});

  final String invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(reminderComposeDataProvider(invoiceId));
    final appearance = ref.watch(appearanceControllerProvider);

    // Bọc `Theme` mới vì app vẫn đang chạy `AppTheme` cũ ở gốc — không bọc thì
    // toàn màn ra sai màu.
    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          bottom: false,
          child: AsyncValueWidget<ReminderComposeData>(
            value: dataAsync,
            onRetry: () =>
                ref.invalidate(reminderComposeDataProvider(invoiceId)),
            data: (data) =>
                _ReminderComposeBody(invoiceId: invoiceId, data: data),
          ),
        ),
      ),
    );
  }
}

/// Toàn bộ nội dung màn sau khi hoá đơn đã tải xong — `Stack` gốc (Column cuộn
/// + `BottomActionBar` nổi đáy), giữ nguyên hình dạng bản mock cũ.
///
/// Là `ConsumerWidget` (không phải `StatelessWidget`) vì phần lớn widget con
/// cần `ref` để đọc/điều khiển `reminderComposeControllerProvider(invoiceId)`.
class _ReminderComposeBody extends ConsumerWidget {
  const _ReminderComposeBody({required this.invoiceId, required this.data});

  final String invoiceId;
  final ReminderComposeData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(reminderComposeControllerProvider(invoiceId));
    final controller = reminderComposeControllerProvider(invoiceId).notifier;
    final invoice = data.invoice;
    final overdueDays = ref
        .watch(appClockProvider)()
        .difference(invoice.dueDate)
        .inDays;

    return Stack(
      children: [
        Column(
          children: [
            SoloAppBar(
              title: 'Nhắc thanh toán',
              titleSize: SoloAppBar.sm,
              leading: IconButtonBox(
                SoloIcons.back,
                label: 'Quay lại',
                ghost: true,
                onTap: () => context.pop(),
              ),
            ),
            Expanded(
              // SingleChildScrollView chứ không phải ListView: nội dung dựng
              // hết một lượt để test còn tìm được phần dưới màn.
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppGap.screen,
                  0,
                  AppGap.screen,
                  AppGap.navBarInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PaymentSlip(invoice: invoice, overdueDays: overdueDays),
                    const SizedBox(height: AppGap.sectionTop),
                    const SectionLabel('Giọng văn'),
                    const SizedBox(height: AppGap.sectionBottom),
                    _ToneChipRow(
                      selected: draft.tone,
                      onSelect: (tone) => ref.read(controller).setTone(tone),
                    ),
                    const SizedBox(height: AppGap.lg),
                    _DraftCard(body: draft.body),
                    const SizedBox(height: AppGap.betweenCards),
                    _ToggleCard(
                      icon: SoloIcons.cash,
                      iconColor: AppColors.momo,
                      label: 'Đính kèm link MoMo',
                      on: draft.attachPaymentLink,
                      onTap: () => ref.read(controller).toggleMomoLink(),
                    ),
                    const SizedBox(height: AppGap.betweenCards),
                    _ToggleCard(
                      icon: SoloIcons.clock,
                      iconColor: AppColors.ink2,
                      label: 'Tự nhắc lại sau 3 ngày',
                      on: draft.repeatAfterDays != null,
                      onTap: () => ref.read(controller).toggleRepeat(),
                    ),
                    const SizedBox(height: AppGap.lg),
                    _ChannelChipRow(
                      selected: draft.channel,
                      onSelect: (channel) =>
                          ref.read(controller).setChannel(channel),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: BottomActionBar(
            child: _ActionRow(
              invoiceId: invoiceId,
              invoice: invoice,
              reminderType: data.suggestedType,
            ),
          ),
        ),
      ],
    );
  }
}

/// Tấm phiếu tiền cần nhắc: người nhận, hoá đơn, và số tiền còn nợ. Là
/// `SlipCard` vì nội dung đúng là một khoản tiền phải đòi (quy tắc 3).
class _PaymentSlip extends StatelessWidget {
  const _PaymentSlip({required this.invoice, required this.overdueDays});

  final Invoice invoice;

  /// Số ngày đã trôi qua kể từ hạn thanh toán, tính qua `appClockProvider`.
  /// Có thể ≤ 0 nếu hoá đơn chưa tới hạn — khi đó không hiện con dấu "Trễ".
  final int overdueDays;

  @override
  Widget build(BuildContext context) {
    return SlipCard(
      notch: 74,
      borderColor: AppColors.momoLine,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionLabel('Gửi cho'),
              // Chỉ hiện khi thật sự quá hạn — mock cũ luôn giả định quá hạn,
              // dữ liệu thật có thể chưa tới hạn thanh toán.
              if (overdueDays > 0)
                StampBadge.due('Trễ $overdueDays ngày')
              else
                const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: AppGap.md),
          Row(
            children: [
              Avatar.initials(
                _initials(invoice.clientName ?? '?'),
                tone: Tone.money,
              ),
              const SizedBox(width: AppGap.row),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      invoice.clientName ?? 'Khách hàng',
                      style: AppText.bodyStrong,
                    ),
                    // Đổi từ 'Đợt 2/3 · đến hạn 19/07' của mock: backend
                    // không có khái niệm số đợt thanh toán.
                    Text(
                      'Hoá đơn ${invoice.invoiceNumber} · đến hạn ${_fmtDate(invoice.dueDate)}',
                      style: AppText.mut,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const PerforatedDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Số tiền', style: AppText.mut),
              Money.card(invoice.amountOutstanding),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ba mức giọng văn — quyết định đầu tiên trong figcaption. Chip trùng với
/// [selected] dùng `Tone.solid` (nền mực đặc), hai chip còn lại trung tính.
class _ToneChipRow extends StatelessWidget {
  const _ToneChipRow({required this.selected, required this.onSelect});

  final ReminderTone selected;
  final ValueChanged<ReminderTone> onSelect;

  @override
  Widget build(BuildContext context) {
    // `Wrap` chứ không phải `Row`: chưa có font thật nên chữ đo rộng hơn thật,
    // ba chip cộng khoảng cách có thể vượt bề ngang màn. `Wrap` tự xuống dòng
    // thay vì tràn ngang.
    return Wrap(
      spacing: AppGap.betweenChips,
      runSpacing: AppGap.betweenChips,
      children: [
        for (final tone in ReminderTone.values)
          _TappableChip(
            label: tone.label,
            tone: tone == selected ? Tone.solid : Tone.neutral,
            selected: tone == selected,
            onTap: () => onSelect(tone),
          ),
      ],
    );
  }
}

/// Bản nhắc do AI soạn — vạch tím bên trái (`AccentCard(tone: Tone.ai)` khớp
/// đúng `border-left:3px solid var(--ai)` trong bản phác thảo), kèm nhãn "Sửa
/// được" để nói rõ đây là bản nháp có thể chỉnh trước khi gửi.
class _DraftCard extends StatelessWidget {
  const _DraftCard({required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    return AccentCard(
      tone: Tone.ai,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusChip('AI soạn', tone: Tone.ai, icon: SoloIcons.ai),
              Text('Sửa được', style: AppText.mut),
            ],
          ),
          const SizedBox(height: AppGap.lg),
          // Đánh đổi: bản mock cũ bôi đậm riêng số tiền bằng ba mảnh `TextSpan`
          // cố định (`messageBefore`/`messageAmount`/`messageAfter`). Nội dung
          // giờ là MỘT chuỗi hoàn chỉnh do `ReminderMessageComposer` soạn (số
          // tiền nằm giữa câu, không tách sẵn thành mảnh riêng) nên chấp nhận
          // mất chi tiết bôi đậm số tiền, hiển thị nguyên văn bằng một `Text`
          // phẳng — người dùng vẫn đọc được và sửa được toàn bộ qua "Sửa lời".
          Text(body, style: AppText.sub),
        ],
      ),
    );
  }
}

/// Một hàng công tắc trong thẻ: icon + nhãn bên trái, trạng thái bật/tắt bên
/// phải. Dùng chung cho "Đính kèm link MoMo" và "Tự nhắc lại sau 3 ngày".
///
/// Để private vì mới chỉ dùng trong MÀN 12. Nếu có màn khác cũng cần một hàng
/// công tắc y hệt (nhãn + icon + track bật/tắt trong `Card`) thì nâng lên
/// `lib/ui/`.
class _ToggleCard extends StatelessWidget {
  const _ToggleCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.on,
    required this.onTap,
  });

  final SoloIconData icon;
  final Color iconColor;
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Trạng thái không được truyền tải chỉ bằng màu: nhãn cho trình đọc màn
    // hình nói rõ "đang bật"/"đang tắt" chứ không chỉ dựa vào `SemanticsFlag`.
    final stateLabel = on ? '$label, đang bật' : '$label, đang tắt';

    return Card(
      // `clipBehavior` để vệt ripple của `InkWell` không tràn ra ngoài bo góc
      // — `CardThemeData` trong `AppTheme` không đặt sẵn `clipBehavior`.
      clipBehavior: Clip.antiAlias,
      // Bọc `InkWell` để cả thẻ thành vùng chạm thật (mock cũ chỉ vẽ hình,
      // chưa gắn hành vi bấm) — bo góc khớp `AppRadius.cardAll` của `Card`.
      child: InkWell(
        borderRadius: AppRadius.cardAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppGap.card,
            vertical: AppGap.lg,
          ),
          // Một `Row` phẳng, không lồng `Row` con: nhãn bọc `Expanded` để tự
          // co lại thay vì đẩy tràn ngang khi đo bằng font thay thế rộng hơn
          // thật.
          child: Row(
            children: [
              SoloIcon(icon, label: null, size: SoloIcon.sm, color: iconColor),
              const SizedBox(width: AppGap.row),
              Expanded(
                child: Text(
                  label,
                  style: AppText.body,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: AppGap.row),
              _ToggleTrack(on: on, label: stateLabel),
            ],
          ),
        ),
      ),
    );
  }
}

/// Đường ray công tắc bật/tắt, `<span style="border-radius:99px">` trong bản
/// phác thảo. Chỉ hiển thị trạng thái — vùng chạm thật nằm ở `InkWell` bọc cả
/// thẻ trong [_ToggleCard].
class _ToggleTrack extends StatelessWidget {
  const _ToggleTrack({required this.on, required this.label});

  final bool on;
  final String label;

  static const double _width = 44;
  static const double _height = 25;
  static const double _thumb = 19;
  static const double _inset = 3;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // `container: true`: nếu không, node này bị gộp chung với node ngầm
      // định của `Text(label)` đứng cạnh trong `Row`, ra một nhãn lặp hai lần
      // thay vì đúng một nhãn "..., đang bật/tắt" mà test tìm.
      container: true,
      label: label,
      toggled: on,
      child: Container(
        width: _width,
        height: _height,
        padding: const EdgeInsets.all(_inset),
        decoration: BoxDecoration(
          color: on ? AppColors.momo : AppColors.line,
          borderRadius: AppRadius.pillAll,
        ),
        child: Align(
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: const _ToggleThumb(),
        ),
      ),
    );
  }
}

class _ToggleThumb extends StatelessWidget {
  const _ToggleThumb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _ToggleTrack._thumb,
      height: _ToggleTrack._thumb,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Kênh gửi — quyết định thứ tư trong figcaption. Chỉ hai kênh khớp bản phác
/// thảo (Zalo OA / Email dự phòng), dù `ReminderChannel` còn `inApp`/`both`.
/// Chip khớp [selected] dùng tone ngọc kèm dấu tick, chip còn lại trung tính.
class _ChannelChipRow extends StatelessWidget {
  const _ChannelChipRow({required this.selected, required this.onSelect});

  final ReminderChannel selected;
  final ValueChanged<ReminderChannel> onSelect;

  static const _channels = [ReminderChannel.zalo, ReminderChannel.email];

  @override
  Widget build(BuildContext context) {
    // `Wrap` vì lý do như [_ToneChipRow]: chưa có font thật nên chip có thể
    // rộng hơn dự kiến.
    return Wrap(
      spacing: AppGap.betweenChips,
      runSpacing: AppGap.betweenChips,
      children: [
        for (final channel in _channels)
          _TappableChip(
            label: channel.label,
            tone: channel == selected ? Tone.ok : Tone.neutral,
            icon: channel == selected ? SoloIcons.check : null,
            selected: channel == selected,
            onTap: () => onSelect(channel),
          ),
      ],
    );
  }
}

/// Một `StatusChip` bấm được, đủ vùng chạm 44pt — cùng khuôn với
/// `_CopyTemplateButton` của MÀN 14 (`templates_page.dart`). Dùng chung cho
/// dải chọn giọng văn và dải chọn kênh gửi, hai dải chip duy nhất của màn này
/// thật sự đổi trạng thái khi bấm (khác `FilterChipBar` — không có ở đây vì
/// đây không phải bộ lọc danh sách).
class _TappableChip extends StatelessWidget {
  const _TappableChip({
    required this.label,
    required this.tone,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final Tone tone;
  final bool selected;
  final SoloIconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: IconButtonBox.tapTarget,
          child: Center(
            child: StatusChip(label, tone: tone, icon: icon),
          ),
        ),
      ),
    );
  }
}

/// Hai nút trong dải hành động đáy: "Sửa lời" mở ô soạn thảo tự do, "Gửi
/// ngay" là hành động chính nên chiếm phần rộng hơn và dùng nút đặc.
///
/// Là `ConsumerWidget` vì cả hai nút đều cần `ref` để gọi
/// `reminderComposeControllerProvider(invoiceId)`.
class _ActionRow extends ConsumerWidget {
  const _ActionRow({
    required this.invoiceId,
    required this.invoice,
    required this.reminderType,
  });

  final String invoiceId;
  final Invoice invoice;
  final ReminderType reminderType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () => _editBody(context, ref),
          style: AppTheme.outlined(),
          child: const Text('Sửa lời'),
        ),
        const SizedBox(width: AppGap.betweenButtons),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _sendNow(context, ref),
            style: AppTheme.filled(tone: Tone.money),
            icon: const SoloIcon(
              SoloIcons.send,
              label: null,
              size: SoloIcon.sm,
              color: AppColors.surface,
            ),
            label: const Text('Gửi ngay'),
          ),
        ),
      ],
    );
  }

  /// Mở ô soạn thảo tự do, giá trị ban đầu là nội dung bản nháp hiện tại.
  /// Nút "Lưu" ghi lại qua `editBody`, đúng bước "Sửa được" trong figcaption.
  Future<void> _editBody(BuildContext context, WidgetRef ref) async {
    final currentBody = ref
        .read(reminderComposeControllerProvider(invoiceId))
        .body;
    final textController = TextEditingController(text: currentBody);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _EditBodySheet(controller: textController),
    );
    textController.dispose();
    if (!context.mounted || result == null) return;
    ref
        .read(reminderComposeControllerProvider(invoiceId).notifier)
        .editBody(result);
  }

  /// Tạo reminder thật qua `ScheduleReminderUseCase`; thành công thì đóng
  /// màn, lỗi thì báo bằng `SnackBar` — không tự động thử lại, người dùng bấm
  /// "Gửi ngay" lần nữa nếu muốn.
  Future<void> _sendNow(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(reminderComposeControllerProvider(invoiceId).notifier)
          .sendNow(invoice: invoice, reminderType: reminderType);
      if (context.mounted) context.pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gửi nhắc thất bại: $e')));
    }
  }
}

/// Nội dung ô soạn thảo tự do trong `showModalBottomSheet` của "Sửa lời" —
/// tách khỏi [_ActionRow] để [TextEditingController] có một `BuildContext`
/// riêng cho `MediaQuery.viewInsets` (bàn phím) của chính sheet.
class _EditBodySheet extends StatelessWidget {
  const _EditBodySheet({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppGap.screen,
        right: AppGap.screen,
        top: AppGap.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppGap.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Sửa lời nhắc'),
          const SizedBox(height: AppGap.sectionBottom),
          TextField(
            controller: controller,
            maxLines: 8,
            minLines: 4,
            style: AppText.sub,
          ),
          const SizedBox(height: AppGap.lg),
          FilledButton(
            style: AppTheme.filled(tone: Tone.money),
            // `Navigator.of(context).pop`, không phải `context.pop()` của
            // go_router: sheet này là một route cục bộ do
            // `showModalBottomSheet` dựng, không nằm trong ngăn xếp
            // `GoRouter` — dùng đúng `Navigator` sở hữu nó.
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

/// Chữ viết tắt cho `Avatar.initials`: chữ cái đầu của (tối đa) hai từ đầu
/// tiên trong tên khách hàng, viết hoa. '?' khi không có tên nào để tách.
String _initials(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return '?';
  if (words.length == 1) {
    // `int.clamp` trả về `num`, không phải `int` — dùng ternary thay vì
    // `substring(0, len.clamp(0, 2))` để tránh lỗi kiểu khi biên dịch.
    final word = words.first;
    return (word.length > 2 ? word.substring(0, 2) : word).toUpperCase();
  }
  return (words[0][0] + words[1][0]).toUpperCase();
}

/// 'dd/MM' không năm — khớp mock '19/07'.
String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
