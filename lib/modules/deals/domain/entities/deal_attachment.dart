import 'package:freezed_annotation/freezed_annotation.dart';

part 'deal_attachment.freezed.dart';

/// A file attached to a deal (brief, scanned contract, reference doc, ...).
///
/// No `url` field: the backend never exposes a direct link to the stored
/// object (`storage_key` stays server-side), so viewing/downloading always
/// goes through the authenticated `GET /deals/attachments/{id}/download`
/// endpoint instead of a plain image/link widget.
@freezed
abstract class DealAttachment with _$DealAttachment {
  const factory DealAttachment({
    required String id,
    required String dealId,
    required String filename,
    required String contentType,
    required int sizeBytes,
    // False means the PDF is a scanned image with no extractable text layer —
    // the AI qualification flow cannot read it. Surface this to the user
    // instead of implying every file was "read".
    required bool aiReadable,
    required DateTime createdAt,
  }) = _DealAttachment;
}
