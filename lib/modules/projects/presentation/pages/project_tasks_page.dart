import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/modules/projects/domain/entities/project.dart';
import 'package:solodesk_mobile/modules/projects/presentation/providers/projects_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/modules/tasks/domain/entities/task.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/priority.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_status.dart';
import 'package:solodesk_mobile/modules/tasks/presentation/providers/tasks_provider.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';
import 'package:solodesk_mobile/shared/widgets/loading_shimmer.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/accent_card.dart';
import 'package:solodesk_mobile/ui/filter_chip_bar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/mono_text.dart';
import 'package:solodesk_mobile/ui/progress_bar.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// MÀN 09 — Task trong dự án.
///
/// Đối chiếu: khối `MÀN 09` trong `design/solodesk-mobile-ui.html`
/// (`<figure class="unit">` chứa appbar "Dự án / Nhận diện Minh An" tới danh
/// sách task và hai nút nổi).
///
/// Bốn quyết định trong figcaption, đừng đảo lại khi sửa:
/// - Kanban task cũng thành **chip lọc + danh sách dọc**, nhất quán với màn
///   Pipeline — dùng `FilterChipBar`, không kéo thả (quy tắc 4).
/// - Ô tick to **19pt**, nằm mép trái để đánh dấu xong bằng ngón cái khi đang
///   cầm máy một tay — `_TaskCheckbox` giữ đúng kích thước này thay vì co về
///   `Checkbox` mặc định của Material.
/// - Nhắc tiến độ do AI viết đặt **ngay dưới thanh phần trăm**, đúng chỗ người
///   dùng vừa nhìn — `_AiNudgeCard` nằm sát sau `_ProgressCard`, trước danh
///   sách task.
/// - Hai nút nổi: mic để **thêm task bằng giọng nói**, dấu cộng để gõ tay —
///   `_FloatingTaskButtons`, không gộp làm một nút.
///
/// Nối dữ liệu thật: [projectDetailProvider] cho thẻ tiến độ, [taskListProvider]
/// (họ theo `TaskOwner.project`) cho chip lọc và danh sách task. Nhắc AI ở
/// `_AiNudgeCard` vẫn là mock — không có field nào chứa nội dung này.
class ProjectTasksPage extends ConsumerWidget {
  const ProjectTasksPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectDetailProvider(projectId));
    final appearance = ref.watch(appearanceControllerProvider);

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          bottom: false,
          child: AsyncValueWidget<Project>(
            value: project,
            onRetry: () => ref.invalidate(projectDetailProvider(projectId)),
            data: (p) => _ProjectTasksBody(project: p),
          ),
        ),
      ),
    );
  }
}

