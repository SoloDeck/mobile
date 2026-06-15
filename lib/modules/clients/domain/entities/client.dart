import 'package:freezed_annotation/freezed_annotation.dart';

part 'client.freezed.dart';

enum ClientType {
  @JsonValue('individual')
  individual,
  @JsonValue('company')
  company,
}

enum ClientStatus {
  @JsonValue('prospect')
  prospect,
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('archived')
  archived,
}

/// A freelancer's client (khách hàng). Pure domain entity — fields mirror the
/// backend `ClientResponse` contract (`/clients`).
@freezed
abstract class Client with _$Client {
  const factory Client({
    required String id,
    required String ownerUserId,
    required String name,
    required ClientType type,
    required ClientStatus status,
    required int dealCount,
    required DateTime createdAt,
    String? email,
    String? phone,
    String? notes,
    String? description,
    DateTime? updatedAt,
  }) = _Client;
}
