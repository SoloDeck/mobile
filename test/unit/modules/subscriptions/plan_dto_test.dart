import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/subscriptions/domain/entities/plan.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/dto/plan_dto.dart';
import 'package:solodesk_mobile/modules/subscriptions/infrastructure/mapper/subscription_mapper.dart';

/// JSON hợp lệ khớp `PlanResponse` backend — [maxClients] điều khiển được để
/// dựng cả hai kịch bản null / có giới hạn.
Map<String, dynamic> _planJson({required Object? maxClients}) => {
  'id': 'plan-1',
  'name': 'Pro',
  'slug': 'pro',
  'price_monthly': 149000,
  'price_yearly': 1287000,
  'currency': 'VND',
  'can_use_ai': true,
  'can_export_pdf': true,
  'max_clients': maxClients,
  'max_deals': 20,
  'max_ai_generations_per_month': 80,
};

void main() {
  group('decimalFromJson', () {
    test('accepts a JSON number', () {
      expect(decimalFromJson(149000), 149000.0);
    });

    test('accepts an integer-looking JSON string', () {
      expect(decimalFromJson('149000'), 149000.0);
    });

    test('accepts a decimal JSON string', () {
      expect(decimalFromJson('149000.00'), 149000.0);
    });
  });

  group('decimalOrZeroFromJson', () {
    test('missing/null price_yearly (backend cũ) parse thành 0, không nổ', () {
      final json = _planJson(maxClients: null)..remove('price_yearly');

      final plan = PlanDto.fromJson(json).toDomain();

      expect(plan.priceYearly, 0);
    });
  });

  group('PlanDto.fromJson -> toDomain (clientsLabel)', () {
    test(
      'max_clients null maps to Plan.maxClients null and "Không giới hạn"',
      () {
        final plan = PlanDto.fromJson(_planJson(maxClients: null)).toDomain();

        expect(plan.maxClients, isNull);
        expect(plan.clientsLabel, 'Không giới hạn');
      },
    );

    test('max_clients 5 maps to Plan.maxClients 5 and "5 khách"', () {
      final plan = PlanDto.fromJson(_planJson(maxClients: 5)).toDomain();

      expect(plan.maxClients, 5);
      expect(plan.clientsLabel, '5 khách');
    });
  });
}