/// Thân màn sau khi đã có dữ liệu dự án — tách riêng để `taskListProvider`
/// chỉ được `watch` một khi biết chắc `projectId` hợp lệ (đã tải xong dự án).
class _ProjectTasksBody extends ConsumerWidget {
  const _ProjectTasksBody({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksProvider = taskListProvider(TaskOwner.project, project.id);
    final tasks = ref.watch(tasksProvider);

    return Stack(
      children: [
        Column(
          children: [
            SoloAppBar(
              title: project.name,
              overline: 'Dự án',
              titleSize: SoloAppBar.sm,
              leading: IconButtonBox(
                SoloIcons.back,
                label: 'Quay lại',
                ghost: true,
                onTap: () => context.pop(),
              ),
              // Không `const` được ở đây: nút ba chấm mang closure mở bảng
              // tuỳ chọn. Các nhánh con khác vẫn giữ `const` từng cái.
              actions: [
                IconButtonBox(
                  SoloIcons.dots,
                  label: 'Thêm tuỳ chọn',
                  onTap: () => _showProjectMenu(context, project.id),
                ),
              ],
            ),
            Expanded(
              // SingleChildScrollView chứ không phải ListView: dựng hết
              // danh sách task một lượt để test tìm được nội dung dưới
              // màn dù màn có cuộn.
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppGap.screen,
                  0,
                  AppGap.screen,
                  AppGap.xxxl * 3,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProgressCard(project: project),
                    const SizedBox(height: AppGap.betweenCards),
                    const _AiNudgeCard(),
                    const SizedBox(height: AppGap.sectionTop),
                    AsyncValueWidget<List<Task>>(
                      value: tasks,
                      onRetry: () => ref.invalidate(tasksProvider),
                      // `LoadingShimmer` mặc định dựng `ListView`, đòi chiều
                      // cao hữu hạn — cột bọc ngoài nằm trong
                      // `SingleChildScrollView` nên cao vô hạn. Ép chiều cao
                      // cố định để chỉ chỗ này thoát lỗi "unbounded height".
                      loadingWidget: const SizedBox(
                        height: 240,
                        child: LoadingShimmer(),
                      ),
                      data: (list) => _TaskSection(tasks: list),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Positioned(
          bottom: AppGap.xxxl,
          right: AppGap.screen,
          child: _FloatingTaskButtons(),
        ),
      ],
    );
  }
}

/// Bảng tuỳ chọn của dự án, mở từ nút ba chấm trên thanh tiêu đề.
///
/// Đây là lối vào duy nhất của MÀN 10 — route `/projects/:id/evidence` đã đăng
/// ký từ lâu nhưng trước đó không widget nào push tới, nên kho bằng chứng bàn
/// giao chỉ mở được bằng cách gõ tay đường dẫn.
///
/// Dùng `showModalBottomSheet` chứ **không** dùng `PopupMenuButton` hay
/// `MenuAnchor`: hai thứ đó tự dựng lấy nút bấm của chúng, làm đổi hình dáng
/// thanh tiêu đề và kéo theo style Material lệch bản phác thảo. Sheet chỉ dựng
/// nội dung *khi mở*, nên cây widget mặc định của màn không đổi một widget nào
/// — ảnh vàng MÀN 09 giữ nguyên.
///
/// Cũng không dùng `DraggableScrollableSheet`: bảng chỉ có một mục, không có gì
/// để kéo, và màn này có quy tắc "không thành phần kéo thả nào".
Future<void> _showProjectMenu(BuildContext context, String projectId) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
    ),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppGap.screen,
        AppGap.sectionTop,
        AppGap.screen,
        AppGap.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SectionLabel('Tuỳ chọn dự án'),
          const SizedBox(height: AppGap.sectionBottom),
          InkWell(
            borderRadius: AppRadius.cardAll,
            // Đóng bảng trước rồi mới đẩy màn mới, để nút quay lại của MÀN 10
            // trả người dùng về đúng danh sách task chứ không về một bảng đang
            // mở dở.
            onTap: () {
              Navigator.pop(sheetContext);
              context.push('/projects/$projectId/evidence');
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppGap.card,
                vertical: AppGap.lg,
              ),
              child: Row(
                children: [
                  SoloIcon(SoloIcons.folder, label: null, size: SoloIcon.sm),
                  SizedBox(width: AppGap.row),
                  Expanded(
                    child: Text(
                      'Kho bằng chứng bàn giao',
                      style: AppText.bodyStrong,
                    ),
                  ),
                  SoloIcon(
                    SoloIcons.chevron,
                    label: null,
                    size: SoloIcon.xs,
                    color: AppColors.ink3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Định dạng `dd/MM`, dùng cho hạn bàn giao dự án và hạn của từng task.
String _formatDayMonth(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}';

/// Số ngày từ [from] tới [to], tính theo ngày lịch (bỏ giờ phút) để tránh lệch
/// một ngày do chênh múi giờ trong ngày.
int _dayDiff(DateTime from, DateTime to) {
  final a = DateTime(from.year, from.month, from.day);
  final b = DateTime(to.year, to.month, to.day);
  return b.difference(a).inDays;
}

/// Thẻ tiến độ trên cùng: tỉ lệ việc đã xong, thanh phần trăm, hạn bàn giao.
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final ratio = project.taskCount == 0
        ? 0.0
        : project.doneCount / project.taskCount;
    final endDate = project.endDate;
    final daysLeft = endDate == null ? null : _dayDiff(DateTime.now(), endDate);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppGap.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionLabel('Tiến độ'),
                MonoText('${project.doneCount}/${project.taskCount} việc'),
              ],
            ),
            const SizedBox(height: AppGap.md),
            // Nền chuyển sắc tím → hồng đúng như bản phác thảo — xem doc
            // comment của `ProgressBar.gradient`, chỉ MÀN 09 dùng biến thể này.
            ProgressBar(
              value: ratio,
              height: ProgressBar.thick,
              gradient: const LinearGradient(
                colors: [AppColors.ai, AppColors.momo],
              ),
            ),
            const SizedBox(height: AppGap.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    endDate == null
                        ? 'Chưa có hạn bàn giao'
                        : 'Bàn giao dự kiến ${_formatDayMonth(endDate)}',
                    style: AppText.mut,
                  ),
                ),
                if (daysLeft != null)
                  StatusChip(
                    daysLeft >= 0
                        ? 'Còn $daysLeft ngày'
                        : 'Trễ ${-daysLeft} ngày',
                    tone: Tone.warn,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Nhắc tiến độ do AI viết. Vạch tím vì là nội dung AI, nhưng chỉ để **đọc**
/// — không có nút gửi nào ở đây, không vi phạm quy tắc 5 vì chẳng có gì để
/// gửi ra ngoài cả, đây thuần là một nhận định hiển thị tại chỗ.
///
/// CHƯA NỐI API — `Project`/`Task` không có field nào chứa nhận định do AI
/// viết cho một dự án; giữ nguyên câu mẫu tới khi backend có endpoint này.
class _AiNudgeCard extends StatelessWidget {
  const _AiNudgeCard();

  @override
  Widget build(BuildContext context) {
    return const AccentCard(
      tone: Tone.ai,
      padding: EdgeInsets.symmetric(
        horizontal: AppGap.card,
        vertical: AppGap.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoloIcon(
            SoloIcons.ai,
            label: 'Gợi ý từ AI',
            size: SoloIcon.sm,
            color: AppColors.ai,
          ),
          SizedBox(width: AppGap.row),
          Expanded(child: Text(_MockData.aiNudge, style: AppText.sub)),
        ],
      ),
    );
  }
}

/// Chip lọc bốn trạng thái + danh sách task dọc bên dưới, cả hai cùng đọc từ
/// [tasks]. Dải chip là chỉ báo đếm, không lọc thật danh sách bên dưới —
/// nhất quán với bản phác thảo, đổi trạng thái từng task vẫn qua ô tick.
class _TaskSection extends StatelessWidget {
  const _TaskSection({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    int countOf(TaskStatus status) =>
        tasks.where((t) => t.status == status).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilterChipBar(
          labels: [
            'Cần làm · ${countOf(TaskStatus.todo)}',
            'Đang làm · ${countOf(TaskStatus.inProgress)}',
            'Chờ duyệt · ${countOf(TaskStatus.review)}',
            'Xong',
          ],
          selectedIndex: 0,
          // Cột đã có lề AppGap.screen từ SingleChildScrollView bên ngoài, đặt
          // thêm lề riêng ở đây sẽ nhân đôi khoảng cách.
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: AppGap.betweenCards),
        if (tasks.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppGap.xxl),
            child: Text(
              'Chưa có việc nào trong dự án này.',
              style: AppText.mut,
            ),
          )
        else
          for (var i = 0; i < tasks.length; i++) ...[
            if (i > 0) const SizedBox(height: AppGap.betweenCards),
            _TaskCard(task: tasks[i]),
          ],
      ],
    );
  }
}

/// Một dòng task: ô tick 19pt mép trái, tên việc, và các chip trạng thái phụ.
///
/// Không phải `AccentCard` — đây không phải danh sách "loại việc" như MÀN 02,
/// vạch màu ở đây chỉ đổi trên viền cả thẻ (task quá hạn), nên tự vẽ bằng
/// `DecoratedBox` giống cách `AccentCard` làm, thay vì bọc `Card` trong
/// `Container` để đổi viền (điều cấm trong `flutter-ui.md`).
///
/// Chip phụ suy ra thẳng từ [Task]: quá hạn ← `deadline` đã qua và chưa
/// `done`; "Ưu tiên cao" ← `priority`; "Hạn dd/MM" ← `deadline` còn hạn;
/// "x/y mục" ← `checklistItems`. Bản phác thảo còn có một biến thể chip đếm
/// file đính kèm ("2 file") — CHƯA NỐI API, `Task` không có field đính kèm
/// nên biến thể đó không có chỗ để bind, bỏ qua thay vì bịa dữ liệu.
class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final done = task.status == TaskStatus.done;
    final deadline = task.deadline;
    final overdue =
        !done && deadline != null && deadline.isBefore(DateTime.now());
    final checkboxTone = done ? Tone.ok : (overdue ? Tone.money : Tone.neutral);
    final borderColor = overdue ? AppColors.momoLine : null;

    final doneChecklist = task.checklistItems.where((c) => c.isDone).length;
    final totalChecklist = task.checklistItems.length;

    final chips = <Widget>[
      if (overdue)
        StatusChip(
          'Trễ ${_dayDiff(deadline, DateTime.now())} ngày',
          tone: Tone.money,
        ),
      if (task.priority == Priority.high) const StatusChip('Ưu tiên cao'),
      if (!overdue && deadline != null)
        StatusChip('Hạn ${_formatDayMonth(deadline)}'),
      if (totalChecklist > 0) StatusChip('$doneChecklist/$totalChecklist mục'),
    ];

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: borderColor ?? AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppGap.card),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TaskCheckbox(tone: checkboxTone, checked: done),
            const SizedBox(width: AppGap.row),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task.title,
                    style: done
                        ? AppText.bodyStrong.copyWith(
                            decoration: TextDecoration.lineThrough,
                          )
                        : AppText.bodyStrong,
                  ),
                  if (chips.isNotEmpty) ...[
                    const SizedBox(height: AppGap.sm),
                    Row(
                      children: [
                        for (var i = 0; i < chips.length; i++) ...[
                          if (i > 0) const SizedBox(width: AppGap.xs),
                          chips[i],
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return done ? Opacity(opacity: 0.55, child: card) : card;
  }
}

/// Ô tick riêng của màn task, to 19pt để bấm được bằng ngón cái — `IconButtonBox`
/// không hợp ở đây vì nó là ô vuông 38pt có nền, còn ô tick chỉ là viền mảnh.
class _TaskCheckbox extends StatelessWidget {
  const _TaskCheckbox({this.tone = Tone.neutral, this.checked = false});

  final Tone tone;
  final bool checked;

  static const double size = 19;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: checked ? 'Đã xong' : 'Chưa xong',
      child: checked
          ? Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: tone.accent,
                borderRadius: BorderRadius.circular(AppRadius.checkbox),
              ),
              child: const Center(
                child: SoloIcon(
                  SoloIcons.check,
                  label: null,
                  size: SoloIcon.xs,
                  color: AppColors.surface,
                  strokeWidth: 3,
                ),
              ),
            )
          : Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.checkbox),
                border: Border.all(
                  // Task trung tính dùng viền xám nhạt của thẻ; task quá hạn
                  // dùng màu đặc để nổi bật ngay, đúng bản phác thảo.
                  color: tone == Tone.neutral ? tone.border : tone.accent,
                  width: 2,
                ),
              ),
            ),
    );
  }
}

