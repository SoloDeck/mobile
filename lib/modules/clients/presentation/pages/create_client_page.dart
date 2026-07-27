import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/modules/clients/domain/entities/client.dart';
import 'package:solodesk_mobile/modules/clients/presentation/controllers/clients_controller.dart';
import 'package:solodesk_mobile/modules/clients/presentation/pages/clients_page.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';

/// Form to create a new client. On success, pops back to the list.
class CreateClientPage extends ConsumerStatefulWidget {
  const CreateClientPage({super.key});

  @override
  ConsumerState<CreateClientPage> createState() => _CreateClientPageState();
}

class _CreateClientPageState extends ConsumerState<CreateClientPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  ClientType _type = ClientType.individual;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final created = await ref
        .read(createClientControllerProvider.notifier)
        .submit(
          name: _nameController.text.trim(),
          type: _type,
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
    if (!mounted) return;
    if (created != null) {
      Navigator.of(context).pop(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createClientControllerProvider);
    final isSubmitting = state.isLoading;
    final appearance = ref.watch(appearanceControllerProvider);

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: Scaffold(
        appBar: AppBar(title: const Text('Thêm khách hàng')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppGap.screen),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên khách hàng *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: AppGap.lg),
              SegmentedButton<ClientType>(
                segments: ClientType.values
                    .map((t) => ButtonSegment(value: t, label: Text(t.label)))
                    .toList(),
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
                style: SegmentedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
              const SizedBox(height: AppGap.lg),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: AppGap.lg),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Điện thoại'),
              ),
              const SizedBox(height: AppGap.lg),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Ghi chú'),
              ),
              const SizedBox(height: AppGap.lg),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppGap.md),
                  child: Text(
                    'Lỗi: Không thể tạo khách hàng. Vui lòng thử lại.',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
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
                    : const Text('Lưu khách hàng'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
