import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/time/app_clock.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/modules/templates/domain/entities/template.dart';
import 'package:solodesk_mobile/modules/templates/domain/value_objects/template_lint.dart';
import 'package:solodesk_mobile/modules/templates/presentation/controllers/templates_controller.dart';
import 'package:solodesk_mobile/modules/templates/presentation/providers/templates_provider.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/avatar.dart';
import 'package:solodesk_mobile/ui/filter_chip_bar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/notice_card.dart';
import 'package:solodesk_mobile/ui/section_header.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// MÀN 14 — Thư viện mẫu tự quản.
///
/// Đối chiếu: khối `MÀN 14` (dòng 1095-1152) trong
/// `design/solodesk-mobile-ui.html`, gồm cả `<figcaption>`.
///
/// Dữ liệu đọc qua Drift cục bộ (`lib/modules/templates/infrastructure`) —
/// backend không có API cho mẫu của người dùng, chỉ có `/admin/templates`
/// dành cho quản trị viên (freelancer gọi bị 403). KHÔNG BAO GIỜ gọi endpoint
/// đó từ module này.
///
/// Bốn quyết định trong figcaption, đừng đảo lại khi sửa:
/// - Mẫu hệ thống và mẫu tự tạo nằm **chung một danh sách** (ba `Card` liền
///   nhau, không tách tab riêng), phân biệt bằng nhãn "chỉ đọc" ngay trong
///   dòng phụ đề của mẫu hệ thống, và nút "Chép" — figcaption gọi thẳng đây
///   là *nút* nên nó dựng thành một vùng chạm 44pt thật (`_CopyTemplateButton`),
///   không phải `StatusChip` đứng yên.
/// - Biến `{{...}}` luôn hiện bằng `StatusChip(tone: Tone.ai, mono: true)` —
///   cùng màu tím với nội dung AI chờ duyệt, vì đây là chỗ dữ liệu sẽ tự điền
///   vào khi gửi thật. Chip "+9" đứng cạnh không phải một biến nên giữ tông
///   trung tính, không tô tím theo.
/// - Cảnh báo thiếu điều khoản dùng `NoticeCard` tô nền cả mảng, nói rõ tài
///   liệu **đã gửi trước đây giữ nguyên bản chụp, không bị sửa ngược** — đúng
///   nguyên văn trong `message`.
/// - Màn này **không có** nút "Soạn thảo" hay ô nhập liệu nào: mobile chỉ cho
///   xem (mở từng thẻ), thấy mẫu nào đang là mặc định (chip "Mặc định"), và
///   chép; soạn thảo đầy đủ để dành cho bản web.
class TemplatesPage extends ConsumerWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider(null));
    final appearance = ref.watch(appearanceControllerProvider);

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      // Nút quay lại mang closure nên `Scaffold` không còn `const` được; các
      // nhánh con không đổi vẫn giữ `const` từng cái một.
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          child: Column(
            children: [
              SoloAppBar(
                title: 'Mẫu của tôi',
                titleSize: SoloAppBar.sm,
                leading: IconButtonBox(
                  SoloIcons.back,
                  label: 'Quay lại',
                  ghost: true,
                  onTap: () => context.pop(),
                ),
                actions: const [
                  IconButtonBox(SoloIcons.plus, label: 'Tạo mẫu mới'),
                ],
              ),
              Expanded(
                child: AsyncValueWidget<List<Template>>(
                  value: templatesAsync,
                  onRetry: () => ref.invalidate(templatesProvider),
                  data: (allTemplates) =>
                      _TemplatesBody(templates: allTemplates),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Phần cuộn của màn, sau khi danh sách mẫu đã tải xong.
///
/// `SingleChildScrollView` chứ không phải `ListView`: màn này chỉ có vài thẻ,
/// dựng hết một lượt để test tìm được cả tấm xem trước ở cuối màn.
///
/// Là `ConsumerWidget` (không phải `StatelessWidget`) vì nút "Chép" ở
/// `_SystemTemplateCard` cần `ref` để gọi `templatesControllerProvider`.
class _TemplatesBody extends ConsumerWidget {
  const _TemplatesBody({required this.templates});

  final List<Template> templates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = templates.length;
    final filterLabels = ['Tất cả · $total', 'Báo giá', 'Hợp đồng', 'Hoá đơn'];

    // Ba vị trí cố định trong danh sách — đúng bố cục bản phác thảo. Mẫu nào
    // không có dữ liệu tương ứng thì bỏ qua cả thẻ, không hiện rỗng.
    final defaultTpl = templates.where((t) => t.isDefault).firstOrNull;
    final copiedTpl = templates
        .where((t) => !t.isSystem && t.sourceTemplateId != null)
        .firstOrNull;
    final systemTpl = templates.where((t) => t.isSystem).firstOrNull;
    // "Mẫu đang mở" ưu tiên mẫu mặc định; nếu chưa ai đặt mặc định thì mở
    // tạm mẫu hệ thống để phần kiểm tra vẫn có nội dung để soi.
    final opened = defaultTpl ?? systemTpl;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppGap.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilterChipBar(labels: filterLabels, selectedIndex: 0),
          const SizedBox(height: AppGap.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppGap.screen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (defaultTpl != null) ...[
                  _DefaultTemplateCard(template: defaultTpl),
                  const SizedBox(height: AppGap.betweenCards),
                ],
                if (copiedTpl != null) ...[
                  _CopiedTemplateCard(template: copiedTpl),
                  const SizedBox(height: AppGap.betweenCards),
                ],
                if (systemTpl != null)
                  _SystemTemplateCard(
                    template: systemTpl,
                    onCopy: () => ref
                        .read(templatesControllerProvider.notifier)
                        .copy(systemTpl.id),
                  ),
                if (opened != null) ...[
                  const SectionHeader('Kiểm tra mẫu đang mở'),
                  _StaleTemplateNotice(issues: TemplateLint.check(opened.body)),
                  const SizedBox(height: AppGap.betweenCards),
                  _TemplatePreviewCard(template: opened),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mẫu của tôi, đang được chọn làm mặc định. Viền mực để nổi trong danh sách,
/// đúng `border-color:var(--ink)` của bản phác thảo — đây là dấu hiệu "chọn
/// mặc định" mà mobile cho phép thấy (bullet 4 của figcaption).
///
/// Là `ConsumerWidget` vì phụ đề "sửa N ngày trước" phải tính qua
/// `appClockProvider` (`AGENTS.md`: mọi thời gian tương đối đi qua đồng hồ
/// chung, không gọi `DateTime.now()` thẳng trong widget) để test ghim được
/// một mốc cố định.
class _DefaultTemplateCard extends ConsumerWidget {
  const _DefaultTemplateCard({required this.template});

  final Template template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(appClockProvider)();
    final updatedAt = template.updatedAt ?? template.createdAt;
    final daysAgo = now.difference(updatedAt).inDays;
    final vars = template.variables;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardAll,
        side: const BorderSide(color: AppColors.ink),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppGap.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _TemplateHeader(
              avatar: const Avatar.icon(SoloIcons.file, tone: Tone.ai),
              title: template.name,
              subtitle: 'Của tôi · sửa $daysAgo ngày trước',
              trailing: template.isDefault
                  ? const StatusChip('Mặc định', tone: Tone.ok)
                  : null,
            ),
            const SizedBox(height: AppGap.betweenCards),
            // `Wrap` chứ không phải `Row`: ba chip biến cộng lại rộng hơn bề
            // ngang thẻ ở một vài cỡ chữ hệ thống, xuống dòng còn hơn tràn ra
            // ngoài card.
            Wrap(
              spacing: AppGap.xs,
              runSpacing: AppGap.xs,
              children: [
                for (var i = 0; i < vars.length && i < 2; i++)
                  StatusChip('{{${vars[i]}}}', tone: Tone.ai, mono: true),
                if (vars.length > 2)
                  StatusChip('+${vars.length - 2}', mono: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Mẫu tự tạo, chép từ mẫu hệ thống rồi sửa lại. Vạch hồng ở avatar (đây là
/// mẫu báo giá — liên quan tiền), mũi tên chevron chỉ mở ra **xem**, không có
/// ô soạn thảo nào đi kèm (bullet 4).
class _CopiedTemplateCard extends StatelessWidget {
  const _CopiedTemplateCard({required this.template});

  final Template template;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppGap.card),
        child: _TemplateHeader(
          avatar: const Avatar.icon(SoloIcons.file, tone: Tone.money),
          title: template.name,
          subtitle: 'Chép từ mẫu hệ thống · đã sửa',
          trailing: const SoloIcon(
            SoloIcons.chevron,
            label: null,
            size: SoloIcon.sm,
            color: AppColors.ink3,
          ),
        ),
      ),
    );
  }
}

/// Mẫu hệ thống, chỉ đọc. Nhãn "chỉ đọc" nằm ngay trong dòng phụ đề, avatar
/// xám (không tone nào cả — không phải tiền, không phải AI, không phải của
/// riêng ai), và hành động duy nhất là nút "Chép" (bullet 1).
class _SystemTemplateCard extends StatelessWidget {
  const _SystemTemplateCard({required this.template, required this.onCopy});

  final Template template;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppGap.card),
        child: _TemplateHeader(
          avatar: const Avatar.icon(SoloIcons.file, tone: Tone.neutral),
          title: template.name,
          subtitle: 'Mẫu hệ thống · chỉ đọc',
          trailing: _CopyTemplateButton(
            templateName: template.name,
            onCopy: onCopy,
          ),
        ),
      ),
    );
  }
}

/// Nút "Chép" — figcaption gọi thẳng đây là một *nút*, nên phải có vùng chạm
/// 44pt thật sự. `StatusChip` tự nói không nên dùng làm nút bấm (không đủ
/// vùng chạm), nên chip chỉ để vẽ hình, còn vùng chạm và ngữ nghĩa nút nằm ở
/// đây.
class _CopyTemplateButton extends StatelessWidget {
  const _CopyTemplateButton({required this.templateName, required this.onCopy});

  final String templateName;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Chép mẫu ${templateName.toLowerCase()}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onCopy,
        child: const SizedBox(
          height: IconButtonBox.tapTarget,
          child: Center(child: StatusChip('Chép')),
        ),
      ),
    );
  }
}

/// Hàng avatar + hai dòng chữ, lặp ở cả ba thẻ mẫu của màn này — cùng hình
/// dáng `_TaskHeader` (MÀN 02) và `_LeadHeader` (MÀN 04).
///
/// Để private vì đây đã là lần dựng thứ ba của đúng bố cục này. Ghi vào báo
/// cáo cuối để cân nhắc nâng lên `lib/ui/`.
class _TemplateHeader extends StatelessWidget {
  const _TemplateHeader({
    required this.avatar,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final Widget avatar;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        avatar,
        const SizedBox(width: AppGap.row),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppText.bodyStrong),
              Text(subtitle, style: AppText.mut),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: AppGap.row), trailing!],
      ],
    );
  }
}

