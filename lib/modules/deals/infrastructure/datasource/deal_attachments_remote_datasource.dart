import 'package:dio/dio.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/dto/deal_attachment_response_dto.dart';
import 'package:solodesk_mobile/shared/api/api_endpoints.dart';
import 'package:solodesk_mobile/shared/models/api_response.dart';

class DealAttachmentsRemoteDatasource {
  const DealAttachmentsRemoteDatasource(this._client);

  final ApiClient _client;

  Future<List<DealAttachmentResponseDto>> listAttachments(
    String dealId,
  ) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.dealAttachments(dealId),
    );
    final items = response.data!['data'] as List<dynamic>;
    return items
        .map(
          (e) => DealAttachmentResponseDto.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<DealAttachmentResponseDto> uploadAttachment({
    required String dealId,
    required String filePath,
    required String filename,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: filename),
    });
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.dealAttachments(dealId),
      data: formData,
      // The shared Dio instance sets a fixed `application/json` base header;
      // it must be overridden per-request so this actually goes out as
      // `multipart/form-data; boundary=...`.
      options: Options(contentType: 'multipart/form-data'),
    );
    return _unwrap(response.data!);
  }

  /// Raw file bytes. This endpoint is not the usual JSON envelope — it's a
  /// binary stream (same shape as `proposals_remote_datasource.downloadPdf`).
  Future<List<int>> downloadAttachment(String attachmentId) async {
    final response = await _client.get<List<int>>(
      ApiEndpoints.dealAttachmentDownload(attachmentId),
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data!;
  }

  Future<void> deleteAttachment(String attachmentId) async {
    await _client.delete<void>(ApiEndpoints.dealAttachmentById(attachmentId));
  }

  DealAttachmentResponseDto _unwrap(Map<String, dynamic> body) {
    final envelope = ApiResponse.fromJson(
      body,
      (json) =>
          DealAttachmentResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }
}
