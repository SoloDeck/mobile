import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Table definitions
// ---------------------------------------------------------------------------

@DataClassName('ClientRow')
class ClientRows extends Table {
  @override
  String get tableName => 'clients';

  TextColumn get id => text()();
  TextColumn get ownerUserId => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get status => text()();
  IntColumn get dealCount => integer()();
  TextColumn get createdAt => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DealRow')
class DealRows extends Table {
  @override
  String get tableName => 'deals';

  TextColumn get id => text()();
  TextColumn get ownerUserId => text()();
  TextColumn get clientId => text()();
  TextColumn get title => text()();
  TextColumn get stage => text()();
  TextColumn get createdAt => text()();
  TextColumn get clientName => text().nullable()();
  TextColumn get source => text().nullable()();
  RealColumn get estimatedValue => real().nullable()();
  RealColumn get actualValue => real().nullable()();
  TextColumn get currency => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get closedAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ProjectRow')
class ProjectRows extends Table {
  @override
  String get tableName => 'projects';

  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get name => text()();
  TextColumn get status => text()();
  IntColumn get taskCount => integer()();
  IntColumn get doneCount => integer()();
  TextColumn get createdAt => text()();
  TextColumn get dealId => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get startDate => text().nullable()();
  TextColumn get endDate => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TaskRow')
class TaskRows extends Table {
  @override
  String get tableName => 'tasks';

  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get title => text()();
  TextColumn get priority => text()();
  TextColumn get status => text()();
  // Checklist items serialized as a JSON array string.
  TextColumn get checklistItems => text()();
  TextColumn get createdAt => text()();
  TextColumn get description => text().nullable()();
  TextColumn get deadline => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftAccessor(tables: [ClientRows])
class ClientRowsDao extends DatabaseAccessor<AppDatabase>
    with _$ClientRowsDaoMixin {
  ClientRowsDao(super.db);

  Future<List<ClientRow>> getAll() => select(clientRows).get();

  Future<void> upsertAll(Iterable<ClientRowsCompanion> rows) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(clientRows, rows.toList());
    });
  }
}

@DriftAccessor(tables: [DealRows])
class DealRowsDao extends DatabaseAccessor<AppDatabase>
    with _$DealRowsDaoMixin {
  DealRowsDao(super.db);

  Future<List<DealRow>> getAll() => select(dealRows).get();

  Future<void> upsertAll(Iterable<DealRowsCompanion> rows) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(dealRows, rows.toList());
    });
  }
}

@DriftAccessor(tables: [ProjectRows])
class ProjectRowsDao extends DatabaseAccessor<AppDatabase>
    with _$ProjectRowsDaoMixin {
  ProjectRowsDao(super.db);

  Future<List<ProjectRow>> getAll() => select(projectRows).get();

  Future<void> upsertAll(Iterable<ProjectRowsCompanion> rows) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(projectRows, rows.toList());
    });
  }
}

@DriftAccessor(tables: [TaskRows])
class TaskRowsDao extends DatabaseAccessor<AppDatabase>
    with _$TaskRowsDaoMixin {
  TaskRowsDao(super.db);

  Future<List<TaskRow>> getAll() => select(taskRows).get();

  Future<void> upsertAll(Iterable<TaskRowsCompanion> rows) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(taskRows, rows.toList());
    });
  }
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [ClientRows, DealRows, ProjectRows, TaskRows],
  daos: [ClientRowsDao, DealRowsDao, ProjectRowsDao, TaskRowsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(clientRows);
        await m.createTable(dealRows);
      }
      if (from < 3) {
        await m.createTable(projectRows);
        await m.createTable(taskRows);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'solodesk.db'));
    return NativeDatabase.createInBackground(file);
  });
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase(_openConnection());
  ref.onDispose(db.close);
  return db;
}
