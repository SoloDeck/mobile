import 'package:solodesk_mobile/modules/subscriptions/domain/entities/subscription.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/repositories/subscriptions_repository.dart';

class GetMySubscriptionUseCase {
  const GetMySubscriptionUseCase(this._repository);

  final SubscriptionsRepository _repository;

  Future<Subscription> call() => _repository.getMySubscription();
}
