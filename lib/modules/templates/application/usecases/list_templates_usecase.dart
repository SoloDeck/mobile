import 'package:solodesk_mobile/modules/templates/domain/entities/template.dart';
import 'package:solodesk_mobile/modules/templates/domain/repositories/templates_repository.dart';
import 'package:solodesk_mobile/modules/templates/domain/value_objects/template_category.dart';

class ListTemplatesUseCase {
  const ListTemplatesUseCase(this._repository);

  final TemplatesRepository _repository;

  Future<List<Template>> call({TemplateCategory? category}) =>
      _repository.listTemplates(category: category);
}
