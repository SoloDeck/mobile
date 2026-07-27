import 'package:solodesk_mobile/modules/templates/domain/entities/template.dart';
import 'package:solodesk_mobile/modules/templates/domain/repositories/templates_repository.dart';

class CopyTemplateUseCase {
  const CopyTemplateUseCase(this._repository);

  final TemplatesRepository _repository;

  Future<Template> call(String sourceId) => _repository.copyTemplate(sourceId);
}
