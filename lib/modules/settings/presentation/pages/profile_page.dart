import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solodesk_mobile/modules/auth/domain/entities/auth_user.dart';
import 'package:solodesk_mobile/modules/auth/presentation/providers/auth_state_provider.dart';
import 'package:solodesk_mobile/modules/settings/domain/entities/business_profile.dart';
import 'package:solodesk_mobile/modules/settings/presentation/providers/settings_provider.dart';
import 'package:solodesk_mobile/modules/settings/presentation/theme/accent_preset_colors.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/avatar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/section_header.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

/// Che phần giữa của [email], giữ tối đa 2 ký tự đầu local-part + domain
/// nguyên vẹn — ví dụ `solodeskai@gmail.com` → `so*******@gmail.com`.
String _maskEmail(String email) {
  final at = email.indexOf('@');
  if (at <= 0) return email; // rỗng hoặc không có '@' — dữ liệu bất thường, hiện nguyên
  final local = email.substring(0, at);
  final domain = email.substring(at);
  final visibleLen = local.length > 2 ? 2 : local.length;
  final maskLen = local.length - visibleLen;
  return '${local.substring(0, visibleLen)}${'*' * maskLen}$domain';
}

/// Che phần giữa của [phone], giữ 3 số đầu + 2 số cuối — ví dụ
/// `0901234567` → `090*****67`.
String _maskPhone(String phone) {
  if (phone.length <= 5) return '*' * phone.length;
  final head = phone.substring(0, 3);
  final tail = phone.substring(phone.length - 2);
  final maskLen = phone.length - 5;
  return '$head${'*' * maskLen}$tail';
}

