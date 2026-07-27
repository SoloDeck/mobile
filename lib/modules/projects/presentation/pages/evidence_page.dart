import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/app_theme.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/avatar.dart';
import 'package:solodesk_mobile/ui/bottom_action_bar.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';
import 'package:solodesk_mobile/ui/mono_text.dart';
import 'package:solodesk_mobile/ui/perforated_divider.dart';
import 'package:solodesk_mobile/ui/progress_bar.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/solo_app_bar.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// MÀN 10 — Kho bằng chứng bàn giao.
///
/// Đối chiếu: khối `MÀN 10` trong `design/solodesk-mobile-ui.html` (dòng 833–892),
/// gồm cả `<figcaption>`.
///
/// Bốn quyết định trong figcaption, đừng đảo lại khi sửa:
/// - **Nhóm file theo mốc bàn giao, không theo thư mục**: hai lưới ảnh xếp dưới
///   `SectionLabel` là "Hôm nay · 25/07" và "21/07 · Đợt nháp 1" — mốc thời gian
///   bàn giao, không phải tên thư mục.
/// - **Ảnh chụp Zalo là bằng chứng chính thức**: `zalo_gui.jpg` nằm cùng
///   `_TileRow` với `logo_v2.png` và `guideline.pdf`, không tách riêng hàng hay
///   khối nào khác.
/// - **Link chia sẻ luôn hiện thời hạn 7 ngày ngay trên nút**: nút trong
///   `_SelectedFileCard` ghi nguyên văn "Tạo link 7 ngày", không rút gọn thành
///   "Tạo link".
/// - **Thanh dung lượng gói đặt ở đáy màn hình**: `ProgressBar` nằm ngay phía
///   trên `BottomActionBar`, sau mọi lưới file, đúng nơi người dùng sắp chạm
///   giới hạn gói.
///
/// ## Một chỗ cố ý lệch khỏi bản phác thảo
///
/// Thẻ "File đang chọn" dùng `.slip` trong HTML, nhưng đây không phải tiền —
/// dựng bằng `Card` theo đúng quy tắc 3 (`AGENTS.md`) và ngoại lệ đã chốt trong
/// doc comment của `SlipCard`. Đừng đổi lại thành `SlipCard`.
///
/// CHƯA NỐI API — toàn bộ dữ liệu là mock. Backend có `file`/`upload` ở
/// `proposals`/`deals` nhưng không phát presigned URL, và mobile chưa có
/// datasource nào cho bằng chứng bàn giao. Không có provider để `watch` ở
/// đây; `WidgetRef` được giữ lại theo khuôn `ConsumerWidget` để sẵn sàng nối
/// dây khi datasource xuất hiện.
///
/// Cùng lý do đó, [projectId] nhận vào nhưng chưa đọc tới: route
/// `/projects/:id/evidence` đã mang sẵn mã dự án, nên màn giữ luôn giá trị này
/// để khi datasource kho file xuất hiện thì `ref.watch(...(projectId))` ngay
/// tại đây — không phải sửa lại chữ ký widget và route một lần nữa. Đây là chỗ
/// nối dây đã chừa sẵn, không phải tham số thừa.
class EvidencePage extends ConsumerWidget {
  const EvidencePage({super.key, required this.projectId});

