import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/core/storage/secure_storage.dart';
import 'package:solodesk_mobile/modules/auth/presentation/controllers/auth_controller.dart';
import 'package:solodesk_mobile/modules/settings/domain/value_objects/accent_preset.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/shared/extensions/context_extensions.dart';
import 'package:solodesk_mobile/shared/widgets/logout_loading_overlay.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/ui/section_header.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

/// Màn "Cài đặt" — sub-screen mở từ gear icon trên tab "Tôi".
///
/// Theo `design/solodesk_cai_dat_sub_screen.html`, năm nhóm theo đúng thứ tự:
/// Chung, Thông báo, Mặc định hoá đơn và báo giá, Bảo mật và dữ liệu, và một
/// nhóm hành động cuối (Đăng xuất / Xoá tài khoản) không có heading riêng.
///
/// Phần lớn field ở đây chưa có API `PUT` — Thông báo và Mặc định hoá đơn/báo
/// giá lưu qua [SettingsRepository] (SecureStorage) như appearance đã làm.
/// Ngôn ngữ/đơn vị tiền tệ, đổi mật khẩu, xuất dữ liệu và xoá tài khoản chưa có
/// backend nên chỉ dựng UI, hành động thật báo "Tính năng sắp có".
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceControllerProvider);
    final appearanceController = ref.read(
      appearanceControllerProvider.notifier,
    );
    final notificationPrefs = ref.watch(
      notificationPreferencesControllerProvider,
    );
    final notificationController = ref.read(
      notificationPreferencesControllerProvider.notifier,
    );
    final invoiceDefaults = ref.watch(invoiceDefaultsControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final isLoggingOut = authState.isLoading;

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: LogoutLoadingOverlay(
        isLoading: isLoggingOut,
        child: Scaffold(
          appBar: AppBar(title: const Text('Cài đặt')),
          body: ListView(
            padding: const EdgeInsets.all(AppGap.screen),
            children: [
              const SectionHeader('Chung'),
              _GroupCard([
                const _SettingsRow(
                  icon: SoloIcons.language,
                  label: 'Ngôn ngữ',
                  value: 'Tiếng Việt',
                ),
                const _SettingsRow(
                  icon: SoloIcons.currencyDong,
                  label: 'Đơn vị tiền tệ',
                  value: 'VND',
                ),
                _AppearanceBlock(
                  mode: appearance.mode,
                  accent: appearance.accent,
                  onModeChanged: appearanceController.setMode,
                  onAccentChanged: appearanceController.setAccent,
                ),
              ]),

              const SectionHeader('Thông báo'),
              _GroupCard([
                _ToggleRow(
                  label: 'Hoá đơn đến hạn',
                  value: notificationPrefs.invoiceDue,
                  onChanged: notificationController.setInvoiceDue,
                ),
                _ToggleRow(
                  label: 'Khách phản hồi báo giá',
                  value: notificationPrefs.quoteResponse,
                  onChanged: notificationController.setQuoteResponse,
                ),
                _ToggleRow(
                  label: 'Tóm tắt hàng tuần qua email',
                  value: notificationPrefs.weeklyEmailSummary,
                  onChanged: notificationController.setWeeklyEmailSummary,
                ),
              ]),

              const SectionHeader('Mặc định hoá đơn và báo giá'),
              _GroupCard([
                _SettingsRow(
                  label: 'Thuế VAT',
                  value: '${_formatPercent(invoiceDefaults.vatPercent)}%',
                  chevron: true,
                  onTap: () => _editVatPercent(
                    context,
                    ref,
                    invoiceDefaults.vatPercent,
                  ),
                ),
                _SettingsRow(
                  label: 'Hạn thanh toán',
                  value: '${invoiceDefaults.dueDays} ngày',
                  chevron: true,
                  onTap: () =>
                      _editDueDays(context, ref, invoiceDefaults.dueDays),
                ),
                _SettingsRow(
                  label: 'Điều khoản và chữ ký',
                  chevron: true,
                  onTap: () =>
                      _editTermsText(context, ref, invoiceDefaults.termsText),
                ),
              ]),

              const SectionHeader('Bảo mật và dữ liệu'),
              _GroupCard([
                _SettingsRow(
                  icon: SoloIcons.lock,
                  label: 'Đổi mật khẩu',
                  chevron: true,
                  onTap: () => context.showSnackBar('Tính năng sắp có'),
                ),
                const _BiometricLockRow(),
                _SettingsRow(
                  icon: SoloIcons.download,
                  label: 'Xuất dữ liệu',
                  chevron: true,
                  onTap: () => context.showSnackBar('Tính năng sắp có'),
                ),
              ]),

              const SizedBox(height: AppGap.sectionTop),
              _GroupCard([
                _SettingsRow(
                  icon: SoloIcons.logout,
                  label: 'Đăng xuất',
                  onTap: isLoggingOut ? null : () => _confirmLogout(context, ref),
                ),
                _SettingsRow(
                  icon: SoloIcons.trash,
                  label: 'Xoá tài khoản',
                  color: Theme.of(context).colorScheme.error,
                  onTap: () => _confirmDeleteAccount(context),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

/// "8" thay vì "8.0" khi phần trăm là số nguyên, giữ nguyên chữ số lẻ nếu có.
String _formatPercent(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toString();
}

Future<void> _editVatPercent(
  BuildContext context,
  WidgetRef ref,
  double current,
) async {
  final text = await showDialog<String>(
    context: context,
    builder: (_) => _TextInputDialog(
      title: 'Thuế VAT',
      initialText: _formatPercent(current),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      suffixText: '%',
    ),
  );
  if (text == null || text.isEmpty) return;
  final value = double.tryParse(text);
  if (value == null) return;
  await ref.read(invoiceDefaultsControllerProvider.notifier).setVatPercent(value);
}

Future<void> _editDueDays(
  BuildContext context,
  WidgetRef ref,
  int current,
) async {
  final text = await showDialog<String>(
    context: context,
    builder: (_) => _TextInputDialog(
      title: 'Hạn thanh toán',
      initialText: current.toString(),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      suffixText: 'ngày',
    ),
  );
  if (text == null || text.isEmpty) return;
  final value = int.tryParse(text);
  if (value == null) return;
  await ref.read(invoiceDefaultsControllerProvider.notifier).setDueDays(value);
}

Future<void> _editTermsText(
  BuildContext context,
  WidgetRef ref,
  String? current,
) async {
  final text = await showDialog<String>(
    context: context,
    builder: (_) => _TextInputDialog(
      title: 'Điều khoản và chữ ký',
      initialText: current ?? '',
      maxLines: 5,
      hintText: 'Nhập điều khoản thanh toán, chữ ký...',
    ),
  );
  if (text == null) return;
  await ref
      .read(invoiceDefaultsControllerProvider.notifier)
      .setTermsText(text.isEmpty ? null : text);
}

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

/// Xoá tài khoản chưa có usecase/endpoint thật trong module `auth` — dựng đúng
/// luồng xác nhận rồi báo "sắp có" thay vì gọi API bịa.
Future<void> _confirmDeleteAccount(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Xoá tài khoản'),
      content: const Text(
        'Hành động này sẽ xoá vĩnh viễn tài khoản và toàn bộ dữ liệu. '
        'Bạn có chắc muốn tiếp tục?',
      ),
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
          child: const Text('Xoá tài khoản'),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    context.showSnackBar('Tính năng sắp có');
  }
}

// ── Nhóm và hàng dùng chung ──────────────────────────────────────────────

/// Một nhóm cài đặt trong cùng một `Card`, ngăn nhau bằng đường kẻ 1px — cùng
/// khuôn `_MenuCard` của `me_page.dart` nhưng viết riêng ở đây để không import
/// private class xuyên file.
class _GroupCard extends StatelessWidget {
  const _GroupCard(this.children);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppGap.betweenCards),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.line),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Một dòng icon (tuỳ chọn) + nhãn + giá trị/chevron (tuỳ chọn).
///
/// **Dùng khi:** dòng tĩnh chỉ hiển thị giá trị (Ngôn ngữ, Đơn vị tiền tệ),
/// dòng điều hướng mở dialog ([onTap] + [chevron]), hoặc dòng hành động cuối
/// (Đăng xuất, Xoá tài khoản — [color] tô cả icon lẫn chữ).
///
/// **KHÔNG dùng khi:** dòng có `Switch` — dùng [_ToggleRow], nó lo cả vùng
/// chạm 44×44 qua `SwitchListTile`.
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    this.icon,
    required this.label,
    this.value,
    this.chevron = false,
    this.onTap,
    this.color,
  });

  final SoloIconData? icon;
  final String label;
  final String? value;
  final bool chevron;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final labelColor = color ?? AppColors.ink;
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppGap.card,
        vertical: AppGap.lg,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            SoloIcon(
              icon!,
              label: null,
              size: SoloIcon.md,
              color: color ?? AppColors.ink2,
            ),
            const SizedBox(width: AppGap.row),
          ],
          Expanded(
            child: Text(label, style: AppText.body.copyWith(color: labelColor)),
          ),
          if (value != null)
            Padding(
              padding: EdgeInsets.only(right: chevron ? AppGap.xs : 0),
              child: Text(value!, style: AppText.mut),
            ),
          if (chevron)
            const SoloIcon(SoloIcons.chevron, label: null, size: SoloIcon.sm),
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}

/// Dòng toggle (`SwitchListTile` để có vùng chạm cả dòng và ngữ nghĩa tự động
/// ghép nhãn + trạng thái cho trình đọc màn hình).
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final SoloIconData? icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppGap.card),
      value: value,
      onChanged: onChanged,
      title: Text(label, style: AppText.body),
      secondary: icon == null
          ? null
          : SoloIcon(
              icon!,
              label: null,
              size: SoloIcon.md,
              color: AppColors.ink2,
            ),
    );
  }
}

