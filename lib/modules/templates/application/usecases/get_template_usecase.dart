import 'package:solodesk_mobile/modules/templates/domain/entities/template.dart';
import 'package:solodesk_mobile/modules/templates/domain/repositories/templates_repository.dart';

class GetTemplateUseCase {
  const GetTemplateUseCase(this._repository);

  final TemplatesRepository _repository;

  Future<Template?> call(String id) => _repository.getTemplate(id);
}
