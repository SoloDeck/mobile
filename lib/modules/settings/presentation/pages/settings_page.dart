import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/modules/auth/presentation/controllers/auth_controller.dart';
import 'package:solodesk_mobile/modules/settings/domain/value_objects/accent_preset.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/shared/widgets/logout_loading_overlay.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceControllerProvider);
    final controller = ref.read(appearanceControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);
    final isLoggingOut = authState.isLoading;

    return LogoutLoadingOverlay(
      isLoading: isLoggingOut,
      child: Scaffold(
        appBar: AppBar(title: const Text('Cài đặt')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionHeader(label: 'Giao diện'),
            const SizedBox(height: 12),
            _ThemeModeSelector(
              mode: appearance.mode,
              onChanged: controller.setMode,
            ),
            const SizedBox(height: 28),
            const _SectionHeader(label: 'Màu nhấn'),
            const SizedBox(height: 12),
            _AccentSelector(
              selected: appearance.accent,
              onChanged: controller.setAccent,
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 8),
            _LogoutTile(isLoading: isLoggingOut),
          ],
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
    final errorColor = Theme.of(context).colorScheme.error;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.logout_rounded, color: errorColor),
      title: Text(
        'Đăng xuất',
        style: TextStyle(color: errorColor, fontWeight: FontWeight.w500),
      ),
      onTap: isLoading ? null : () => _confirmLogout(context, ref),
    );
  }
}

// ── unchanged widgets below ──────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

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
                border: Border.all(
                  color: isSelected ? scheme.onSurface : Colors.transparent,
                  width: 3,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 6),
            Text(preset.label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
