import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_attachment_service.g.dart';

/// Signature of the underlying single-file picker call.
///
/// `file_picker` 11+ exposes [FilePicker] as an `abstract final class` with
/// only static methods, so it can no longer be subclassed or injected as an
/// instance. Tests inject a stub through this function seam instead.
typedef PickSingleFile = Future<PlatformFile?> Function();

/// Bọc [FilePicker] để đính kèm một tệp bất kỳ (brief, hợp đồng scan, ...).
class FileAttachmentService {
  FileAttachmentService({PickSingleFile? pickSingleFile})
    : _pickSingleFile = pickSingleFile ?? FilePicker.pickFile;

  final PickSingleFile _pickSingleFile;

  Future<PlatformFile?> pickFile() => _pickSingleFile();
}

@Riverpod(keepAlive: true)
FileAttachmentService fileAttachmentService(Ref ref) {
  return FileAttachmentService();
}