/// Màn "Hồ sơ" — chỉnh sửa tên hiển thị, thương hiệu và thông tin xuất hoá đơn.
///
/// Mở từ thẻ hồ sơ ở tab "Tôi". Phần lớn field ở đây **chưa có API `PUT`**
/// (chỉ `GET /users/me` cho `fullName`/`email`) — mọi chỉnh sửa được lưu tạm
/// local qua [BusinessProfileController], xem `TODO(sync)` trong
/// `settings_repository_impl.dart`.
///
/// Dùng state cục bộ (các `TextEditingController`) thay vì ghi thẳng vào
/// controller mỗi lần gõ: chỉ [BusinessProfileController.save] khi người dùng
/// bấm "Lưu" trên `AppBar`.
///
/// Email và số điện thoại luôn hiện ở dạng che (xem [_maskEmail]/
/// [_maskPhone]) — **không có tính năng xem lại giá trị thật**. Email chỉ đọc
/// nên không có tương tác nào cả. Số điện thoại vẫn sửa được, nhưng theo kiểu
/// "gõ mù": bấm vào dòng mở ra một ô nhập TRỐNG để gõ số MỚI đè lên toàn bộ,
/// không bao giờ hiển thị lại số cũ — giống cách đổi mật khẩu. Rời khỏi ô mà
/// chưa gõ gì thì giữ nguyên số cũ (không xoá mất).
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _industryController = TextEditingController();
  final _taxCodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _bankAccountController = TextEditingController();

  String? _avatarLocalPath;
  String? _logoLocalPath;
  String? _publicSlug;

  bool _saving = false;

  /// Số điện thoại đang ở chế độ nhập (gõ mù, ô trống) khi `true`. Không có
  /// bước "xem" nào — bấm dòng lúc đang che là mở ô nhập trống luôn, không
  /// bao giờ hiện lại số cũ. Tự che lại khi mất focus (xem listener ở
  /// [initState]).
  bool _phoneRevealed = false;
  final _phoneFocusNode = FocusNode();

  /// Số cũ, lưu tạm lúc mở ô nhập trống — nếu người dùng rời đi mà không gõ
  /// gì thì khôi phục lại, tránh vô tình xoá mất số đã lưu.
  String _phoneBeforeEdit = '';

  /// `true` ngay khi người dùng gõ hoặc chọn ảnh lần đầu. Chặn việc nạp lại từ
  /// [BusinessProfileController] hydrate xong sau khi màn đã mở (xem
  /// `ref.listen` trong [build]) đè lên nội dung người dùng đang sửa dở.
  bool _userEdited = false;

  @override
  void initState() {
    super.initState();
    // Nạp state cục bộ từ giá trị hiện có ngay khi mở màn. Nếu
    // `BusinessProfileController` chưa kịp hydrate xong từ `SecureStorage`
    // (bất đồng bộ), `ref.listen` trong `build` sẽ nạp lại khi nó xong — miễn
    // là người dùng chưa bắt đầu sửa gì.
    final profile = ref.read(businessProfileControllerProvider);
    final user = ref.read(currentUserProvider);
    _seedControllers(profile, user);
    _phoneFocusNode.addListener(() {
      if (_phoneFocusNode.hasFocus || !mounted) return;
      _restorePhoneIfBlank();
      setState(() => _phoneRevealed = false);
    });
  }

  /// Đang gõ mù ([_phoneRevealed]) mà ô còn trống thì khôi phục số cũ —
  /// dùng cả khi rời ô lẫn khi bấm "Lưu" ngay lúc ô vẫn đang trống/focus, để
  /// không vô tình xoá mất số đã lưu chỉ vì mở ô nhập rồi không gõ gì.
  void _restorePhoneIfBlank() {
    if (_phoneRevealed && _phoneController.text.trim().isEmpty) {
      _phoneController.text = _phoneBeforeEdit;
    }
  }

  void _seedControllers(BusinessProfile profile, AuthUser? user) {
    _displayNameController.text = profile.displayName.isNotEmpty
        ? profile.displayName
        : (user?.fullName ?? '');
    _phoneController.text = profile.phone;
    _businessNameController.text = profile.businessName;
    _industryController.text = profile.industry;
    _taxCodeController.text = profile.taxCode;
    _addressController.text = profile.address;
    _bankAccountController.text = profile.bankAccountMasked;
    _avatarLocalPath = profile.avatarLocalPath;
    _logoLocalPath = profile.logoLocalPath;
    _publicSlug = profile.publicSlug;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _industryController.dispose();
    _taxCodeController.dispose();
    _addressController.dispose();
    _bankAccountController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _markEdited([String? _]) {
    setState(() => _userEdited = true);
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    setState(() {
      _avatarLocalPath = picked.path;
      _userEdited = true;
    });
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    setState(() {
      _logoLocalPath = picked.path;
      _userEdited = true;
    });
  }

  void _openPublicPage() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tính năng sắp có')));
  }

  Future<void> _save() async {
    _restorePhoneIfBlank();
    setState(() => _saving = true);
    final profile = BusinessProfile(
      displayName: _displayNameController.text.trim(),
      phone: _phoneController.text.trim(),
      avatarLocalPath: _avatarLocalPath,
      businessName: _businessNameController.text.trim(),
      logoLocalPath: _logoLocalPath,
      industry: _industryController.text.trim(),
      taxCode: _taxCodeController.text.trim(),
      address: _addressController.text.trim(),
      bankAccountMasked: _bankAccountController.text.trim(),
      publicSlug: _publicSlug,
    );
    await ref.read(businessProfileControllerProvider.notifier).save(profile);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã lưu hồ sơ')));
    context.pop();
  }

  String _avatarInitials() {
    final name = _displayNameController.text.trim().isNotEmpty
        ? _displayNameController.text.trim()
        : (ref.read(currentUserProvider)?.fullName ?? '');
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Widget _buildAvatar() {
    final path = _avatarLocalPath;
    if (path != null && path.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          File(path),
          width: 72,
          height: 72,
          fit: BoxFit.cover,
        ),
      );
    }
    return Avatar.initials(
      _avatarInitials(),
      size: 72,
      radius: 20,
      tone: Tone.ai,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hydrate xong sau khi màn đã mở (đọc `SecureStorage` là bất đồng bộ) thì
    // nạp lại state cục bộ — trừ khi người dùng đã bắt đầu sửa.
    ref.listen<BusinessProfile>(businessProfileControllerProvider, (
      previous,
      next,
    ) {
      if (_userEdited) return;
      setState(() => _seedControllers(next, ref.read(currentUserProvider)));
    });

    final appearance = ref.watch(appearanceControllerProvider);
    final email = ref.watch(currentUserProvider)?.email ?? '';

    return Theme(
      data: AppTheme.light(seed: appearance.accent.seed),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SoloAppBar(
                title: 'Hồ sơ',
                titleSize: SoloAppBar.sm,
                leading: IconButtonBox(
                  SoloIcons.back,
                  label: 'Quay lại',
                  ghost: true,
                  onTap: () => context.pop(),
                ),
                actions: [
                  TextButton(
                    onPressed: _saving ? null : _save,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.ai,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(44, 44),
                      textStyle: AppText.button,
                    ),
                    child: Text(_saving ? 'Đang lưu…' : 'Lưu'),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppGap.screen,
                    0,
                    AppGap.screen,
                    AppGap.xxl,
                  ),
                  children: [
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickAvatar,
                            child: _buildAvatar(),
                          ),
                          const SizedBox(height: AppGap.md),
                          InkWell(
                            onTap: _pickAvatar,
                            borderRadius: BorderRadius.circular(
                              AppRadius.chip,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppGap.lg,
                                vertical: AppGap.xs,
                              ),
                              child: Text(
                                'Đổi ảnh đại diện',
                                style: AppText.link,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SectionHeader('Cá nhân'),
                    _GroupCard([
                      _EditableFieldRow(
                        label: 'Tên hiển thị',
                        controller: _displayNameController,
                        onChanged: _markEdited,
                      ),
                      _StaticFieldRow(
                        label: 'Email',
                        value: _maskEmail(email),
                        muted: true,
                      ),
                      if (_phoneRevealed)
                        _EditableFieldRow(
                          label: 'Số điện thoại',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          focusNode: _phoneFocusNode,
                          onChanged: _markEdited,
                        )
                      else
                        _StaticFieldRow(
                          label: 'Số điện thoại',
                          value: _maskPhone(_phoneController.text),
                          onTap: () {
                            // Gõ mù: mở ô trống, không hiện lại số cũ.
                            _phoneBeforeEdit = _phoneController.text;
                            _phoneController.clear();
                            setState(() => _phoneRevealed = true);
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => _phoneFocusNode.requestFocus(),
                            );
                          },
                        ),
                    ]),
                    const SectionHeader('Thương hiệu'),
                    _GroupCard([
                      _EditableFieldRow(
                        label: 'Tên doanh nghiệp',
                        controller: _businessNameController,
                        onChanged: _markEdited,
                      ),
                      _LogoRow(
                        uploaded:
                            _logoLocalPath != null &&
                            _logoLocalPath!.isNotEmpty,
                        onTap: _pickLogo,
                      ),
                      _EditableFieldRow(
                        label: 'Lĩnh vực',
                        controller: _industryController,
                        onChanged: _markEdited,
                      ),
                    ]),
                    const SectionHeader('Thông tin xuất hoá đơn'),
                    _GroupCard([
                      _EditableFieldRow(
                        label: 'Mã số thuế',
                        controller: _taxCodeController,
                        onChanged: _markEdited,
                      ),
                      _EditableFieldRow(
                        label: 'Địa chỉ',
                        controller: _addressController,
                        onChanged: _markEdited,
                      ),
                      _EditableFieldRow(
                        label: 'Tài khoản nhận tiền',
                        controller: _bankAccountController,
                        onChanged: _markEdited,
                      ),
                    ]),
                    const SizedBox(height: AppGap.sectionTop),
                    _PublicPageCard(slug: _publicSlug, onTap: _openPublicPage),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Một nhóm dòng trong cùng một `Card`, ngăn nhau bằng đường kẻ 1px — cùng
/// khuôn với `_MenuCard` ở `me_page.dart`.
class _GroupCard extends StatelessWidget {
  const _GroupCard(this.rows);

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.line),
            rows[i],
          ],
        ],
      ),
    );
  }
}

