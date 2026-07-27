import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/projects/domain/entities/project.dart';
import 'package:solodesk_mobile/modules/projects/domain/repositories/projects_repository.dart';
import 'package:solodesk_mobile/modules/projects/domain/value_objects/project_status.dart';
import 'package:solodesk_mobile/modules/projects/infrastructure/repository/projects_repository_impl.dart';
import 'package:solodesk_mobile/modules/projects/presentation/pages/project_tasks_page.dart';
import 'package:solodesk_mobile/modules/tasks/domain/entities/checklist_item.dart';
import 'package:solodesk_mobile/modules/tasks/domain/entities/task.dart';
import 'package:solodesk_mobile/modules/tasks/domain/repositories/tasks_repository.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/priority.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_status.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/repository/tasks_repository_impl.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/filter_chip_bar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/progress_bar.dart';
import 'package:solodesk_mobile/ui/slip_card.dart';
import 'package:solodesk_mobile/ui/solo_nav_bar.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

import '../flutter_test_config.dart';

const _projectId = 'p1';

/// "Hôm nay" chốt tại lúc file này được nạp, dùng để suy ra mọi mốc thời gian
/// tương đối trong dữ liệu giả — tránh khoá cứng một ngày lịch cụ thể (chuỗi
/// "31/07" gốc), vì `ProjectTasksPage` giờ tính hạn từ `DateTime.now()` thật.
final DateTime _today = () {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}();

DateTime _daysFromToday(int days) => _today.add(Duration(days: days));

String _dayMonth(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}';

final DateTime _projectEndDate = _daysFromToday(6);
final DateTime _task1Deadline = _daysFromToday(-2);
final DateTime _task2Deadline = _daysFromToday(3);
final DateTime _task3Deadline = _daysFromToday(5);

final _project = Project(
  id: _projectId,
  ownerId: 'u1',
  name: 'Nhận diện Minh An',
  status: ProjectStatus.active,
  taskCount: 11,
  doneCount: 7,
  createdAt: DateTime.utc(2026, 1, 1),
  endDate: _projectEndDate,
);

final _tasks = <Task>[
  Task(
    id: 't1',
    entityType: TaskOwner.project,
    entityId: _projectId,
    title: 'Gửi bản nháp logo vòng 2',
    priority: Priority.high,
    status: TaskStatus.inProgress,
    createdAt: DateTime.utc(2026, 6, 1),
    deadline: _task1Deadline,
  ),
  Task(
    id: 't2',
    entityType: TaskOwner.project,
    entityId: _projectId,
    title: 'Dựng brand guideline 12 trang',
    priority: Priority.medium,
    status: TaskStatus.todo,
    createdAt: DateTime.utc(2026, 6, 2),
    deadline: _task2Deadline,
    checklistItems: [
      for (var i = 0; i < 8; i++)
        ChecklistItem(
          id: 'c$i',
          taskId: 't2',
          text: 'Mục $i',
          isDone: i < 3,
          position: i,
        ),
    ],
  ),
  Task(
    id: 't3',
    entityType: TaskOwner.project,
    entityId: _projectId,
    title: 'Xuất bộ social kit',
    priority: Priority.medium,
    status: TaskStatus.todo,
    createdAt: DateTime.utc(2026, 6, 3),
    deadline: _task3Deadline,
  ),
  Task(
    id: 't4',
    entityType: TaskOwner.project,
    entityId: _projectId,
    title: 'Chốt moodboard với khách',
    priority: Priority.low,
    status: TaskStatus.done,
    createdAt: DateTime.utc(2026, 6, 4),
  ),
  Task(
    id: 't5',
    entityType: TaskOwner.project,
    entityId: _projectId,
    title: 'Duyệt bản in card visit',
    priority: Priority.medium,
    status: TaskStatus.review,
    createdAt: DateTime.utc(2026, 6, 5),
  ),
];

class _FakeProjectsRepository implements ProjectsRepository {
  @override
  Future<Project> getProject(String id) async => _project;

  @override
  Future<List<Project>> listProjects({String? dealId, ProjectStatus? status}) =>
      Future.value([_project]);

  @override
  Future<Project> createProject({
    required String name,
    String? dealId,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
  }) async => _project;
}

class _FakeTasksRepository implements TasksRepository {
  @override
  Future<List<Task>> listByEntity({
    required TaskOwner entityType,
    required String entityId,
    TaskStatus? status,
  }) async => _tasks;

  @override
  Future<Task> getTask(String id) async => _tasks.firstWhere((t) => t.id == id);

  @override
  Future<Task> createTask({
    required TaskOwner entityType,
    required String entityId,
    required String title,
    String? description,
    Priority? priority,
    DateTime? deadline,
  }) async => _tasks.first;

