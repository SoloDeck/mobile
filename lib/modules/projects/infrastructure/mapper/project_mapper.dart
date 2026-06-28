import 'package:solodesk_mobile/modules/projects/domain/entities/project.dart';
import 'package:solodesk_mobile/modules/projects/infrastructure/dto/project_response_dto.dart';

DateTime? _parseDate(String? value) =>
    value == null ? null : DateTime.parse(value);

extension ProjectResponseDtoMapper on ProjectResponseDto {
  Project toDomain() => Project(
    id: id,
    ownerId: ownerId,
    name: name,
    status: status,
    taskCount: taskCount,
    doneCount: doneCount,
    createdAt: DateTime.parse(createdAt),
    dealId: dealId,
    description: description,
    startDate: _parseDate(startDate),
    endDate: _parseDate(endDate),
    updatedAt: _parseDate(updatedAt),
  );
}
