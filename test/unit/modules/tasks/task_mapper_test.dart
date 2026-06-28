import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/dto/task_response_dto.dart';
import 'package:solodesk_mobile/modules/tasks/infrastructure/mapper/task_mapper.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/priority.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_owner.dart';
import 'package:solodesk_mobile/modules/tasks/domain/value_objects/task_status.dart';

void main() {
  group('TaskResponseDtoMapper', () {
    test('maps TaskResponseDto with checklist_items to Task entity', () {
      final dto = TaskResponseDto.fromJson({
        'id': 't1',
        'entity_type': 'project',
        'entity_id': 'p1',
        'title': 'Viết tài liệu',
        'priority': 'high',
        'status': 'in_progress',
        'deadline': '2026-06-20T10:00:00.000Z',
        'created_at': '2026-06-14T08:00:00.000Z',
        'updated_at': '2026-06-15T09:00:00.000Z',
        'description': 'Mô tả công việc',
        'checklist_items': [
          {
            'id': 'c1',
            'task_id': 't1',
            'text': 'Phần mở đầu',
            'is_done': true,
            'position': 0,
          },
          {
            'id': 'c2',
            'task_id': 't1',
            'text': 'Phần kết luận',
            'is_done': false,
            'position': 1,
          },
        ],
      });

      final task = dto.toDomain();

      expect(task.id, 't1');
      expect(task.entityType, TaskOwner.project);
      expect(task.entityId, 'p1');
      expect(task.title, 'Viết tài liệu');
      expect(task.priority, Priority.high);
      expect(task.status, TaskStatus.inProgress);
      expect(task.deadline, DateTime.parse('2026-06-20T10:00:00.000Z'));
      expect(task.description, 'Mô tả công việc');
      expect(task.checklistItems, hasLength(2));
      expect(task.checklistItems.first.id, 'c1');
      expect(task.checklistItems.first.text, 'Phần mở đầu');
      expect(task.checklistItems.first.isDone, isTrue);
      expect(task.checklistItems[1].position, 1);
      expect(task.checklistItems[1].isDone, isFalse);
    });

    test('defaults checklist_items to empty when omitted', () {
      final dto = TaskResponseDto.fromJson({
        'id': 't2',
        'entity_type': 'deal',
        'entity_id': 'd1',
        'title': 'Gọi khách',
        'priority': 'low',
        'status': 'todo',
        'created_at': '2026-06-14T08:00:00.000Z',
      });

      final task = dto.toDomain();

      expect(task.checklistItems, isEmpty);
      expect(task.deadline, isNull);
      expect(task.description, isNull);
      expect(task.entityType, TaskOwner.deal);
    });

    test('TaskOwner enum maps correctly from string', () {
      expect(TaskOwnerX.fromWire('project'), TaskOwner.project);
      expect(TaskOwnerX.fromWire('deal'), TaskOwner.deal);
      expect(TaskOwnerX.fromWire('reminder'), TaskOwner.reminder);
      expect(TaskOwner.project.wireValue, 'project');
      expect(TaskOwner.deal.wireValue, 'deal');
      expect(TaskOwner.reminder.wireValue, 'reminder');
      expect(() => TaskOwnerX.fromWire('unknown'), throwsArgumentError);
    });
  });
}
