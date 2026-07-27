import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/modules/projects/domain/entities/project.dart';
import 'package:solodesk_mobile/modules/projects/domain/value_objects/project_status.dart';
import 'package:solodesk_mobile/modules/projects/presentation/providers/projects_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/progress_bar.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// Tab "Dự án" — danh sách dự án.
///
/// **KHÔNG có trong `design/solodesk-mobile-ui.html`.** Bản phác thảo 15 màn
/// dựng MÀN 09 (task trong dự án) và MÀN 10 (kho bằng chứng), cả hai đều nhận
/// `projectId`, nhưng không dựng màn nào để *chọn* dự án — trong khi
/// `SoloNavBar` lại dành hẳn một tab cho "Dự án". Màn này lấp đúng khoảng trống
/// đó và không hơn: một danh sách, chạm vào là mở MÀN 09.
///
/// Vì không có bản phác thảo để đối chiếu, chỗ này cố ý dựng bằng những mảnh đã
/// có sẵn trong `lib/ui/` thay vì sáng tác bố cục mới. Khi bản phác thảo bổ
/// sung màn Dự án thật, thay nội dung ở đây theo nó.
///
/// Dữ liệu thật từ `projectListProvider` — màn này không có mảnh mock nào.
class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectListProvider);
    final appearance = ref.watch(appearanceControllerProvider);

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SoloAppBar(title: 'Dự án'),
              Expanded(
                child: AsyncValueWidget<List<Project>>(
                  value: projects,
                  onRetry: () => ref.invalidate(projectListProvider),
                  data: (list) => list.isEmpty
                      ? const _EmptyProjects()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppGap.screen,
                            0,
                            AppGap.screen,
                            AppGap.navBarInset,
                          ),
                          itemCount: list.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppGap.betweenCards),
                          itemBuilder: (_, i) => _ProjectCard(list[i]),
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

/// Một dự án trong danh sách.
///
/// `Card` chứ không phải `AccentCard`: mọi thẻ ở đây cùng một loại, vạch màu
/// mép trái sẽ không phân biệt được gì — đúng mục "KHÔNG dùng khi" trong doc
/// comment của `AccentCard`.
class _ProjectCard extends StatelessWidget {
  const _ProjectCard(this.project);

  final Project project;

  /// Tone theo trạng thái, cùng bảng màu với phần còn lại của app: ngọc là
  /// xong, hổ phách là đang dừng, còn lại trung tính. Không dùng `Tone.ai` —
  /// quy tắc 2 giữ màu tím cho riêng nội dung AI chờ duyệt.
  Tone get _tone => switch (project.status) {
    ProjectStatus.completed => Tone.ok,
    ProjectStatus.onHold => Tone.warn,
    ProjectStatus.planning || ProjectStatus.active => Tone.neutral,
  };

  @override
  Widget build(BuildContext context) {
    final total = project.taskCount;
    final done = project.doneCount;
    // Dự án chưa có task nào thì thanh tiến độ để trống thay vì chia cho 0.
    final ratio = total == 0 ? 0.0 : done / total;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/projects/${project.id}/tasks'),
        child: Padding(
          padding: const EdgeInsets.all(AppGap.card),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(project.name, style: AppText.bodyStrong),
                  ),
                  const SizedBox(width: AppGap.row),
                  StatusChip(project.status.label, tone: _tone),
                ],
              ),
              const SizedBox(height: AppGap.md),
              ProgressBar(value: ratio),
              const SizedBox(height: AppGap.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$done/$total task xong', style: AppText.mut),
                  const SoloIcon(
                    SoloIcons.chevron,
                    label: null,
                    size: SoloIcon.sm,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppGap.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SectionLabel('Chưa có dự án nào'),
            SizedBox(height: AppGap.md),
            Text(
              'Dự án được tạo khi bạn mở tab "Dự án" trên một thương vụ.',
              style: AppText.mut,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
