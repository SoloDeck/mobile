import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/dto/client_response_dto.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/mapper/client_mapper.dart';

void main() {
  group('ClientResponseDto.toDomain', () {
    test('maps an API client response to the domain entity', () {
      final dto = ClientResponseDto.fromJson({
        'id': 'client-1',
        'owner_user_id': 'owner-1',
        'name': 'Công ty ABC',
        'type': 'company',
        'status': 'active',
        'deal_count': 3,
        'email': 'lienhe@abc.vn',
        'phone': '0900000000',
        'notes': 'Khách quen',
        'description': null,
        'created_at': '2026-06-14T08:00:00Z',
        'updated_at': '2026-06-15T09:30:00Z',
      });

      final client = dto.toDomain();

      expect(client.id, 'client-1');
      expect(client.ownerUserId, 'owner-1');
      expect(client.name, 'Công ty ABC');
      expect(client.type, ClientType.company);
      expect(client.status, ClientStatus.active);
      expect(client.dealCount, 3);
      expect(client.email, 'lienhe@abc.vn');
      expect(client.phone, '0900000000');
      expect(client.notes, 'Khách quen');
      expect(client.description, isNull);
      expect(client.createdAt, DateTime.utc(2026, 6, 14, 8));
      expect(client.updatedAt, DateTime.utc(2026, 6, 15, 9, 30));
    });

    test('defaults deal_count to 0 when absent', () {
      final dto = ClientResponseDto.fromJson({
        'id': 'client-2',
        'owner_user_id': 'owner-1',
        'name': 'Anh Tú',
        'type': 'individual',
        'status': 'prospect',
        'created_at': '2026-06-14T08:00:00Z',
      });

      final client = dto.toDomain();

      expect(client.dealCount, 0);
      expect(client.type, ClientType.individual);
      expect(client.status, ClientStatus.prospect);
      expect(client.updatedAt, isNull);
    });
  });
}