/// Dialog nhập một dòng chữ hoặc số, dùng cho Thuế VAT / Hạn thanh toán /
/// Điều khoản và chữ ký. Trả về chuỗi đã `trim()`, hoặc `null` nếu bấm "Huỷ".
class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.initialText,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.hintText,
    this.suffixText,
  });

  final String title;
  final String initialText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final String? hintText;
  final String? suffixText;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          hintText: widget.hintText,
          suffixText: widget.suffixText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Huỷ'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

/// Toggle "Khoá bằng sinh trắc học".
///
/// **Chỉ lưu ý định của người dùng** — dự án chưa có package `local_auth`
/// nên chưa có luồng khoá thật bằng vân tay/khuôn mặt. Cờ này đọc/ghi thẳng
/// qua `secureStorageProvider` (khoá `app.biometric_lock`) thay vì đi qua
/// `SettingsRepository`, vì đây chỉ là một bool cờ ý định, chưa phải một cài
/// đặt thật cần đồng bộ. Khi thêm `local_auth` + luồng khoá app, chuyển cờ
/// này vào repository cùng cách các cài đặt khác đang lưu.
class _BiometricLockRow extends ConsumerStatefulWidget {
  const _BiometricLockRow();

  @override
  ConsumerState<_BiometricLockRow> createState() => _BiometricLockRowState();
}

