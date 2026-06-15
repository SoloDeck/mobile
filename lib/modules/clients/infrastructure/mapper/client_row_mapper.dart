import 'package:drift/drift.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';

extension ClientRowMapper on ClientRow {
  Client toDomain() => Client(
    id: id,
    ownerUserId: ownerUserId,
    name: name,
    type: ClientType.values.byName(type),
    status: ClientStatus.values.byName(status),
    dealCount: dealCount,
    createdAt: DateTime.parse(createdAt),
    email: email,
    phone: phone,
    notes: notes,
    description: description,
    updatedAt: updatedAt == null ? null : DateTime.parse(updatedAt!),
  );
}

extension ClientToRowMapper on Client {
  ClientRowsCompanion toRow() => ClientRowsCompanion(
    id: Value(id),
    ownerUserId: Value(ownerUserId),
    name: Value(name),
    type: Value(type.name),
    status: Value(status.name),
    dealCount: Value(dealCount),
    createdAt: Value(createdAt.toIso8601String()),
    email: Value(email),
    phone: Value(phone),
    notes: Value(notes),
    description: Value(description),
    updatedAt: Value(updatedAt?.toIso8601String()),
  );
}
