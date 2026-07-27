import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/modules/auth/presentation/controllers/auth_controller.dart';
import 'package:solodesk_mobile/modules/settings/domain/value_objects/accent_preset.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/shared/widgets/logout_loading_overlay.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/ui/section_header.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceControllerProvider);
    final controller = ref.read(appearanceControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);
    final isLoggingOut = authState.isLoading;

    return Theme(
      data: AppTheme.light(),
      child: LogoutLoadingOverlay(
        isLoading: isLoggingOut,
        child: Scaffold(
          appBar: AppBar(title: const Text('Cài đặt')),
          body: ListView(
            padding: const EdgeInsets.all(AppGap.screen),
            children: [
              const SectionHeader('Giao diện'),
              const SizedBox(height: AppGap.sectionBottom),
              _ThemeModeSelector(
                mode: appearance.mode,
                onChanged: controller.setMode,
              ),
              const SizedBox(height: AppGap.sectionTop),
              const SectionHeader('Màu nhấn'),
              const SizedBox(height: AppGap.sectionBottom),
              _AccentSelector(
                selected: appearance.accent,
                onChanged: controller.setAccent,
              ),
              const SizedBox(height: AppGap.sectionTop),
              const Divider(),
              const SizedBox(height: AppGap.sm),
              _LogoutTile(isLoading: isLoggingOut),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends ConsumerWidget {
  const _LogoutTile({required this.isLoading});

  final bool isLoading;

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.logout_rounded, color: AppColors.ink),
      title: const Text(
        'Đăng xuất',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      onTap: isLoading ? null : () => _confirmLogout(context, ref),
    );
  }
}

// ── Theme-mode and accent selectors ─────────────────────────────────────────

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({required this.mode, required this.onChanged});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.system,
          label: Text('Hệ thống'),
          icon: Icon(Icons.brightness_auto_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          label: Text('Sáng'),
          icon: Icon(Icons.light_mode_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text('Tối'),
          icon: Icon(Icons.dark_mode_outlined),
        ),
      ],
      selected: {mode},
      showSelectedIcon: false,
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _AccentSelector extends StatelessWidget {
  const _AccentSelector({required this.selected, required this.onChanged});

  final AccentPreset selected;
  final ValueChanged<AccentPreset> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        for (final preset in AccentPreset.values)
          _AccentSwatch(
            preset: preset,
            isSelected: preset == selected,
            onTap: () => onChanged(preset),
          ),
      ],
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  final AccentPreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: isSelected,
      label: preset.label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: preset.seed,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: scheme.onSurface, width: 2)
                    : null,
              ),
              child: isSelected
                  ? const SoloIcon(SoloIcons.check, label: null, color: AppColors.surface)
                  : null,
            ),
            const SizedBox(height: AppGap.xs),
            Text(preset.label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
