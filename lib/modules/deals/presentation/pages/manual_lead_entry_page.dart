import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/core/media/file_attachment_service.dart';
import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/presentation/providers/clients_provider.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/presentation/controllers/create_deal_manual_controller.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';

/// Manual ("Gõ tay") lead-entry form, reached from the quick-capture screen's
/// file-icon button. Lets the user create a [Deal] by hand — no voice/AI
/// qualify flow involved.
class ManualLeadEntryPage extends ConsumerStatefulWidget {
  const ManualLeadEntryPage({super.key});

  @override
  ConsumerState<ManualLeadEntryPage> createState() =>
      _ManualLeadEntryPageState();
}

class _ManualLeadEntryPageState extends ConsumerState<ManualLeadEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _estimatedValueController = TextEditingController();
  final _notesController = TextEditingController();

  Client? _selectedClient;
  PlatformFile? _attachedFile;
  bool _pickingFile = false;

  @override
  void dispose() {
    _titleController.dispose();
    _estimatedValueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() => _pickingFile = true);
    try {
      final picked = await ref.read(fileAttachmentServiceProvider).pickFile();
      if (picked != null) {
        setState(() => _attachedFile = picked);
      }
    } finally {
      if (mounted) setState(() => _pickingFile = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) return;

    // TODO: upload once backend attachment endpoint exists. For now the
    // picked file's name/path is only kept in local form state and is not
    // sent anywhere.
    final rawValue = _estimatedValueController.text.trim();

    final created = await ref
        .read(createDealManualControllerProvider.notifier)
        .submit(
          clientId: _selectedClient!.id,
          title: _titleController.text.trim(),
          source: DealSource.inbound,
          estimatedValue: rawValue.isEmpty ? null : double.tryParse(rawValue),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
    if (!mounted) return;
    if (created != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã tạo lead mới')));
      Navigator.of(context).pop(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createDealManualControllerProvider);
    final isSubmitting = state.isLoading;
    final clients = ref.watch(clientListProvider);
    final appearance = ref.watch(appearanceControllerProvider);

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: Scaffold(
        appBar: AppBar(title: const Text('Nhập lead thủ công')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppGap.screen),
            children: [
              AsyncValueWidget<List<Client>>(
                value: clients,
                onRetry: () => ref.invalidate(clientListProvider),
                data: (items) {
                  if (items.isEmpty) {
                    return const Text(
                      'Chưa có khách hàng nào. Vui lòng thêm khách hàng trước.',
                    );
                  }
                  return DropdownButtonFormField<Client>(
                    initialValue: _selectedClient,
                    decoration: const InputDecoration(
                      labelText: 'Khách hàng *',
                    ),
                    items: items
                        .map(
                          (c) =>
                              DropdownMenuItem(value: c, child: Text(c.name)),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedClient = v),
                    validator: (v) =>
                        v == null ? 'Vui lòng chọn khách hàng' : null,
                  );
                },
              ),
              const SizedBox(height: AppGap.lg),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tên lead *'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Vui lòng nhập tên lead'
                    : null,
              ),
              const SizedBox(height: AppGap.lg),
              TextFormField(
                controller: _estimatedValueController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Giá trị ước tính',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  return double.tryParse(v.trim()) == null
                      ? 'Vui lòng nhập số hợp lệ'
                      : null;
                },
              ),
              const SizedBox(height: AppGap.lg),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Ghi chú'),
              ),
              const SizedBox(height: AppGap.lg),
              OutlinedButton.icon(
                onPressed: _pickingFile ? null : _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(
                  _attachedFile == null ? 'Đính kèm tệp' : 'Chọn tệp khác',
                ),
              ),
              if (_attachedFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppGap.sm),
                  child: Text(
                    _attachedFile!.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: AppGap.lg),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppGap.md),
                  child: Text(
                    'Lỗi: Không thể tạo lead. Vui lòng thử lại.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              FilledButton(
                onPressed: isSubmitting ? null : _submit,
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
