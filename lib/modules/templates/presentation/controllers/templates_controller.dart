import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/templates/application/usecases/copy_template_usecase.dart';
import 'package:solodesk_mobile/modules/templates/application/usecases/delete_template_usecase.dart';
import 'package:solodesk_mobile/modules/templates/application/usecases/set_default_template_usecase.dart';
import 'package:solodesk_mobile/modules/templates/infrastructure/repository/templates_repository_impl.dart';
import 'package:solodesk_mobile/modules/templates/presentation/providers/templates_provider.dart';

part 'templates_controller.g.dart';

/// Điều khiển ba hành động ghi trên thư viện mẫu: chép, đặt mặc định, xoá.
/// Không giữ payload trả về (ba hành động có kiểu trả khác nhau: `Template`,
/// `void`, `void`) nên trạng thái chỉ là `AsyncValue<void>` — UI chỉ cần biết
/// đang chạy/thành công/lỗi, không cần đọc lại giá trị từ `state`. Thành công
/// thì làm mới `templatesProvider` để danh sách hiện đúng dữ liệu mới.
@riverpod
class TemplatesController extends _$TemplatesController {
  @override
  FutureOr<void> build() {}

  Future<void> copy(String sourceId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await CopyTemplateUseCase(ref.read(templatesRepositoryProvider))(
        sourceId,
      );
      ref.invalidate(templatesProvider);
    });
  }

  Future<void> setDefault(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await SetDefaultTemplateUseCase(ref.read(templatesRepositoryProvider))(
        id,
      );
      ref.invalidate(templatesProvider);
    });
  }

  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await DeleteTemplateUseCase(ref.read(templatesRepositoryProvider))(id);
      ref.invalidate(templatesProvider);
    });
  }
}