  @override
  Future<Task> updateStatus({
    required String taskId,
    required TaskStatus status,
  }) async => _tasks.firstWhere((t) => t.id == taskId);
}

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        projectsRepositoryProvider.overrideWithValue(_FakeProjectsRepository()),
        tasksRepositoryProvider.overrideWithValue(_FakeTasksRepository()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const ProjectTasksPage(projectId: _projectId),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MÀN 09 — cấu trúc theo figcaption', () {
    testWidgets('bốn trạng thái task hiện thành chip lọc, không kéo thả', (
      tester,
    ) async {
      await _pump(tester);

      final bar = tester.widget<FilterChipBar>(find.byType(FilterChipBar));
      // Đếm suy ra từ danh sách task giả: 2 cần làm (t2, t3), 1 đang làm (t1),
      // 1 chờ duyệt (t5), 1 xong (t4) — không phải chép nguyên số của bản
      // phác thảo, vì số đó giờ tính từ `taskListProvider` thật.
      expect(bar.labels, [
        'Cần làm · 2',
        'Đang làm · 1',
        'Chờ duyệt · 1',
        'Xong',
      ]);
      expect(bar.selectedIndex, 0);
    });

    testWidgets('thanh tiến độ nằm trên, nhắc AI đặt ngay dưới nó', (
      tester,
    ) async {
      await _pump(tester);

      final progressTop = tester.getTopLeft(find.byType(ProgressBar)).dy;
      final aiIconTop = tester
          .getTopLeft(
            find.text(
              'Với nhịp hiện tại, dự án sẽ trễ khoảng 2 ngày. Cân nhắc dời '
              'vòng sửa thứ ba.',
            ),
          )
          .dy;
      expect(progressTop, lessThan(aiIconTop));

      final filterTop = tester.getTopLeft(find.byType(FilterChipBar)).dy;
      expect(aiIconTop, lessThan(filterTop));
    });

    testWidgets('năm task xếp dọc theo thứ tự trả về từ provider', (
      tester,
    ) async {
      await _pump(tester);

      final titles = [
        'Gửi bản nháp logo vòng 2',
        'Dựng brand guideline 12 trang',
        'Xuất bộ social kit',
        'Chốt moodboard với khách',
        'Duyệt bản in card visit',
      ];
      final tops = titles
          .map((title) => tester.getTopLeft(find.text(title)).dy)
          .toList();
      expect(tops, List.of(tops)..sort());
    });

    testWidgets('có hai nút nổi ở đáy màn: mic và dấu cộng', (tester) async {
      await _pump(tester);

      expect(find.bySemanticsLabel('Thêm task bằng giọng nói'), findsOneWidget);
      expect(find.bySemanticsLabel('Thêm task mới'), findsOneWidget);
    });

    testWidgets('màn này không có thanh tab đáy — mở từ trong một dự án', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.byType(SoloNavBar), findsNothing);
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

    testWidgets('nút thêm tuỳ chọn mở lối vào kho bằng chứng', (tester) async {
      await _pump(tester);
      await tester.tap(find.bySemanticsLabel('Thêm tuỳ chọn'));
      await tester.pumpAndSettle();
      expect(find.text('Kho bằng chứng bàn giao'), findsOneWidget);
    });
  });

  group('MÀN 09 — quy ước màu', () {
    testWidgets('task quá hạn dùng tone tiền cho chip và ô tick', (
      tester,
    ) async {
      await _pump(tester);

      final overdueLabel =
          'Trễ ${_today.difference(_task1Deadline).inDays} '
          'ngày';
      final overdueChip = tester.widget<StatusChip>(
        find.widgetWithText(StatusChip, overdueLabel),
      );
      expect(overdueChip.tone, Tone.money);
    });

    testWidgets('nhắc hạn bàn giao còn lại dùng tone hổ phách', (tester) async {
      await _pump(tester);

      final remainingLabel =
          'Còn ${_projectEndDate.difference(_today).inDays} ngày';
      final chip = tester.widget<StatusChip>(
        find.widgetWithText(StatusChip, remainingLabel),
      );
      expect(chip.tone, Tone.warn);
    });
  });

  group('MÀN 09 — chuỗi hiển thị', () {
    testWidgets('nguyên văn tiếng Việt và số suy ra từ dữ liệu giả', (
      tester,
    ) async {
      await _pump(tester);

      for (final text in [
        'Dự án',
        'Nhận diện Minh An',
        // `SectionLabel` tự in hoa — chép nguyên văn kết quả hiển thị.
        'TIẾN ĐỘ',
        '7/11 việc',
        'Bàn giao dự kiến ${_dayMonth(_projectEndDate)}',
        'Còn ${_projectEndDate.difference(_today).inDays} ngày',
        'Với nhịp hiện tại, dự án sẽ trễ khoảng 2 ngày. Cân nhắc dời '
            'vòng sửa thứ ba.',
        'Cần làm · 2',
        'Đang làm · 1',
        'Chờ duyệt · 1',
        // 'Xong' không kiểm ở đây: dải chip cuộn ngang, chip cuối có thể nằm
        // ngoài vùng build của ListView khi không có font thật để đo đúng bề
        // rộng. Đã kiểm nguyên văn của nó qua `FilterChipBar.labels` ở nhóm
        // "cấu trúc theo figcaption" bên trên.
        'Gửi bản nháp logo vòng 2',
        'Trễ ${_today.difference(_task1Deadline).inDays} ngày',
        'Ưu tiên cao',
        'Dựng brand guideline 12 trang',
        'Hạn ${_dayMonth(_task2Deadline)}',
        '3/8 mục',
        'Xuất bộ social kit',
        'Hạn ${_dayMonth(_task3Deadline)}',
        'Chốt moodboard với khách',
        'Duyệt bản in card visit',
      ]) {
        expect(find.text(text), findsWidgets, reason: 'thiếu chuỗi "$text"');
      }
    });
  });

  group('MÀN 09 — quy tắc không được vi phạm', () {
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

    testWidgets('không có SlipCard — màn này không phải nội dung tiền', (
      tester,
    ) async {
      await _pump(tester);
      // Nội dung màn không phải tờ phiếu tiền (quy tắc 3), nên không dùng
      // SlipCard ở bất kỳ đâu.
      expect(find.byType(SlipCard), findsNothing);
    });
  });

  testWidgets('ảnh vàng — màn 09 task trong dự án', (tester) async {
    await _pump(tester);
    await expectLater(
      find.byType(ProjectTasksPage),
      matchesGoldenFile('goldens/screen_09_project_tasks.png'),
    );
  }, skip: !soloFontsLoaded);
}
