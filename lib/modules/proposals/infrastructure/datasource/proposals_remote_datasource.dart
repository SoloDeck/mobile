import 'package:dio/dio.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_status.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/dto/proposal_request_dto.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/dto/proposal_response_dto.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/dto/proposal_status_request_dto.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';
import 'package:solodesk_mobile/shared/models/api_response.dart';

/// Một trang DTO báo giá cùng cursor phân trang trả kèm.
typedef ProposalDtoPage = ({
  List<ProposalResponseDto> items,
  int page,
  int totalPages,
});

class ProposalsRemoteDatasource {
  const ProposalsRemoteDatasource(this._client);

  final ApiClient _client;

  Future<ProposalDtoPage> listProposals({
    ProposalStatus? status,
    String? dealId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.proposals,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (status != null) 'status': status.wireValue,
        'deal_id': ?dealId,
      },
    );
    final body = response.data!;
    final items = (body['data'] as List<dynamic>)
        .map((e) => ProposalResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = body['pagination'] as Map<String, dynamic>?;
    final currentPage = (pagination?['page'] as num?)?.toInt() ?? page;
    final totalPages =
        (pagination?['total_pages'] as num?)?.toInt() ?? currentPage;
    return (items: items, page: currentPage, totalPages: totalPages);
  }

  Future<ProposalResponseDto> getProposal(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.proposalById(id),
    );
    return _unwrap(response.data!);
  }

  Future<ProposalResponseDto> createProposal(ProposalRequestDto dto) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.proposals,
      data: dto.toJson(),
    );
    return _unwrap(response.data!);
  }

  Future<ProposalResponseDto> updateProposalContent(
    String id,
    ProposalRequestDto dto,
  ) async {
    final response = await _client.patch<Map<String, dynamic>>(
      ApiEndpoints.proposalById(id),
      data: dto.toJson(),
    );
    return _unwrap(response.data!);
  }

  Future<ProposalResponseDto> sendProposal(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.proposalSend(id),
    );
    return _unwrap(response.data!);
  }

  Future<ProposalResponseDto> transitionStatus(
    String id,
    ProposalStatusRequestDto dto,
  ) async {
    final response = await _client.patch<Map<String, dynamic>>(
      ApiEndpoints.proposalStatus(id),
      data: dto.toJson(),
    );
    return _unwrap(response.data!);
  }

  Future<ProposalResponseDto> generateContent(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.proposalGenerateContent(id),
    );
    return _unwrap(response.data!);
  }

  Future<ProposalResponseDto> generateFromDeal(String dealId) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.proposalGenerateFromDeal(dealId),
    );
    return _unwrap(response.data!);
  }

  /// Trả về bytes PDF thô. Đây là một stream file, KHÔNG có envelope
  /// `{success,code,timestamp,data}` như các endpoint khác nên không unwrap
  /// qua [ApiResponse].
  Future<List<int>> downloadPdf(String id) async {
    final response = await _client.get<List<int>>(
      ApiEndpoints.proposalPdf(id),
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data!;
  }

  Future<void> deleteProposal(String id) =>
      _client.delete<void>(ApiEndpoints.proposalById(id));

  ProposalResponseDto _unwrap(Map<String, dynamic> body) {
    final envelope = ApiResponse.fromJson(
      body,
      (json) => ProposalResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }
}
