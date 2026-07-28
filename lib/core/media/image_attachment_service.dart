import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_attachment_service.g.dart';

/// Bọc [ImagePicker] để đính kèm ảnh brief của khách hàng (chụp mới hoặc
/// chọn từ thư viện).
class ImageAttachmentService {
  ImageAttachmentService({
    ImagePicker? imagePicker,
    Future<bool> Function()? permissionRequester,
  }) : _picker = imagePicker ?? ImagePicker(),
       _permissionRequester =
           permissionRequester ?? _defaultPermissionRequester;

  final ImagePicker _picker;
  final Future<bool> Function() _permissionRequester;

  // iOS phân quyền thư viện ảnh qua Permission.photos; Android (và camera
  // trên mọi nền tảng) dùng Permission.camera cho luồng chụp ảnh.
  static Future<bool> _defaultPermissionRequester() async {
    final permission = Platform.isIOS ? Permission.photos : Permission.camera;
    final status = await permission.request();
    return status.isGranted;
  }

  Future<bool> requestPermission() => _permissionRequester();

  Future<XFile?> pickFromGallery() async {
    final granted = await requestPermission();
    if (!granted) return null;
    return _picker.pickImage(source: ImageSource.gallery);
  }

  Future<XFile?> pickFromCamera() async {
    final granted = await requestPermission();
    if (!granted) return null;
    return _picker.pickImage(source: ImageSource.camera);
  }
}

@Riverpod(keepAlive: true)
ImageAttachmentService imageAttachmentService(Ref ref) {
  return ImageAttachmentService();
}
