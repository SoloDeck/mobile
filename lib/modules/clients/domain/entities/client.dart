import 'package:freezed_annotation/freezed_annotation.dart';

part 'client.freezed.dart';
part 'client.g.dart';

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

@freezed
abstract class Client with _$Client {
  const factory Client({
    required String id,
    required String name,
    required ClientType type,
    required ClientStatus status,
    required DateTime createdAt,
    String? email,
    String? phone,
    String? companyName,
    String? website,
    List<String>? tags,
  }) = _Client;

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
}
