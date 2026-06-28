import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/projects/infrastructure/dto/project_response_dto.dart';
import 'package:solodesk_mobile/modules/projects/infrastructure/mapper/project_mapper.dart';
import 'package:solodesk_mobile/modules/projects/domain/value_objects/project_status.dart';

void main() {
  group('ProjectResponseDtoMapper', () {
    test('maps ProjectResponseDto to Project entity correctly', () {
      const dto = ProjectResponseDto(
        id: 'p1',
        ownerId: 'owner-1',
        name: 'Website redesign',
        status: ProjectStatus.active,
        taskCount: 5,
        doneCount: 2,
        createdAt: '2026-06-14T08:00:00.000Z',
        dealId: 'deal-1',
        description: 'Thiết kế lại trang chủ',
        startDate: '2026-06-01',
        endDate: '2026-07-01',
        updatedAt: '2026-06-15T09:00:00.000Z',
      );

      final project = dto.toDomain();

      expect(project.id, 'p1');
      expect(project.ownerId, 'owner-1');
      expect(project.name, 'Website redesign');
      expect(project.status, ProjectStatus.active);
      expect(project.taskCount, 5);
      expect(project.doneCount, 2);
      expect(project.dealId, 'deal-1');
      expect(project.description, 'Thiết kế lại trang chủ');
      expect(project.startDate, DateTime.parse('2026-06-01'));
      expect(project.endDate, DateTime.parse('2026-07-01'));
      expect(project.createdAt, DateTime.parse('2026-06-14T08:00:00.000Z'));
      expect(project.updatedAt, DateTime.parse('2026-06-15T09:00:00.000Z'));
    });

    test('maps nullable deal_id correctly', () {
      const dto = ProjectResponseDto(
        id: 'p2',
        ownerId: 'owner-1',
        name: 'Standalone project',
        status: ProjectStatus.planning,
        createdAt: '2026-06-14T08:00:00.000Z',
        // dealId, dates, description, updatedAt all omitted (null)
      );

      final project = dto.toDomain();

      expect(project.dealId, isNull);
      expect(project.description, isNull);
      expect(project.startDate, isNull);
      expect(project.endDate, isNull);
      expect(project.updatedAt, isNull);
      // Defaults from the DTO when the backend omits counts.
      expect(project.taskCount, 0);
      expect(project.doneCount, 0);
    });

    test('parses status enum from wire JSON', () {
      final dto = ProjectResponseDto.fromJson({
        'id': 'p3',
        'owner_id': 'owner-1',
        'name': 'On hold project',
        'status': 'on_hold',
        'task_count': 3,
        'done_count': 1,
        'created_at': '2026-06-14T08:00:00.000Z',
        'deal_id': null,
      });

      final project = dto.toDomain();

      expect(project.status, ProjectStatus.onHold);
      expect(project.dealId, isNull);
    });
  });
}
