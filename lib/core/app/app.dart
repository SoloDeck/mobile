import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/core/router/app_router.dart';
import 'package:solodesk_mobile/core/theme/app_theme.dart';
import 'package:solodesk_mobile/modules/auth/presentation/controllers/auth_controller.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';

class SoloDeskApp extends ConsumerStatefulWidget {
  const SoloDeskApp({super.key});

  @override
  ConsumerState<SoloDeskApp> createState() => _SoloDeskAppState();
}

class _SoloDeskAppState extends ConsumerState<SoloDeskApp> {
  @override
  void initState() {
    super.initState();
    // Token nằm trong secure storage sống qua các lần mở app, nhưng
    // `currentUserProvider` thì không — nó chỉ được nạp trong lần đăng nhập
    // thành công. Không gọi lại ở đây thì mở app bằng phiên cũ sẽ vào thẳng
    // trang chủ mà tab "Tôi" vẫn hiện "Chưa đăng nhập".
    //
    // `trySilentLogin` tự nuốt lỗi và trả `false` khi không khôi phục được, nên
    // không cần bọc thêm gì; router vẫn tự đá về `/login` khi hết token.
    //
    // `listenManual` chứ không phải `read` trần: `authControllerProvider` là
    // autoDispose, đọc suông thì nó bị huỷ ngay khi lời gọi trả về future, và
    // `ref.read` bên trong `_loadCurrentUser` ném lỗi trên một notifier đã
    // chết — lỗi đó rơi đúng vào `catch (_)` của `trySilentLogin` nên `/me` im
    // lặng không bao giờ được gọi. Subscription này giữ provider sống tới khi
    // widget bị bỏ — `listenManual` trong `ConsumerState` tự đóng theo widget
    // nên không cần giữ lại subscription để tự tay huỷ.
    ref.listenManual(authControllerProvider, (_, _) {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).trySilentLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final appearance = ref.watch(appearanceControllerProvider);

    return MaterialApp.router(
      title: 'SoloDesk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(
        brightness: Brightness.light,
        seed: appearance.accent.seed,
      ),
      darkTheme: AppTheme.build(
        brightness: Brightness.dark,
        seed: appearance.accent.seed,
      ),
      themeMode: appearance.mode,
      routerConfig: router,
    );
  }
}
