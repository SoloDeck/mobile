import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/core/router/app_router.dart';
import 'package:solodesk_mobile/core/theme/app_theme.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';

class SoloDeskApp extends ConsumerWidget {
  const SoloDeskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
