import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/datasource/deal_attachments_remote_datasource.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  late _MockApiClient client;
  late DealAttachmentsRemoteDatasource datasource;

  setUp(() {
    client = _MockApiClient();
    datasource = DealAttachmentsRemoteDatasource(client);
  });

  Map<String, dynamic> attachmentJson(String id) => {
    'id': id,
    'deal_id': 'deal-1',
    'filename': 'brief.pdf',
    'content_type': 'application/pdf',
    'size_bytes': 2048,
    'ai_readable': true,
    'created_at': '2026-07-01T08:00:00Z',
  };

  Response<Map<String, dynamic>> resp(Map<String, dynamic> data) =>
      Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: ApiEndpoints.dealAttachments('deal-1')),
        data: {
          'success': true,
          'code': 200,
          'timestamp': '2026-07-01T08:00:00Z',
          ...data,
        },
      );

  test('listAttachments GETs /deals/{id}/attachments and parses the list', () async {
    when(
      () => client.get<Map<String, dynamic>>(any()),
    ).thenAnswer(
      (_) async => resp({
        'data': [attachmentJson('att-1'), attachmentJson('att-2')],
      }),
    );

    final items = await datasource.listAttachments('deal-1');

    expect(items, hasLength(2));
    verify(
      () => client.get<Map<String, dynamic>>(
        ApiEndpoints.dealAttachments('deal-1'),
      ),
    ).called(1);
  });

  test(
    'uploadAttachment POSTs multipart form data with field "file" to the '
    'deal-scoped path',
    () async {
      when(
        () => client.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => resp({'data': attachmentJson('att-1')}));

      final tempFile = await File(
        '${Directory.systemTemp.path}/deal_attachment_upload_test.pdf',
      ).create(recursive: true);
      await tempFile.writeAsBytes([1, 2, 3, 4]);
      addTearDown(() => tempFile.delete());

      final result = await datasource.uploadAttachment(
        dealId: 'deal-1',
        filePath: tempFile.path,
        filename: 'brief.pdf',
      );

      expect(result.id, 'att-1');

      final captured = verify(
        () => client.post<Map<String, dynamic>>(
          ApiEndpoints.dealAttachments('deal-1'),
          data: captureAny(named: 'data'),
          options: captureAny(named: 'options'),
        ),
      ).captured;
      final data = captured[0] as FormData;
      final options = captured[1] as Options;

      expect(data.files, hasLength(1));
      expect(data.files.single.key, 'file');
      expect(data.files.single.value.filename, 'brief.pdf');
      expect(options.contentType, 'multipart/form-data');
    },
  );

  test(
    'downloadAttachment GETs the flat /deals/attachments/{id}/download path '
    'as raw bytes',
    () async {
      when(
        () => client.get<List<int>>(any(), options: any(named: 'options')),
      ).thenAnswer(
        (_) async => Response<List<int>>(
          requestOptions: RequestOptions(path: 'x'),
          data: [1, 2, 3],
        ),
      );

      final bytes = await datasource.downloadAttachment('att-1');

      expect(bytes, [1, 2, 3]);
      final options =
          verify(
                () => client.get<List<int>>(
                  ApiEndpoints.dealAttachmentDownload('att-1'),
                  options: captureAny(named: 'options'),
                ),
              ).captured.single
              as Options;
      expect(options.responseType, ResponseType.bytes);
    },
  );

  test(
    'deleteAttachment DELETEs the flat /deals/attachments/{id} path '
    '(no deal_id segment)',
    () async {
      when(
        () => client.delete<void>(any()),
      ).thenAnswer(
        (_) async => Response<void>(requestOptions: RequestOptions(path: 'x')),
      );

      await datasource.deleteAttachment('att-1');

      verify(
        () => client.delete<void>(ApiEndpoints.dealAttachmentById('att-1')),
      ).called(1);
    },
  );
}