/// Một dòng "nhãn trái — giá trị sửa được bên phải", `TextField` không viền
/// căn phải để trông như chữ tĩnh cho tới khi người dùng chạm vào.
class _EditableFieldRow extends StatelessWidget {
  const _EditableFieldRow({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.onChanged,
    this.focusNode,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppGap.card,
        vertical: AppGap.lg,
      ),
      child: Row(
        children: [
          Text(label, style: AppText.body.copyWith(color: AppColors.ink2)),
          const SizedBox(width: AppGap.row),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              onChanged: onChanged,
              textAlign: TextAlign.right,
              style: AppText.body,
              decoration: const InputDecoration(
                isDense: true,
                isCollapsed: true,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Một dòng "nhãn trái — giá trị chỉ đọc bên phải", dùng cho Email và (khi
/// đang che) Số điện thoại. [onTap] khác nhau tuỳ nơi gọi: với Email chỉ bật
/// tắt xem tại chỗ; với Số điện thoại đang che thì chuyển sang chế độ sửa.
class _StaticFieldRow extends StatelessWidget {
  const _StaticFieldRow({
    required this.label,
    required this.value,
    this.muted = false,
    this.onTap,
  });

  final String label;
  final String value;
  final bool muted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppGap.card,
        vertical: AppGap.lg,
      ),
      child: Row(
        children: [
          Text(label, style: AppText.body.copyWith(color: AppColors.ink2)),
          const SizedBox(width: AppGap.row),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: muted ? AppText.mut : AppText.body,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}

/// Dòng "Logo trên hoá đơn" — cả dòng bấm được để mở `image_picker`, hiện
/// trạng thái "Đã tải lên"/"Chưa tải lên" thay vì chỉ đổi màu.
class _LogoRow extends StatelessWidget {
  const _LogoRow({required this.uploaded, required this.onTap});

  final bool uploaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppGap.card,
          vertical: AppGap.lg,
        ),
        child: Row(
          children: [
            Text(
              'Logo trên hoá đơn',
              style: AppText.body.copyWith(color: AppColors.ink2),
            ),
            const SizedBox(width: AppGap.row),
            Expanded(
              child: Text(
                uploaded ? 'Đã tải lên' : 'Chưa tải lên',
                textAlign: TextAlign.right,
                style: AppText.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thẻ "Trang giới thiệu công khai" cuối màn. Chưa có backend cấp trang công
/// khai thật — chạm vào chỉ báo "Tính năng sắp có".
class _PublicPageCard extends StatelessWidget {
  const _PublicPageCard({required this.slug, required this.onTap});

  final String? slug;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = (slug == null || slug!.isEmpty)
        ? 'solodesk.vn/ (chưa đặt)'
        : 'solodesk.vn/$slug';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppGap.card),
          child: Row(
            children: [
              const SoloIcon(
                SoloIcons.link,
                label: null,
                color: AppColors.ink2,
              ),
              const SizedBox(width: AppGap.row),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Trang giới thiệu công khai', style: AppText.body),
                    Text(subtitle, style: AppText.mut),
                  ],
                ),
              ),
              const SoloIcon(
                SoloIcons.chevron,
                label: null,
                size: SoloIcon.sm,
                color: AppColors.ink3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
