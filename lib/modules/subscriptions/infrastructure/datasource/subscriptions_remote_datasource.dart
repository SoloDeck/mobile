import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/dto/checkout_request_dto.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/dto/payment_intent_dto.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/dto/plan_dto.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/dto/subscription_dto.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';
import 'package:solodesk_mobile/shared/models/api_response.dart';

class SubscriptionsRemoteDatasource {
  const SubscriptionsRemoteDatasource(this._client);

  final ApiClient _client;

  /// `GET /subscriptions/plans` — public, không cần đăng nhập. Vẫn đi qua
  /// [_client] bình thường: nếu đã đăng nhập, `AuthInterceptor` tự gắn token
  /// nhưng backend không đòi hỏi. Không có `pagination` ở endpoint này.
  Future<List<PlanDto>> listPlans() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.subscriptionPlans,
    );
    final items = response.data!['data'] as List<dynamic>;
    return items
        .map((e) => PlanDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SubscriptionDto> getMySubscription() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.subscriptionMe,
    );
    return _unwrapSubscription(response.data!);
  }

  Future<PaymentIntentDto> createCheckout(CheckoutRequestDto dto) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.subscriptionCheckout,
      data: dto.toJson(),
    );
    return _unwrapPaymentIntent(response.data!);
  }

  /// `POST /subscriptions/cancel` — không có body, huỷ gia hạn ở cuối kỳ.
  Future<SubscriptionDto> cancelSubscription() async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.subscriptionCancel,
    );
    return _unwrapSubscription(response.data!);
  }

  Future<PaymentIntentDto> getPaymentIntent(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.paymentIntentById(id),
    );
    return _unwrapPaymentIntent(response.data!);
  }

  /// `POST /payments/intents/{id}/cancel` — không có body.
  Future<PaymentIntentDto> cancelPaymentIntent(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.paymentIntentCancel(id),
    );
    return _unwrapPaymentIntent(response.data!);
  }

  SubscriptionDto _unwrapSubscription(Map<String, dynamic> body) {
    final envelope = ApiResponse.fromJson(
      body,
      (json) => SubscriptionDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  PaymentIntentDto _unwrapPaymentIntent(Map<String, dynamic> body) {
    final envelope = ApiResponse.fromJson(
      body,
      (json) => PaymentIntentDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }
}
