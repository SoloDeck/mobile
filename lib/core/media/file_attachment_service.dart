import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_attachment_service.g.dart';

/// Bọc [FilePicker] để đính kèm một tệp bất kỳ (brief, hợp đồng scan, ...).
class FileAttachmentService {
  FileAttachmentService({FilePicker? filePicker})
    : _picker = filePicker ?? FilePicker.platform;

  final FilePicker _picker;

  Future<PlatformFile?> pickFile() async {
    final result = await _picker.pickFiles();
    if (result == null || result.files.isEmpty) return null;
    return result.files.first;
  }
}

@Riverpod(keepAlive: true)
FileAttachmentService fileAttachmentService(Ref ref) {
  return FileAttachmentService();
}
