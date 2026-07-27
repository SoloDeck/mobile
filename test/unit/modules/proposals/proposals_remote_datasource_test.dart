import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/datasource/proposals_remote_datasource.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/dto/proposal_request_dto.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  late _MockApiClient client;
  late ProposalsRemoteDatasource datasource;

  setUp(() {
    client = _MockApiClient();
    datasource = ProposalsRemoteDatasource(client);
  });

  Map<String, dynamic> proposalJson(String id) => {
    'id': id,
    'deal_id': 'deal-1',
    'owner_user_id': 'owner-1',
    'version_number': 1,
    'status': 'draft',
    'content': <String, dynamic>{},
    'ai_generated': true,
    'created_at': '2026-07-01T08:00:00Z',
  };

  Response<Map<String, dynamic>> resp(Map<String, dynamic> data) =>
      Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: ApiEndpoints.proposals),
        data: {
          'success': true,
          'code': 200,
          'timestamp': '2026-07-01T08:00:00Z',
          ...data,
        },
      );

  test('listProposals parse đúng envelope phân trang', () async {
    when(
      () => client.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => resp({
        'data': [proposalJson('p-1'), proposalJson('p-2')],
        'pagination': {'page': 2, 'total_pages': 5},
      }),
    );

    final page = await datasource.listProposals(page: 2);

    expect(page.items, hasLength(2));
    expect(page.items.map((e) => e.id), ['p-1', 'p-2']);
    expect(page.page, 2);
    expect(page.totalPages, 5);
  });

  test(
    'getProposal unwrap đúng envelope object đơn {success,code,timestamp,data}',
    () async {
      when(
        () => client.get<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => resp({'data': proposalJson('p-1')}));

      final dto = await datasource.getProposal('p-1');

      expect(dto.id, 'p-1');
      expect(dto.dealId, 'deal-1');
      verify(
        () =>
            client.get<Map<String, dynamic>>(ApiEndpoints.proposalById('p-1')),
      ).called(1);
    },
  );

  test(
    'createProposal unwrap đúng envelope object đơn {success,code,timestamp,data}',
    () async {
      when(
        () =>
            client.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => resp({'data': proposalJson('p-1')}));

      final dto = await datasource.createProposal(
        const ProposalRequestDto(dealId: 'deal-1', content: {}),
      );

      expect(dto.id, 'p-1');
      verify(
        () => client.post<Map<String, dynamic>>(
          ApiEndpoints.proposals,
          data: any(named: 'data'),
        ),
      ).called(1);
    },
  );

  test(
    'downloadPdf trả về List<int> từ response bytes, KHÔNG unwrap qua ApiResponse',
    () async {
      when(
        () => client.get<List<int>>(any(), options: any(named: 'options')),
      ).thenAnswer(
        (_) async => Response<List<int>>(
          requestOptions: RequestOptions(path: ApiEndpoints.proposalPdf('p-1')),
          // Cố tình KHÔNG bọc theo envelope {success,code,timestamp,data} —
          // đây là bytes thô của file PDF.
          data: [1, 2, 3, 4],
        ),
      );

      final bytes = await datasource.downloadPdf('p-1');

      expect(bytes, [1, 2, 3, 4]);
      verify(
        () => client.get<List<int>>(
          ApiEndpoints.proposalPdf('p-1'),
          options: any(named: 'options'),
        ),
      ).called(1);
    },
  );
}
