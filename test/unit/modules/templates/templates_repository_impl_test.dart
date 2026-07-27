import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/templates/domain/value_objects/template_category.dart';
import 'package:solodesk_mobile/modules/templates/infrastructure/datasource/templates_local_datasource.dart';
import 'package:solodesk_mobile/modules/templates/infrastructure/repository/templates_repository_impl.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

/// Dùng Drift in-memory thật (không mock) — theo khuôn
/// `test/unit/core/database/migration_v4_v5_test.dart`. `templates` là kho
/// lưu trữ chính chứ không phải cache, nên hành vi seed/ghi đè phải được
/// kiểm bằng cơ sở dữ liệu thật.
void main() {
  late AppDatabase database;
  late TemplatesLocalDatasource local;
  late TemplatesRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    local = TemplatesLocalDatasource(database);
    repository = TemplatesRepositoryImpl(local);
  });

  tearDown(() => database.close());

  test(
    'ensureSeeded chạy hai lần vẫn đúng 3 dòng, không đè bản người dùng đã sửa',
    () async {
      final firstRun = await repository.listTemplates();
      expect(firstRun, hasLength(3));
      expect(firstRun.every((t) => t.isSystem), isTrue);

      final edited = firstRun
          .firstWhere((t) => t.id == 'sys-proposal-standard')
          .copyWith(name: 'Tên tôi tự sửa');
      await local.upsert(edited);

      final secondRun = await repository.listTemplates();
      expect(secondRun, hasLength(3));
      expect(
        secondRun.firstWhere((t) => t.id == 'sys-proposal-standard').name,
        'Tên tôi tự sửa',
      );
    },
  );

  test('copyTemplate tạo bản isSystem:false, sourceTemplateId trỏ về gốc, '
      'id khác gốc', () async {
    await repository.listTemplates(); // kích hoạt ensureSeeded ngầm
    final source = await repository.getTemplate('sys-proposal-standard');

    final copy = await repository.copyTemplate('sys-proposal-standard');

    expect(copy.id, isNot('sys-proposal-standard'));
    expect(copy.isSystem, isFalse);
    expect(copy.isDefault, isFalse);
    expect(copy.sourceTemplateId, 'sys-proposal-standard');
    expect(copy.category, TemplateCategory.proposal);
    expect(copy.name, source!.name);
    expect(copy.body, source.body);

    final persisted = await repository.getTemplate(copy.id);
    expect(persisted, isNotNull);
    expect(persisted!.sourceTemplateId, 'sys-proposal-standard');
  });

  test('copyTemplate với id không tồn tại ném NotFoundException', () async {
    await expectLater(
      repository.copyTemplate('does-not-exist'),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('setDefaultTemplate chỉ giữ một mặc định trong cùng category', () async {
    await repository.listTemplates(); // kích hoạt ensureSeeded ngầm

    final copy1 = await repository.copyTemplate('sys-proposal-standard');
    // Đảm bảo id sinh ra khác nhau dù dựa trên đồng hồ hệ thống.
    await Future<void>.delayed(const Duration(milliseconds: 2));
    final copy2 = await repository.copyTemplate('sys-proposal-standard');
    expect(copy1.id, isNot(copy2.id));

    await repository.setDefaultTemplate(copy1.id);
    var proposals = await repository.listTemplates(
      category: TemplateCategory.proposal,
    );
    expect(proposals.firstWhere((t) => t.id == copy1.id).isDefault, isTrue);
    expect(proposals.firstWhere((t) => t.id == copy2.id).isDefault, isFalse);

    await repository.setDefaultTemplate(copy2.id);
    proposals = await repository.listTemplates(
      category: TemplateCategory.proposal,
    );
    expect(proposals.firstWhere((t) => t.id == copy1.id).isDefault, isFalse);
    expect(proposals.firstWhere((t) => t.id == copy2.id).isDefault, isTrue);
  });

  test('deleteTemplate từ chối xoá mẫu hệ thống', () async {
    await repository.listTemplates(); // kích hoạt ensureSeeded ngầm

    await expectLater(
      repository.deleteTemplate('sys-proposal-standard'),
      throwsA(isA<ValidationException>()),
    );

    final stillThere = await repository.getTemplate('sys-proposal-standard');
    expect(stillThere, isNotNull);
  });

  test('deleteTemplate xoá được mẫu do người dùng tạo', () async {
    await repository.listTemplates(); // kích hoạt ensureSeeded ngầm
    final copy = await repository.copyTemplate('sys-proposal-standard');

    await repository.deleteTemplate(copy.id);

    expect(await repository.getTemplate(copy.id), isNull);
  });

  test('listTemplates lọc theo category đúng', () async {
    final proposals = await repository.listTemplates(
      category: TemplateCategory.proposal,
    );

    expect(proposals, hasLength(1));
    expect(proposals.single.id, 'sys-proposal-standard');
  });
}
