import 'package:solodesk_mobile/modules/templates/domain/repositories/templates_repository.dart';

class SetDefaultTemplateUseCase {
  const SetDefaultTemplateUseCase(this._repository);

  final TemplatesRepository _repository;

  Future<void> call(String id) => _repository.setDefaultTemplate(id);
}
