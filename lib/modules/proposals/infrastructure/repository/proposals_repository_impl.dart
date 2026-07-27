import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal_content.dart';
import 'package:solodesk_mobile/modules/proposals/domain/repositories/proposals_repository.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_query.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_status.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/datasource/proposals_local_datasource.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/datasource/proposals_remote_datasource.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/dto/proposal_request_dto.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/dto/proposal_status_request_dto.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/mapper/proposal_mapper.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

part 'proposals_repository_impl.g.dart';

class ProposalsRepositoryImpl implements ProposalsRepository {
  const ProposalsRepositoryImpl(this._remote, this._local);

  final ProposalsRemoteDatasource _remote;
  final ProposalsLocalDatasource _local;

  @override
  Future<ProposalListPage> listProposals({
    ProposalListFilter filter = const ProposalListFilter(),
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final result = await _remote.listProposals(
        status: filter.status,
        dealId: filter.dealId,
        page: page,
        pageSize: pageSize,
      );
      final proposals = result.items.map((dto) => dto.toDomain()).toList();
      // Chỉ trang đầu tiên nạp lại cache ngoại tuyến — các trang sau chỉ nối
      // thêm vào danh sách đang hiển thị chứ không thay tập cache.
      if (page == 1) {
        await _local.upsertProposals(proposals);
      }
      return ProposalListPage(
        items: proposals,
        page: result.page,
        hasMore: result.page < result.totalPages,
      );
    } on NetworkException {
      // Trang sau (page > 1) không có gì để rơi về — ném lại lỗi.
      if (page > 1) rethrow;
      final cached = await _local.listProposals(filter: filter);
      return ProposalListPage(items: cached, page: 1, hasMore: false);
    }
  }

  @override
  Future<Proposal> getProposal(String id) async {
    final proposal = (await _remote.getProposal(id)).toDomain();
    await _local.upsertProposals([proposal]);
    return proposal;
  }

  @override
  Future<Proposal> createProposal({
    required String dealId,
    required ProposalContent content,
  }) async {
    final dto = await _remote.createProposal(
      ProposalRequestDto(dealId: dealId, content: content.toMap()),
    );
    final proposal = dto.toDomain();
    await _local.upsertProposals([proposal]);
    return proposal;
  }

  @override
  Future<Proposal> updateProposalContent({
    required String id,
    required String dealId,
    required ProposalContent content,
  }) async {
    // Backend bắt buộc PATCH phải gửi cả `deal_id` lẫn `content`, dù chỉ
    // `content` thật sự được áp dụng.
    final dto = await _remote.updateProposalContent(
      id,
      ProposalRequestDto(dealId: dealId, content: content.toMap()),
    );
    final proposal = dto.toDomain();
    await _local.upsertProposals([proposal]);
    return proposal;
  }

  @override
  Future<Proposal> sendProposal(String id) async {
    final proposal = (await _remote.sendProposal(id)).toDomain();
    await _local.upsertProposals([proposal]);
    return proposal;
  }

  @override
  Future<Proposal> transitionStatus({
    required String id,
    required ProposalStatus target,
  }) async {
    final dto = await _remote.transitionStatus(
      id,
      ProposalStatusRequestDto(status: target.wireValue),
    );
    final proposal = dto.toDomain();
    await _local.upsertProposals([proposal]);
    return proposal;
  }

  @override
  Future<Proposal> generateFromDeal(String dealId) async {
    // Đây là báo giá MỚI — chỉ cache chính nó, không đụng tới danh sách cũ.
    final proposal = (await _remote.generateFromDeal(dealId)).toDomain();
    await _local.upsertProposals([proposal]);
    return proposal;
  }

  @override
  Future<Proposal> regenerateContent(String id) async {
    // Chỉ là một lệnh gọi API thô — khôi phục 3 khoá riêng của mobile
    // (revision_rounds/valid_until/total) sau khi sinh lại là trách nhiệm của
    // `RegenerateProposalContentUseCase`, không phải của repository.
    final proposal = (await _remote.generateContent(id)).toDomain();
    await _local.upsertProposals([proposal]);
    return proposal;
  }

  @override
  Future<List<int>> downloadPdf(String id) => _remote.downloadPdf(id);

  @override
  Future<void> deleteProposal(String id) {
    // TODO: xoá luôn bản ghi khỏi Drift khi có yêu cầu đồng bộ chặt hơn — bản
    // này chấp nhận cache tạm thời chưa đồng bộ với server sau khi xoá.
    return _remote.deleteProposal(id);
  }
}

@Riverpod(keepAlive: true)
ProposalsRepository proposalsRepository(Ref ref) {
  final client = ref.read(apiClientProvider);
  final database = ref.read(appDatabaseProvider);
  return ProposalsRepositoryImpl(
    ProposalsRemoteDatasource(client),
    ProposalsLocalDatasource(database),
  );
}
