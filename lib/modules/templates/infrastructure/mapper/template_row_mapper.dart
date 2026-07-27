import 'package:drift/drift.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/templates/domain/entities/template.dart';
import 'package:solodesk_mobile/modules/templates/domain/value_objects/template_category.dart';

extension TemplateRowMapper on TemplateRow {
  Template toDomain() => Template(
    id: id,
    name: name,
    category: templateCategoryFromWire(category),
    body: body,
    isSystem: isSystem,
    isDefault: isDefault,
    sourceTemplateId: sourceTemplateId,
    createdAt: DateTime.parse(createdAt),
    updatedAt: updatedAt == null ? null : DateTime.parse(updatedAt!),
  );
}

extension TemplateToRowMapper on Template {
  TemplateRowsCompanion toRow() => TemplateRowsCompanion(
    id: Value(id),
    name: Value(name),
    category: Value(category.wireValue),
    body: Value(body),
    isSystem: Value(isSystem),
    isDefault: Value(isDefault),
    sourceTemplateId: Value(sourceTemplateId),
    createdAt: Value(createdAt.toIso8601String()),
    updatedAt: Value(updatedAt?.toIso8601String()),
  );
}
