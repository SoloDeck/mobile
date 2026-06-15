import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/datasource/deals_local_datasource.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/datasource/deals_remote_datasource.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/dto/deal_response_dto.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/repository/deals_repository_impl.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

class _MockDealsRemoteDatasource extends Mock
    implements DealsRemoteDatasource {}

Deal _deal({String title = 'Cached deal'}) => Deal(
  id: 'deal-1',
  ownerUserId: 'owner-1',
  clientId: 'client-1',
  title: title,
  stage: DealStage.qualified,
  createdAt: DateTime.utc(2026, 6, 14),
  clientName: 'Client One',
  source: DealSource.referral,
  estimatedValue: 1000,
  currency: 'VND',
  updatedAt: DateTime.utc(2026, 6, 15),
);

DealResponseDto _dealDto({String title = 'Remote deal'}) => DealResponseDto(
  id: 'deal-1',
  ownerUserId: 'owner-1',
  clientId: 'client-1',
  title: title,
  stage: DealStage.qualified,
  createdAt: '2026-06-14T00:00:00.000Z',
  clientName: 'Client One',
  source: DealSource.referral,
  estimatedValue: 2500,
  currency: 'VND',
  updatedAt: '2026-06-15T00:00:00.000Z',
);

void main() {
  late AppDatabase database;
  late DealsLocalDatasource local;
  late _MockDealsRemoteDatasource remote;
  late DealsRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    local = DealsLocalDatasource(database);
    remote = _MockDealsRemoteDatasource();
    repository = DealsRepositoryImpl(remote, local);
  });

  tearDown(() => database.close());

  test('listDeals returns cached deals when remote is offline', () async {
    await local.upsertDeals([_deal()]);
    when(
      () => remote.listDeals(stage: null),
    ).thenThrow(NetworkException.noConnection());

    final result = await repository.listDeals();

    expect(result, [_deal()]);
  });

  test('successful listDeals refresh upserts remote deals', () async {
    await local.upsertDeals([_deal(title: 'Stale deal')]);
    when(
      () => remote.listDeals(stage: null),
    ).thenAnswer((_) async => [_dealDto()]);

    final result = await repository.listDeals();
    final cached = await local.listDeals();

    expect(result.single.title, 'Remote deal');
    expect(cached, hasLength(1));
    expect(cached.single.title, 'Remote deal');
    expect(cached.single.estimatedValue, 2500);
  });
}
