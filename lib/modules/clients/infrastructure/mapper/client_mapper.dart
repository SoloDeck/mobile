import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/infrastructure/dto/client_response_dto.dart';

extension ClientResponseDtoMapper on ClientResponseDto {
  Client toDomain() => Client(
    id: id,
    ownerUserId: ownerUserId,
    name: name,
    type: type,
    status: status,
    dealCount: dealCount,
    createdAt: DateTime.parse(createdAt),
    email: email,
    phone: phone,
    notes: notes,
    description: description,
    updatedAt: updatedAt == null ? null : DateTime.parse(updatedAt!),
  );
}
