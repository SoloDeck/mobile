import 'package:solodesk_mobile/modules/templates/domain/entities/template.dart';
import 'package:solodesk_mobile/modules/templates/domain/value_objects/template_category.dart';

/// Contract cho thư viện mẫu tự quản, local-first bằng Drift. Implemented in
/// `infrastructure/repository/templates_repository_impl.dart`.
///
/// `ensureSeeded()` không nằm trong interface — là chi tiết triển khai của
/// `TemplatesRepositoryImpl`, tự chạy trước mỗi lần đọc.
abstract interface class TemplatesRepository {
  Future<List<Template>> listTemplates({TemplateCategory? category});

  Future<Template?> getTemplate(String id);

  Future<Template> copyTemplate(String sourceId);

  Future<void> setDefaultTemplate(String id);

  Future<void> deleteTemplate(String id);
}