class _BiometricLockRowState extends ConsumerState<_BiometricLockRow> {
  static const _storageKey = 'app.biometric_lock';

  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  Future<void> _hydrate() async {
    final raw = await ref.read(secureStorageProvider).read(_storageKey);
    if (mounted && raw == 'true') setState(() => _enabled = true);
  }

  Future<void> _toggle(bool value) async {
    setState(() => _enabled = value);
    await ref.read(secureStorageProvider).write(_storageKey, value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return _ToggleRow(
      icon: SoloIcons.fingerprint,
      label: 'Khoá bằng sinh trắc học',
      value: _enabled,
      onChanged: _toggle,
    );
  }
}

/// Dòng "Giao diện" + selector theme/màu nhấn — logic không đổi so với bản cũ,
/// chỉ gộp vào nhóm "Chung" thay vì có heading rời.
class _AppearanceBlock extends StatelessWidget {
  const _AppearanceBlock({
    required this.mode,
    required this.accent,
    required this.onModeChanged,
    required this.onAccentChanged,
  });

  final ThemeMode mode;
  final AccentPreset accent;
  final ValueChanged<ThemeMode> onModeChanged;
  final ValueChanged<AccentPreset> onAccentChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppGap.card,
        AppGap.lg,
        AppGap.card,
        AppGap.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SoloIcon(
                SoloIcons.moon,
                label: null,
                size: SoloIcon.md,
                color: AppColors.ink2,
              ),
              const SizedBox(width: AppGap.row),
              Text('Giao diện', style: AppText.body),
            ],
          ),
          const SizedBox(height: AppGap.lg),
          _ThemeModeSelector(mode: mode, onChanged: onModeChanged),
          const SizedBox(height: AppGap.xl),
          const SectionLabel('Màu nhấn'),
          const SizedBox(height: AppGap.sm),
          _AccentSelector(selected: accent, onChanged: onAccentChanged),
        ],
      ),
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
