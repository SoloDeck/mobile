import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/value_objects/deal_activity_type.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/datasource/deal_activities_remote_datasource.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  late _MockApiClient client;
  late DealActivitiesRemoteDatasource datasource;

  setUp(() {
    client = _MockApiClient();
    datasource = DealActivitiesRemoteDatasource(client);
  });

  Response<Map<String, dynamic>> resp(Map<String, dynamic> data) =>
      Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: ApiEndpoints.dealActivities('deal-1')),
        data: {
          'success': true,
          'code': 200,
          'timestamp': '2026-07-01T08:00:00Z',
          ...data,
        },
      );

  test(
    'listActivities GETs the singular /activity path with pagination params',
    () async {
      when(
        () => client.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => resp({
          'data': [
            {
              'id': 'a1',
              'deal_id': 'deal-1',
              'entry_type': 'stage_change',
              'description': 'Stage changed: new_lead → qualified',
              'previous_stage': 'new_lead',
              'new_stage': 'qualified',
              'created_at': '2026-07-01T08:00:00Z',
            },
          ],
        }),
      );

      final items = await datasource.listActivities('deal-1', pageSize: 50);

      expect(items, hasLength(1));
      expect(items.single.entryType, DealActivityType.stageChange);
      expect(items.single.previousStage, DealStage.newLead);
      expect(items.single.newStage, DealStage.qualified);

      final params =
          verify(
                () => client.get<Map<String, dynamic>>(
                  ApiEndpoints.dealActivities('deal-1'),
                  queryParameters: captureAny(named: 'queryParameters'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(params['page'], 1);
      expect(params['page_size'], 50);
    },
  );

  test('parses entries with no stage transition (previous/new stage null)', () async {
    when(
      () => client.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => resp({
        'data': [
          {
            'id': 'a2',
            'deal_id': 'deal-1',
            'entry_type': 'document_attached',
            'description': 'Document attached: brief.pdf',
            'created_at': '2026-07-01T08:00:00Z',
          },
        ],
      }),
    );

    final items = await datasource.listActivities('deal-1');

    expect(items.single.entryType, DealActivityType.documentAttached);
    expect(items.single.previousStage, isNull);
    expect(items.single.newStage, isNull);
  });
}