/// Cảnh báo mẫu đang mở thiếu điều khoản — bullet 3 của figcaption: tài liệu
/// cũ **không** bị sửa ngược khi mẫu thay đổi, message nói rõ điều đó.
///
/// Chỉ hiện lỗi đầu tiên (đúng cấu trúc "một `NoticeCard`" hiện có); nếu
/// [issues] rỗng thì không có gì để cảnh báo — trả `SizedBox.shrink()`.
class _StaleTemplateNotice extends StatelessWidget {
  const _StaleTemplateNotice({required this.issues});

  final List<TemplateLintIssue> issues;

  @override
  Widget build(BuildContext context) {
    if (issues.isEmpty) return const SizedBox.shrink();

    return NoticeCard(
      tone: Tone.warn,
      icon: SoloIcons.clock,
      message: issues.first.message,
    );
  }
}

/// Xem trước tài liệu của mẫu đang mở. Biến hiển thị bằng chip tím mono ngay
/// trong đoạn văn, đúng bullet 2 của figcaption.
///
/// [Template.previewExcerpt] trả `null` khi mẫu không đủ hai đoạn văn hoặc
/// đoạn thứ hai không có đủ hai biến — khi đó ẩn hẳn thẻ, không hiện rỗng.
class _TemplatePreviewCard extends StatelessWidget {
  const _TemplatePreviewCard({required this.template});

  final Template template;

  @override
  Widget build(BuildContext context) {
    final excerpt = template.previewExcerpt;
    if (excerpt == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppGap.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SectionLabel('Xem trước'),
            const SizedBox(height: AppGap.md),
            Text(template.docTitle, style: AppText.titleSm),
            const SizedBox(height: AppGap.sm),
            Text.rich(
              TextSpan(
                style: AppText.sub,
                children: [
                  TextSpan(text: excerpt.before),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: StatusChip(
                      '{{${excerpt.firstVariable}}}',
                      tone: Tone.ai,
                      mono: true,
                    ),
                  ),
                  TextSpan(text: excerpt.between),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: StatusChip(
                      '{{${excerpt.secondVariable}}}',
                      tone: Tone.ai,
                      mono: true,
                    ),
                  ),
                  TextSpan(text: excerpt.after),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
