import 'package:solodesk_mobile/modules/subscriptions/domain/entities/plan.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/repositories/subscriptions_repository.dart';

class ListPlansUseCase {
  const ListPlansUseCase(this._repository);

  final SubscriptionsRepository _repository;

  Future<List<Plan>> call() => _repository.listPlans();
}
