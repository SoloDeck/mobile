import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/templates/domain/entities/template.dart';
import 'package:solodesk_mobile/modules/templates/domain/value_objects/template_category.dart';
import 'package:solodesk_mobile/modules/templates/infrastructure/mapper/template_row_mapper.dart';
import 'package:solodesk_mobile/modules/templates/infrastructure/seed/system_template_seeds.dart';

class TemplatesLocalDatasource {
  const TemplatesLocalDatasource(this._database);

  final AppDatabase _database;

  /// Gieo 3 mẫu hệ thống nếu chưa có — dùng `insertIfAbsent`
  /// (`InsertMode.insertOrIgnore`) nên KHÔNG đè mẫu người dùng đã sửa tên/nội
  /// dung. Idempotent, gọi được nhiều lần an toàn.
  Future<void> ensureSeeded() =>
      _database.templateRowsDao.insertIfAbsent(systemTemplateSeeds);

  Future<List<Template>> listTemplates({TemplateCategory? category}) async {
    final rows = await _database.templateRowsDao.getAll();
    final templates = rows.map((row) => row.toDomain()).toList();
    if (category == null) return templates;
    return templates.where((t) => t.category == category).toList();
  }

  Future<Template?> getById(String id) async {
    final row = await _database.templateRowsDao.getById(id);
    return row?.toDomain();
  }

  Future<void> upsert(Template template) =>
      _database.templateRowsDao.upsertAll([template.toRow()]);

  Future<void> deleteById(String id) =>
      _database.templateRowsDao.deleteById(id);

  Future<void> setDefault(String id, TemplateCategory category) =>
      _database.templateRowsDao.setDefault(id, category.wireValue);
}
