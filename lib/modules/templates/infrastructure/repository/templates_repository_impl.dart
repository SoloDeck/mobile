import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/templates/domain/entities/template.dart';
import 'package:solodesk_mobile/modules/templates/domain/repositories/templates_repository.dart';
import 'package:solodesk_mobile/modules/templates/domain/value_objects/template_category.dart';
import 'package:solodesk_mobile/modules/templates/infrastructure/datasource/templates_local_datasource.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

part 'templates_repository_impl.g.dart';

class TemplatesRepositoryImpl implements TemplatesRepository {
  const TemplatesRepositoryImpl(this._local);

  final TemplatesLocalDatasource _local;

  @override
  Future<List<Template>> listTemplates({TemplateCategory? category}) async {
    await _local.ensureSeeded();
    return _local.listTemplates(category: category);
  }

  @override
  Future<Template?> getTemplate(String id) async {
    await _local.ensureSeeded();
    return _local.getById(id);
  }

  @override
  Future<Template> copyTemplate(String sourceId) async {
    final source = await _local.getById(sourceId);
    if (source == null) {
      throw const NotFoundException('Không tìm thấy mẫu để chép');
    }
    // Sinh id/thời điểm tạo cho bản ghi MỚI — không phải hiển thị thời gian
    // tương đối trên UI, nên không cần đi qua appClockProvider ở đây.
    final copy = Template(
      id: 'tpl-${DateTime.now().microsecondsSinceEpoch}',
      name: source.name,
      category: source.category,
      body: source.body,
      createdAt: DateTime.now(),
      sourceTemplateId: source.id,
    );
    await _local.upsert(copy);
    return copy;
  }

  @override
  Future<void> setDefaultTemplate(String id) async {
    final template = await _local.getById(id);
    if (template == null) {
      throw const NotFoundException('Không tìm thấy mẫu');
    }
    await _local.setDefault(id, template.category);
  }

  @override
  Future<void> deleteTemplate(String id) async {
    final template = await _local.getById(id);
    if (template == null) return;
    if (template.isSystem) {
      throw const ValidationException('Không thể xoá mẫu hệ thống');
    }
    await _local.deleteById(id);
  }
}

@Riverpod(keepAlive: true)
TemplatesRepository templatesRepository(Ref ref) {
  final database = ref.read(appDatabaseProvider);
  return TemplatesRepositoryImpl(TemplatesLocalDatasource(database));
}