  /// Mã dự án lấy từ `:id` của route cha `/projects/:id`. Chưa dùng tới —
  /// xem đoạn cuối doc comment của lớp.
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: AppTheme.light(),
      // Không `const` được từ `Scaffold` xuống: nút quay lại mang closure
      // `context.pop()`. Các nhánh con còn lại vẫn giữ `const` từng cái.
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  SoloAppBar(
                    title: _MockData.appBarTitle,
                    titleSize: SoloAppBar.sm,
                    leading: IconButtonBox(
                      SoloIcons.back,
                      label: 'Quay lại',
                      ghost: true,
                      onTap: () => context.pop(),
                    ),
                    actions: const [
                      IconButtonBox(SoloIcons.search, label: 'Tìm kiếm'),
                    ],
                  ),
                  const Expanded(
                    // SingleChildScrollView chứ không phải ListView: nội dung
                    // dựng hết một lượt để test tìm được cả phần dưới màn.
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        AppGap.screen,
                        0,
                        AppGap.screen,
                        // Chừa chỗ cho BottomActionBar nổi ở đáy. Không có token
                        // riêng cho dải hành động không kèm SoloNavBar, dùng tạm
                        // navBarInset — xem ghi chú trong báo cáo cuối.
                        AppGap.navBarInset,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _FileCountRow(),
                          SizedBox(height: AppGap.lg),
                          SectionLabel(_MockData.todayLabel),
                          SizedBox(height: AppGap.sm),
                          _TileRow([
                            _GradientTile(
                              colors: [AppColors.ai, AppColors.momo],
                              fileName: _MockData.logoFile,
                            ),
                            _GradientTile(
                              colors: [AppColors.ink, AppColors.ink2],
                              fileName: _MockData.zaloFile,
                            ),
                            _FileTile(
                              fileName: _MockData.guidelineFile,
                              fileSize: _MockData.guidelineSize,
                            ),
                          ]),
                          SizedBox(height: AppGap.xl),
                          SectionLabel(_MockData.draftLabel),
                          SizedBox(height: AppGap.sm),
                          _TileRow([
                            _GradientTile(
                              colors: [AppColors.jade, AppColors.avJ2],
                            ),
                            _GradientTile(
                              colors: [AppColors.amber, AppColors.avA2],
                            ),
                            _MoreTile(_MockData.moreCount),
                          ]),
                          SizedBox(height: AppGap.xl),
                          _SelectedFileCard(),
                          SizedBox(height: AppGap.card),
                          _StorageUsage(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: BottomActionBar(child: _CaptureButton()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dòng đếm file + công tắc kiểu xem (Lưới / Dòng thời gian), `.between` trong
/// bản phác thảo.
class _FileCountRow extends StatelessWidget {
  const _FileCountRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Text(_MockData.fileSummary, style: AppText.mut)),
        _ViewToggle(),
      ],
    );
  }
}

/// Hai chip chọn kiểu xem — dùng thẳng `StatusChip`, không phải
/// `FilterChipBar`, vì đây chỉ là công tắc hai nhánh nằm gọn trong một hàng
/// canh phải, không phải dải lọc nhiều nhóm cuộn ngang.
class _ViewToggle extends StatelessWidget {
  const _ViewToggle();

  static const List<String> _labels = ['Lưới', 'Dòng thời gian'];
  static const int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _labels.length; i++) ...[
          if (i > 0) const SizedBox(width: AppGap.xs),
          StatusChip(
            _labels[i],
            tone: i == _selectedIndex ? Tone.solid : Tone.neutral,
          ),
        ],
      ],
    );
  }
}

/// Một hàng ba ô vuông của lưới file, `grid-template-columns:repeat(3,1fr)`
/// trong bản phác thảo.
class _TileRow extends StatelessWidget {
  const _TileRow(this.tiles);

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: AppGap.sm),
          Expanded(child: AspectRatio(aspectRatio: 1, child: tiles[i])),
        ],
      ],
    );
  }
}

/// Ô ảnh nền chuyển sắc, đại diện cho ảnh chụp hoặc ảnh Zalo. [fileName] là
/// `null` cho các ô "đợt nháp" chỉ có màu, không có tên file lẫn icon.
class _GradientTile extends StatelessWidget {
  const _GradientTile({required this.colors, this.fileName});

  final List<Color> colors;
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(AppRadius.tile),
      ),
      child: fileName == null
          ? null
          : Stack(
              children: [
                Center(
                  child: SoloIcon(
                    SoloIcons.image,
                    label: null,
                    color: AppColors.surface.withValues(alpha: 0.85),
                  ),
                ),
                Positioned(
                  left: AppGap.xs,
                  bottom: AppGap.xs,
                  child: MonoText(
                    fileName!,
                    style: AppText.numSm,
                    color: AppColors.surface.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Ô tệp không phải ảnh — nền trắng, viền xám, icon tệp và tên/dung lượng ở
/// giữa. Đại diện cho `guideline.pdf`.
class _FileTile extends StatelessWidget {
  const _FileTile({required this.fileName, required this.fileSize});

  final String fileName;
  final String fileSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadius.tile),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SoloIcon(SoloIcons.file, label: null, color: AppColors.momo),
            const SizedBox(height: AppGap.xxs),
            MonoText(fileName, style: AppText.numSm),
            Text(fileSize, style: AppText.mut),
          ],
        ),
      ),
    );
  }
}

