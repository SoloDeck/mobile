import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/tone.dart';

/// `ThemeData` của tầng giao diện SoloDesk, dựng từ bản phác thảo.
///
/// **Dùng khi:** khởi tạo `MaterialApp` cho các màn trong `lib/features/`, và
/// trong mọi golden test.
///
/// **KHÔNG dùng khi:** đang làm việc trong `lib/modules/` — tầng đó chạy theme
/// riêng ở `lib/core/theme/app_theme.dart`. Hai theme cố ý tách nhau, xem
/// `docs/adr/solodesk-ui-config-conflicts.md`.
///
/// `Card` và các nút đã được cấu hình sẵn ở đây, nên màn hình **không** bọc thêm
/// `Container` để đổi nền hay viền.
abstract final class AppTheme {
  /// Bản phác thảo chỉ có một chế độ sáng. Chưa thiết kế chế độ tối cho tầng này
  /// — MÀN 06 là một màn nền tối, không phải một theme tối.
  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: AppColors.ink,
      onPrimary: AppColors.surface,
      secondary: AppColors.ai,
      onSecondary: AppColors.surface,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.ink2,
      outline: AppColors.line,
      outlineVariant: AppColors.line,
      error: AppColors.momo,
      onError: AppColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.paper,
      fontFamily: AppFontFamily.body,
      splashFactory: InkSparkle.splashFactory,

      // `.card` — nền trắng, viền 1px, bo 18, không đổ bóng.
      // Padding không nằm trong CardTheme: bọc nội dung bằng
      // `Padding(padding: EdgeInsets.all(AppGap.card))`.
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardAll,
          side: const BorderSide(color: AppColors.line),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(style: filled()),
      outlinedButtonTheme: OutlinedButtonThemeData(style: outlined()),

      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),

      textTheme: const TextTheme(
        displayLarge: AppText.hero,
        headlineMedium: AppText.display,
        titleLarge: AppText.title,
        titleMedium: AppText.titleSm,
        bodyLarge: AppText.body,
        bodyMedium: AppText.sub,
        bodySmall: AppText.mut,
        labelLarge: AppText.button,
        labelSmall: AppText.label,
      ),
    );
  }

  /// Nút đặc `.btn`. [tone] đổi màu nền theo ngữ nghĩa:
  /// `Tone.solid` mực than (mặc định), `Tone.money` hồng, `Tone.ai` tím.
  ///
  /// [small] cho biến thể `.btn.sm` cao 38 — dùng khi nút nằm *trong* một thẻ,
  /// không phải khi muốn nút gọn hơn.
  static ButtonStyle filled({Tone tone = Tone.solid, bool small = false}) {
    return ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(tone.accent),
      foregroundColor: const WidgetStatePropertyAll(AppColors.surface),
      iconColor: const WidgetStatePropertyAll(AppColors.surface),
      elevation: const WidgetStatePropertyAll(0),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      textStyle: WidgetStatePropertyAll(
        small ? AppText.buttonSm : AppText.button,
      ),
      minimumSize: WidgetStatePropertyAll(Size(0, small ? 38 : 46)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: small ? AppGap.lg : AppGap.xl),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            small ? AppRadius.buttonSm : AppRadius.button,
          ),
        ),
      ),
    );
  }

  /// Nút viền `.btn.out` — lối phụ đứng cạnh một nút đặc.
  ///
  /// **KHÔNG** dùng làm hành động chính của màn: bản phác thảo luôn cho hành
  /// động chính một nút đặc.
  static ButtonStyle outlined({bool small = false}) {
    return ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      foregroundColor: const WidgetStatePropertyAll(AppColors.ink),
      iconColor: const WidgetStatePropertyAll(AppColors.ink),
      elevation: const WidgetStatePropertyAll(0),
      textStyle: WidgetStatePropertyAll(
        small ? AppText.buttonSm : AppText.button,
      ),
      minimumSize: WidgetStatePropertyAll(Size(0, small ? 38 : 46)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: small ? AppGap.lg : AppGap.xl),
      ),
      side: const WidgetStatePropertyAll(
        BorderSide(color: AppColors.ink, width: 1.5),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            small ? AppRadius.buttonSm : AppRadius.button,
          ),
        ),
      ),
    );
  }
}
