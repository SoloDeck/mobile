import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal_content.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_status.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/datasource/proposals_local_datasource.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/datasource/proposals_remote_datasource.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/dto/proposal_request_dto.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/dto/proposal_response_dto.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/repository/proposals_repository_impl.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

/// Mock CHỈ remote datasource — local dùng Drift in-memory THẬT (đúng khuôn
/// `test/unit/core/database/migration_v4_v5_test.dart` /
/// `test/unit/modules/invoices/invoices_repository_impl_test.dart`).
class _MockRemote extends Mock implements ProposalsRemoteDatasource {}

ProposalResponseDto _dto(String id, {String dealId = 'deal-1'}) =>
    ProposalResponseDto(
      id: id,
      dealId: dealId,
      ownerUserId: 'owner-1',
      versionNumber: 1,
      status: 'draft',
      content: const <String, dynamic>{},
      aiGenerated: true,
      createdAt: '2026-07-01T08:00:00Z',
    );

Proposal _proposal({String id = 'p-1', String dealId = 'deal-1'}) => Proposal(
  id: id,
  dealId: dealId,
  ownerUserId: 'owner-1',
  versionNumber: 1,
  status: ProposalStatus.draft,
  content: const ProposalContent(),
  aiGenerated: true,
  createdAt: DateTime.utc(2026, 7, 1),
);

void main() {
  late AppDatabase database;
  late ProposalsLocalDatasource local;
  late _MockRemote remote;
  late ProposalsRepositoryImpl repository;

  setUpAll(() {
    // `updateProposalContent` dùng `captureAny()`/`any()` cho tham số
    // `ProposalRequestDto` (kiểu non-nullable) -> bắt buộc phải đăng ký giá
    // trị fallback.
    registerFallbackValue(
      const ProposalRequestDto(dealId: 'fallback', content: {}),
    );
  });

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    local = ProposalsLocalDatasource(database);
    remote = _MockRemote();
    repository = ProposalsRepositoryImpl(remote, local);
  });

  tearDown(() => database.close());

  test('listProposals trang 1 khi remote OK -> cache vào Drift, hasMore đúng '
      'theo page/totalPages', () async {
    when(
      () => remote.listProposals(
        status: any(named: 'status'),
        dealId: any(named: 'dealId'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      ),
    ).thenAnswer(
      (_) async => (items: [_dto('p-1'), _dto('p-2')], page: 1, totalPages: 3),
    );

    final page = await repository.listProposals();

    expect(page.items.map((p) => p.id), ['p-1', 'p-2']);
    expect(page.page, 1);
    expect(page.hasMore, isTrue); // 1 < 3

    final cached = await local.listProposals();
    expect(cached.map((p) => p.id).toSet(), {'p-1', 'p-2'});
  });

  test('listProposals trang 1 (page == totalPages) -> hasMore false', () async {
    when(
      () => remote.listProposals(
        status: any(named: 'status'),
        dealId: any(named: 'dealId'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      ),
    ).thenAnswer((_) async => (items: [_dto('p-1')], page: 1, totalPages: 1));

    final page = await repository.listProposals();

    expect(page.hasMore, isFalse);
  });

  test('listProposals trang 1 khi remote ném NetworkException -> đọc từ Drift '
      'cache, hasMore false', () async {
    await local.upsertProposals([_proposal(id: 'p-cached')]);
    when(
      () => remote.listProposals(
        status: any(named: 'status'),
        dealId: any(named: 'dealId'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      ),
    ).thenThrow(NetworkException.noConnection());

    final page = await repository.listProposals();

    expect(page.items.single.id, 'p-cached');
    expect(page.hasMore, isFalse);
  });

  test('listProposals trang 2 khi remote ném NetworkException -> RETHROW, '
      'không fallback', () async {
    when(
      () => remote.listProposals(
        status: any(named: 'status'),
        dealId: any(named: 'dealId'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      ),
    ).thenThrow(NetworkException.noConnection());

    expect(
      () => repository.listProposals(page: 2),
      throwsA(isA<NetworkException>()),
    );
  });

  test('updateProposalContent gửi request có đủ dealId và content.toMap() '
      'đầy đủ', () async {
    const content = ProposalContent(
      scopeOfWork: ['Logo', 'Brand guideline'],
      deliverables: ['File AI'],
      timeline: '01/07 → 31/07',
      paymentTerms: 'Cọc 50%, duyệt nháp 30%, bàn giao 20%',
    );
    when(
      () => remote.updateProposalContent(any(), any()),
    ).thenAnswer((_) async => _dto('p-1', dealId: 'deal-9'));

    await repository.updateProposalContent(
      id: 'p-1',
      dealId: 'deal-9',
      content: content,
    );

    final captured =
        verify(
              () => remote.updateProposalContent('p-1', captureAny()),
            ).captured.single
            as ProposalRequestDto;
    expect(captured.dealId, 'deal-9');
    expect(captured.content, content.toMap());
  });
}
