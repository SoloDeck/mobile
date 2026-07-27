import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/payment_intent.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/plan.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/subscription.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/datasource/subscriptions_remote_datasource.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/dto/checkout_request_dto.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/mapper/subscription_mapper.dart';

part 'subscriptions_repository_impl.g.dart';

/// Module này KHÔNG có local datasource / cache Drift — xem docstring của
/// `SubscriptionsRepository` (domain) để rõ lý do: mua gói cần mạng, cache giá
/// cũ nguy hiểm hơn báo lỗi.
class SubscriptionsRepositoryImpl implements SubscriptionsRepository {
  const SubscriptionsRepositoryImpl(this._remote);

  final SubscriptionsRemoteDatasource _remote;

  @override
  Future<List<Plan>> listPlans() => _remote.listPlans().then(
    (dtos) => dtos.map((d) => d.toDomain()).toList(),
  );

  @override
  Future<Subscription> getMySubscription() =>
      _remote.getMySubscription().then((d) => d.toDomain());

  @override
  Future<PaymentIntent> createCheckout({
    required String planId,
    String? returnUrl,
  }) => _remote
      .createCheckout(CheckoutRequestDto(planId: planId, returnUrl: returnUrl))
      .then((d) => d.toDomain());

  @override
  Future<Subscription> cancelSubscription() =>
      _remote.cancelSubscription().then((d) => d.toDomain());

  @override
  Future<PaymentIntent> getPaymentIntent(String id) =>
      _remote.getPaymentIntent(id).then((d) => d.toDomain());

  @override
  Future<PaymentIntent> cancelPaymentIntent(String id) =>
      _remote.cancelPaymentIntent(id).then((d) => d.toDomain());
}

@Riverpod(keepAlive: true)
SubscriptionsRepository subscriptionsRepository(Ref ref) {
  final client = ref.read(apiClientProvider);
  return SubscriptionsRepositoryImpl(SubscriptionsRemoteDatasource(client));
}