/// Ô "còn N file nữa" ở cuối một lưới đã đầy — chỉ có `MonoText`, không icon.
class _MoreTile extends StatelessWidget {
  const _MoreTile(this.count);

  final String count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadius.tile),
      ),
      child: Center(
        child: MonoText(count, style: AppText.numMd, color: AppColors.ink3),
      ),
    );
  }
}

/// Thẻ "File đang chọn". Là `Card`, **không phải** `SlipCard` — nội dung không
/// phải tiền, xem ghi chú ngoại lệ trong doc comment của `EvidencePage`.
class _SelectedFileCard extends StatelessWidget {
  const _SelectedFileCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppGap.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SectionLabel('File đang chọn'),
                StatusChip('Đã ghi nhận', tone: Tone.ok),
              ],
            ),
            const SizedBox(height: AppGap.md),
            const Row(
              children: [
                Avatar.icon(SoloIcons.image, tone: Tone.ai),
                SizedBox(width: AppGap.row),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_MockData.logoFile, style: AppText.bodyStrong),
                      Text(_MockData.selectedFileMeta, style: AppText.mut),
                    ],
                  ),
                ),
              ],
            ),
            const PerforatedDivider(bleed: AppGap.card),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: AppTheme.outlined(small: true),
                    child: const Text('Gắn vào task'),
                  ),
                ),
                const SizedBox(width: AppGap.betweenButtons),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    style: AppTheme.filled(small: true),
                    icon: const SoloIcon(
                      SoloIcons.send,
                      label: null,
                      size: SoloIcon.xs,
                      color: AppColors.surface,
                    ),
                    label: const Text('Tạo link 7 ngày'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dòng dung lượng gói + thanh tiến độ, đặt ở đáy thân màn theo figcaption.
class _StorageUsage extends StatelessWidget {
  const _StorageUsage();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(_MockData.storageLabel, style: AppText.mut)),
            MonoText(_MockData.storageUsage, style: AppText.numSm),
          ],
        ),
        SizedBox(height: AppGap.xs),
        ProgressBar(value: _MockData.storageRatio, color: AppColors.ai),
      ],
    );
  }
}

/// Nút chính "Chụp hoặc chọn file", đặt trong `BottomActionBar` để luôn nằm
/// trong tầm ngón cái dù nội dung phía trên có dài.
class _CaptureButton extends StatelessWidget {
  const _CaptureButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {},
      style: AppTheme.filled(),
      icon: const SoloIcon(
        SoloIcons.image,
        label: null,
        size: SoloIcon.sm,
        color: AppColors.surface,
      ),
      label: const Text(_MockData.captureButtonLabel),
    );
  }
}

/// CHƯA NỐI API — toàn bộ file, mốc bàn giao và dung lượng gói ở đây là dữ
/// liệu giả lấy nguyên từ bản phác thảo. Backend chưa có datasource cho bằng
/// chứng bàn giao (không có presigned URL cho `file`/`upload` ở
/// `proposals`/`deals`). Ghép API thật chỉ cần thay ở đây.
///
/// Là class chứ không phải record vì Dart không cho đọc field của record trong
/// biểu thức `const`, mà widget của màn này phải const được. Tên viết hoa theo
/// lint `camel_case_types` của repo.
abstract final class _MockData {
  static const String appBarTitle = 'Bằng chứng bàn giao';
  static const String fileSummary = '14 file · dự án Minh An';
  static const String todayLabel = 'Hôm nay · 25/07';
  static const String draftLabel = '21/07 · Đợt nháp 1';
  static const String logoFile = 'logo_v2.png';
  static const String zaloFile = 'zalo_gui.jpg';
  static const String guidelineFile = 'guideline.pdf';
  static const String guidelineSize = '4.2 MB';
  static const String moreCount = '+9';
  static const String selectedFileMeta = '2.1 MB · tải lên 09:12 · bởi bạn';
  static const String storageLabel = 'Dung lượng gói Solo Pro';
  static const String storageUsage = '1,8 / 10 GB';
  static const double storageRatio = 0.18;
  static const String captureButtonLabel = 'Chụp hoặc chọn file';
}
