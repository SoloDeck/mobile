import 'package:solodesk_mobile/modules/subscriptions/domain/entities/payment_intent.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/plan.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/subscription.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/payment_intent_status.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/value_objects/subscription_status.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/dto/payment_intent_dto.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/dto/payment_link_dto.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/dto/plan_dto.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/dto/subscription_dto.dart';

extension PlanDtoMapper on PlanDto {
  Plan toDomain() => Plan(
    id: id,
    name: name,
    slug: slug,
    priceMonthly: priceMonthly,
    priceYearly: priceYearly,
    currency: currency,
    canUseAi: canUseAi,
    canExportPdf: canExportPdf,
    maxClients: maxClients,
    maxDeals: maxDeals,
    maxAiGenerationsPerMonth: maxAiGenerationsPerMonth,
  );
}

extension SubscriptionDtoMapper on SubscriptionDto {
  Subscription toDomain() => Subscription(
    id: id,
    userId: userId,
    planId: planId,
    planName: planName,
    planSlug: planSlug,
    status: subscriptionStatusFromWire(status),
    currentPeriodStart: DateTime.parse(currentPeriodStart),
    currentPeriodEnd: DateTime.parse(currentPeriodEnd),
    cancelAtPeriodEnd: cancelAtPeriodEnd,
  );
}

extension PaymentLinkDtoMapper on PaymentLinkDto {
  PaymentLink toDomain() => PaymentLink(
    type: type,
    url: url,
    qrCodeUrl: qrCodeUrl,
    instructions: instructions,
  );
}

extension PaymentIntentDtoMapper on PaymentIntentDto {
  PaymentIntent toDomain() => PaymentIntent(
    id: id,
    subscriptionId: subscriptionId,
    planId: planId,
    provider: provider,
    status: paymentIntentStatusFromWire(status),
    amount: amount,
    currency: currency,
    paymentLink: paymentLink.toDomain(),
    providerReference: providerReference,
    paidAt: paidAt == null ? null : DateTime.parse(paidAt!),
    expiresAt: DateTime.parse(expiresAt),
    failureReason: failureReason,
  );
}
