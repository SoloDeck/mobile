import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';

/// Ba bảng thêm ở schema v5 (`proposals`, `reminders`, `templates`) phải tồn
/// tại ngay khi mở cơ sở dữ liệu. `templates` là kho lưu trữ chính chứ không
/// phải cache — không có endpoint nào để đồng bộ lại nếu bảng thiếu.
void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('schemaVersion là 5', () {
    expect(database.schemaVersion, 5);
  });

  test('ba bảng mới tồn tại và rỗng', () async {
    expect(await database.proposalRowsDao.getAll(), isEmpty);
    expect(await database.reminderRowsDao.getAll(), isEmpty);
    expect(await database.templateRowsDao.getAll(), isEmpty);
  });

  test('năm bảng cũ vẫn còn nguyên', () async {
    expect(await database.clientRowsDao.getAll(), isEmpty);
    expect(await database.dealRowsDao.getAll(), isEmpty);
    expect(await database.projectRowsDao.getAll(), isEmpty);
    expect(await database.taskRowsDao.getAll(), isEmpty);
    expect(await database.invoiceRowsDao.getAll(), isEmpty);
  });

  test('replaceAll của reminders xoá dòng cũ thay vì gộp thêm', () async {
    await database.reminderRowsDao.replaceAll([
      _reminder('r-1'),
      _reminder('r-2'),
    ]);
    await database.reminderRowsDao.replaceAll([_reminder('r-3')]);

    final rows = await database.reminderRowsDao.getAll();
    expect(rows.map((r) => r.id), ['r-3']);
  });

  test('insertIfAbsent không đè lên mẫu người dùng đã sửa', () async {
    await database.templateRowsDao.insertIfAbsent([
      _template('sys-1', name: 'Báo giá tiêu chuẩn'),
    ]);
    await database.templateRowsDao.upsertAll([
      _template('sys-1', name: 'Tên tôi tự đặt'),
    ]);
    // Lần gieo thứ hai — mô phỏng lần mở app sau.
    await database.templateRowsDao.insertIfAbsent([
      _template('sys-1', name: 'Báo giá tiêu chuẩn'),
    ]);

    final rows = await database.templateRowsDao.getAll();
    expect(rows, hasLength(1));
    expect(rows.single.name, 'Tên tôi tự đặt');
  });

  test('setDefault chỉ giữ một mẫu mặc định trong cùng một loại', () async {
    await database.templateRowsDao.upsertAll([
      _template('t-1', category: 'proposal', isDefault: true),
      _template('t-2', category: 'proposal'),
      _template('t-3', category: 'contract', isDefault: true),
    ]);

    await database.templateRowsDao.setDefault('t-2', 'proposal');

    final rows = await database.templateRowsDao.getAll();
    final defaults = rows.where((r) => r.isDefault).map((r) => r.id).toList()
      ..sort();
    // `t-3` khác loại nên không bị đụng tới.
    expect(defaults, ['t-2', 't-3']);
  });

  test('setDefault bỏ qua id không thuộc loại được truyền', () async {
    await database.templateRowsDao.upsertAll([
      _template('t-1', category: 'proposal', isDefault: true),
      _template('t-3', category: 'contract'),
    ]);

    await database.templateRowsDao.setDefault('t-3', 'proposal');

    final rows = await database.templateRowsDao.getAll();
    expect(rows.where((r) => r.isDefault), isEmpty);
  });
}

ReminderRowsCompanion _reminder(String id) => ReminderRowsCompanion.insert(
  id: id,
  ownerUserId: 'u-1',
  targetType: 'invoice',
  targetId: 'inv-1',
  reminderType: 'payment_due',
  channel: 'both',
  status: 'pending',
  scheduledAt: '2026-07-25T09:00:00Z',
  createdAt: '2026-07-25T08:00:00Z',
);

TemplateRowsCompanion _template(
  String id, {
  String name = 'Mẫu',
  String category = 'proposal',
  bool isDefault = false,
}) => TemplateRowsCompanion.insert(
  id: id,
  name: name,
  category: category,
  body: 'Xin chào {{client_name}}',
  isDefault: Value(isDefault),
  createdAt: '2026-07-01T00:00:00Z',
);
