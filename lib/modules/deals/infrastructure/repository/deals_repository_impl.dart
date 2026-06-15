import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deals_repository.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/datasource/deals_local_datasource.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/datasource/deals_remote_datasource.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/dto/create_deal_request_dto.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/dto/stage_transition_request_dto.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/mapper/deal_mapper.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

part 'deals_repository_impl.g.dart';

class DealsRepositoryImpl implements DealsRepository {
  const DealsRepositoryImpl(this._remote, this._local);

  final DealsRemoteDatasource _remote;
  final DealsLocalDatasource _local;

  @override
  Future<List<Deal>> listDeals({DealStage? stage}) async {
    try {
      final dtos = await _remote.listDeals(stage: stage);
      final deals = dtos.map((dto) => dto.toDomain()).toList();
      await _local.upsertDeals(deals);
      return deals;
    } on NetworkException {
      return _local.listDeals(stage: stage);
    }
  }

  @override
  Future<Deal> getDeal(String id) async {
    final dto = await _remote.getDeal(id);
    return dto.toDomain();
  }

  @override
  Future<Deal> createDeal({
    required String clientId,
    required String title,
    DealSource? source,
    double? estimatedValue,
    String? currency,
    String? notes,
  }) async {
    final dto = await _remote.createDeal(
      CreateDealRequestDto(
        clientId: clientId,
        title: title,
        source: source,
        estimatedValue: estimatedValue,
        currency: currency,
        notes: notes,
      ),
    );
    final deal = dto.toDomain();
    await _local.upsertDeals([deal]);
    return deal;
  }

  @override
  Future<Deal> transitionStage({
    required String id,
    required DealStage targetStage,
    String? note,
  }) async {
    final dto = await _remote.transitionStage(
      id,
      StageTransitionRequestDto(targetStage: targetStage, note: note),
    );
    final deal = dto.toDomain();
    await _local.upsertDeals([deal]);
    return deal;
  }
}

@Riverpod(keepAlive: true)
DealsRepository dealsRepository(Ref ref) {
  final client = ref.read(apiClientProvider);
  final database = ref.read(appDatabaseProvider);
  return DealsRepositoryImpl(
    DealsRemoteDatasource(client),
    DealsLocalDatasource(database),
  );
}
