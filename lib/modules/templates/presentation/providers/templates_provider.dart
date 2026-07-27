import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/templates/application/usecases/get_template_usecase.dart';
import 'package:solodesk_mobile/modules/templates/application/usecases/list_templates_usecase.dart';
import 'package:solodesk_mobile/modules/templates/domain/entities/template.dart';
import 'package:solodesk_mobile/modules/templates/domain/value_objects/template_category.dart';
import 'package:solodesk_mobile/modules/templates/infrastructure/repository/templates_repository_impl.dart';

part 'templates_provider.g.dart';

/// Toàn bộ mẫu (hệ thống + tự tạo) trong thư viện tự quản, lọc theo
/// [category] khi truyền vào — `null` trả về cả ba loại.
@riverpod
Future<List<Template>> templates(Ref ref, TemplateCategory? category) {
  final useCase = ListTemplatesUseCase(ref.watch(templatesRepositoryProvider));
  return useCase(category: category);
}

/// Một mẫu theo [id] — dùng khi mở riêng một thẻ mẫu.
@riverpod
Future<Template?> templateDetail(Ref ref, String id) {
  final useCase = GetTemplateUseCase(ref.watch(templatesRepositoryProvider));
  return useCase(id);
}
