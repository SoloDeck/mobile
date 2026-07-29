import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/media/file_attachment_service.dart';
import 'package:solodesk_mobile/core/services/url_opener.dart';
import 'package:solodesk_mobile/modules/deals/application/usecases/delete_deal_attachment_usecase.dart';
import 'package:solodesk_mobile/modules/deals/application/usecases/download_deal_attachment_usecase.dart';
import 'package:solodesk_mobile/modules/deals/application/usecases/upload_deal_attachment_usecase.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal_attachment.dart';
import 'package:solodesk_mobile/modules/deals/infrastructure/repository/deal_attachments_repository_impl.dart';
import 'package:solodesk_mobile/modules/deals/presentation/providers/deal_attachments_provider.dart';

part 'deal_attachment_controller.g.dart';

/// Drives upload/delete from the "Tài liệu" tab. Keeps loading state so the
/// tab can disable itself mid-request; refreshes the list on success.
@riverpod
class DealAttachmentController extends _$DealAttachmentController {
  @override
  AsyncValue<DealAttachment?> build() => const AsyncValue.data(null);

  /// Opens the file picker; does nothing if the user cancels (no file
  /// chosen, or `PlatformFile.path` is null on web — desktop/mobile only).
  Future<void> pickAndUpload(String dealId) async {
    final picked = await ref.read(fileAttachmentServiceProvider).pickFile();
    final path = picked?.path;
    if (picked == null || path == null) return;

    state = const AsyncValue.loading();
    final useCase = UploadDealAttachmentUseCase(
      ref.read(dealAttachmentsRepositoryProvider),
    );
    state = await AsyncValue.guard(
      () => useCase(dealId: dealId, filePath: path, filename: picked.name),
    );
    if (state.hasValue && state.value != null) {
      ref.invalidate(dealAttachmentsProvider(dealId));
    }
  }

  Future<void> delete({
    required String dealId,
    required String attachmentId,
  }) async {
    state = const AsyncValue.loading();
    final useCase = DeleteDealAttachmentUseCase(
      ref.read(dealAttachmentsRepositoryProvider),
    );
    final result = await AsyncValue.guard(() async {
      await useCase(attachmentId);
      return null;
    });
    state = result;
    if (!result.hasError) {
      ref.invalidate(dealAttachmentsProvider(dealId));
    }
  }

  /// Downloads the file to a temp path then hands it to the platform to
  /// open. Returns the local path on success, null on failure.
  ///
  /// Known limitation: opening a bare `file://` URI via `UrlOpener` is not
  /// reliable on Android 7+ (`FileUriExposedException` under strict mode
  /// unless the receiving app is a FileProvider-aware viewer). This repo has
  /// no `open_filex`/`open_file` dependency yet — if manual testing shows
  /// this failing on-device, that package needs to be added (new dependency,
  /// needs confirmation) rather than working around it here.
  Future<String?> downloadAndOpen(DealAttachment attachment) async {
    final useCase = DownloadDealAttachmentUseCase(
      ref.read(dealAttachmentsRepositoryProvider),
    );
    final bytes = await useCase(attachment.id);
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, attachment.filename));
    await file.writeAsBytes(bytes, flush: true);
    final opened = await ref
        .read(urlOpenerProvider)
        .open(Uri.file(file.path).toString());
    return opened ? file.path : null;
  }
}
