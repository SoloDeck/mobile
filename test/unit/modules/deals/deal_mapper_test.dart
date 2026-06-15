import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/dto/deal_response_dto.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/mapper/deal_mapper.dart';

void main() {
  group('DealResponseDto.toDomain', () {
    test('maps an API deal response to the domain entity', () {
      final dto = DealResponseDto.fromJson({
        'id': 'deal-1',
        'owner_user_id': 'owner-1',
        'client_id': 'client-1',
        'client_name': 'Công ty ABC',
        'title': 'Website bán hàng',
        'stage': 'qualified',
        'source': 'referral',
        'estimated_value': 15000000,
        'actual_value': null,
        'currency': 'VND',
        'notes': null,
        'created_at': '2026-06-14T08:00:00Z',
        'updated_at': '2026-06-15T08:00:00Z',
      });

      final deal = dto.toDomain();

      expect(deal.id, 'deal-1');
      expect(deal.clientId, 'client-1');
      expect(deal.clientName, 'Công ty ABC');
      expect(deal.stage, DealStage.qualified);
      expect(deal.source, DealSource.referral);
      expect(deal.estimatedValue, 15000000);
      expect(deal.currency, 'VND');
    });

    test('parses a Decimal money field sent as a JSON string', () {
      final dto = DealResponseDto.fromJson({
        'id': 'deal-2',
        'owner_user_id': 'owner-1',
        'client_id': 'client-1',
        'title': 'Thiết kế logo',
        'stage': 'new_lead',
        'estimated_value': '2500000.50',
        'created_at': '2026-06-14T08:00:00Z',
      });

      expect(dto.estimatedValue, 2500000.50);
      expect(dto.toDomain().estimatedValue, 2500000.50);
    });
  });
}
