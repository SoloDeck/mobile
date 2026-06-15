import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/repositories/deals_repository.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/datasource/deals_remote_datasource.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/dto/create_deal_request_dto.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/dto/stage_transition_request_dto.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/mapper/deal_mapper.dart';

part 'deals_repository_impl.g.dart';

class DealsRepositoryImpl implements DealsRepository {
  const DealsRepositoryImpl(this._remote);

  final DealsRemoteDatasource _remote;

  @override
  Future<List<Deal>> listDeals({DealStage? stage}) async {
    final dtos = await _remote.listDeals(stage: stage);
    return dtos.map((e) => e.toDomain()).toList();
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
    return dto.toDomain();
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
    return dto.toDomain();
  }
}

@Riverpod(keepAlive: true)
DealsRepository dealsRepository(Ref ref) {
  final client = ref.read(apiClientProvider);
  return DealsRepositoryImpl(DealsRemoteDatasource(client));
}
