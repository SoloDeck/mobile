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

@DataClassName('InvoiceRow')
class InvoiceRows extends Table {
  @override
  String get tableName => 'invoices';

  TextColumn get id => text()();
  TextColumn get invoiceNumber => text()();
  TextColumn get status => text()();
  TextColumn get dueDate => text()();
  RealColumn get total => real()();
  RealColumn get amountOutstanding => real()();
  TextColumn get clientName => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ProposalRow')
class ProposalRows extends Table {
  @override
  String get tableName => 'proposals';

  TextColumn get id => text()();
  TextColumn get dealId => text()();
  TextColumn get ownerUserId => text()();
  IntColumn get versionNumber => integer()();
  TextColumn get status => text()();

  /// `content` phía backend là JSONB tự do — lưu nguyên chuỗi JSON, không tách
  /// cột, để phiên bản app sau không làm mất khoá lạ.
  TextColumn get contentJson => text()();
  BoolColumn get aiGenerated => boolean().withDefault(const Constant(false))();
  TextColumn get createdAt => text()();

  /// Ghép từ thương vụ để danh sách ngoại tuyến còn đọc được tên khách.
  TextColumn get clientName => text().nullable()();
  TextColumn get shareToken => text().nullable()();
  TextColumn get shareExpiresAt => text().nullable()();
  TextColumn get sentAt => text().nullable()();
  TextColumn get respondedAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ReminderRow')
class ReminderRows extends Table {
  @override
  String get tableName => 'reminders';

  TextColumn get id => text()();
  TextColumn get ownerUserId => text()();
  TextColumn get targetType => text()();
  TextColumn get targetId => text()();
  TextColumn get reminderType => text()();
  TextColumn get channel => text()();
  TextColumn get status => text()();
  TextColumn get scheduledAt => text()();
  TextColumn get messagePreview => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Kho lưu trữ chính của thư viện mẫu — **không phải cache**.
///
/// Backend không có module templates (chỉ có `/admin/templates` dành cho
/// quản trị viên, freelancer gọi bị 403), nên đây là nơi duy nhất chứa mẫu của
/// người dùng. Mất bảng này là mất công sức người dùng: không hàm nào được
/// xoá sạch nó.
@DataClassName('TemplateRow')
class TemplateRows extends Table {
  @override
  String get tableName => 'templates';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();

  /// Biến `{{...}}` được suy ra khi đọc, không lưu cột riêng.
  TextColumn get body => text()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  TextColumn get sourceTemplateId => text().nullable()();
  TextColumn get createdAt => text()();
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

@DriftAccessor(tables: [InvoiceRows])
class InvoiceRowsDao extends DatabaseAccessor<AppDatabase>
    with _$InvoiceRowsDaoMixin {
  InvoiceRowsDao(super.db);

  Future<List<InvoiceRow>> getAll() => select(invoiceRows).get();

  Future<void> upsertAll(Iterable<InvoiceRowsCompanion> rows) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(invoiceRows, rows.toList());
    });
  }
}

@DriftAccessor(tables: [ProposalRows])
class ProposalRowsDao extends DatabaseAccessor<AppDatabase>
    with _$ProposalRowsDaoMixin {
  ProposalRowsDao(super.db);

  Future<List<ProposalRow>> getAll() => select(proposalRows).get();

  Future<void> upsertAll(Iterable<ProposalRowsCompanion> rows) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(proposalRows, rows.toList());
    });
  }
}

@DriftAccessor(tables: [ReminderRows])
class ReminderRowsDao extends DatabaseAccessor<AppDatabase>
    with _$ReminderRowsDaoMixin {
  ReminderRowsDao(super.db);

  Future<List<ReminderRow>> getAll() => select(reminderRows).get();

  Future<void> upsertAll(Iterable<ReminderRowsCompanion> rows) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(reminderRows, rows.toList());
    });
  }

  /// `GET /reminders` trả về **toàn bộ** tập dữ liệu chứ không phân trang, nên
  /// cách đồng bộ đúng là thay sạch. Nếu chỉ upsert thì nhắc hẹn đã bị huỷ ở
  /// máy chủ sẽ nằm lại trong cache mãi.
  Future<void> replaceAll(Iterable<ReminderRowsCompanion> rows) async {
    await transaction(() async {
      await delete(reminderRows).go();
      await batch((batch) {
        batch.insertAll(reminderRows, rows.toList());
      });
    });
  }
}

@DriftAccessor(tables: [TemplateRows])
class TemplateRowsDao extends DatabaseAccessor<AppDatabase>
    with _$TemplateRowsDaoMixin {
  TemplateRowsDao(super.db);

  Future<List<TemplateRow>> getAll() => select(templateRows).get();

  Future<TemplateRow?> getById(String id) =>
      (select(templateRows)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertAll(Iterable<TemplateRowsCompanion> rows) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(templateRows, rows.toList());
    });
  }

  /// Gieo mẫu hệ thống mà không đè lên bản người dùng đã sửa.
  Future<void> insertIfAbsent(Iterable<TemplateRowsCompanion> rows) async {
    await batch((batch) {
      batch.insertAll(
        templateRows,
        rows.toList(),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  Future<void> deleteById(String id) async {
    await (delete(templateRows)..where((t) => t.id.equals(id))).go();
  }

  /// Đặt mẫu mặc định cho một loại — mỗi loại chỉ được có đúng một mẫu mặc định.
  Future<void> setDefault(String id, String category) async {
    await transaction(() async {
      await (update(templateRows)..where((t) => t.category.equals(category)))
          .write(const TemplateRowsCompanion(isDefault: Value(false)));
      // Chốt cả `category` để một id lạc loại không thể trở thành mặc định
      // của loại khác.
      await (update(templateRows)
            ..where((t) => t.id.equals(id) & t.category.equals(category)))
          .write(const TemplateRowsCompanion(isDefault: Value(true)));
    });
  }
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [
    ClientRows,
    DealRows,
    ProjectRows,
    TaskRows,
    InvoiceRows,
    ProposalRows,
    ReminderRows,
    TemplateRows,
  ],
  daos: [
    ClientRowsDao,
    DealRowsDao,
    ProjectRowsDao,
    TaskRowsDao,
    InvoiceRowsDao,
    ProposalRowsDao,
    ReminderRowsDao,
    TemplateRowsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 5;

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
      if (from < 4) {
        await m.createTable(invoiceRows);
      }
      if (from < 5) {
        await m.createTable(proposalRows);
        await m.createTable(reminderRows);
        await m.createTable(templateRows);
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