/// Hai nút nổi ở đáy màn: mic để ghi task bằng giọng nói, dấu cộng để gõ tay.
/// `IconButtonBox` cố ý không hợp ở đây — hình dáng nút nổi tròn khác nút icon
/// vuông trong appbar, xem doc comment của nó.
class _FloatingTaskButtons extends StatelessWidget {
  const _FloatingTaskButtons();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _VoiceCaptureButton(),
        SizedBox(width: AppGap.betweenButtons),
        _QuickAddButton(),
      ],
    );
  }
}

/// Nút mic phụ — nền trắng, viền xám, cạnh 46pt, bo góc riêng không khớp bán
/// kính nào trong `AppRadius` nên đặt hằng số cục bộ, giống cách `IconButtonBox`
/// và `SoloNavBar` tự khai riêng kích thước của chúng.
class _VoiceCaptureButton extends StatelessWidget {
  const _VoiceCaptureButton();

  static const double _size = 46;
  static const double _radius = 15;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Thêm task bằng giọng nói',
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.35),
              offset: const Offset(0, 8),
              blurRadius: 20,
              spreadRadius: -8,
            ),
          ],
        ),
        child: const Center(
          child: SoloIcon(SoloIcons.mic, label: null, color: AppColors.ink),
        ),
      ),
    );
  }
}

/// Nút dấu cộng chính — cùng hình dáng với nút nổi giữa `SoloNavBar`
/// (`AppRadius.fab`), chỉ khác cạnh 52pt vì đứng một mình, không nằm giữa
/// thanh tab.
class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton();

  static const double _size = 52;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Thêm task mới',
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(AppRadius.fab),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.72),
              offset: const Offset(0, 10),
              blurRadius: 22,
              spreadRadius: -8,
            ),
          ],
        ),
        child: const Center(
          child: SoloIcon(
            SoloIcons.plus,
            label: null,
            size: 24,
            color: AppColors.surface,
          ),
        ),
      ),
    );
  }
}

/// Dữ liệu chưa có nguồn API — xem doc comment tại từng chỗ dùng.
abstract final class _MockData {
  static const String aiNudge =
      'Với nhịp hiện tại, dự án sẽ trễ khoảng 2 ngày. Cân nhắc dời '
      'vòng sửa thứ ba.';
}
