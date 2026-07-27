import 'package:solodesk_mobile/modules/templates/domain/repositories/templates_repository.dart';

class DeleteTemplateUseCase {
  const DeleteTemplateUseCase(this._repository);

  final TemplatesRepository _repository;

  Future<void> call(String id) => _repository.deleteTemplate(id);
}
