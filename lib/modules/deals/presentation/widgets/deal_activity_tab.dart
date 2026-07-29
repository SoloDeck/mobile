import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal_activity.dart';
import 'package:solodesk_mobile/modules/deals/domain/value_objects/deal_activity_type.dart';
import 'package:solodesk_mobile/modules/deals/presentation/providers/deal_activities_provider.dart';
import 'package:solodesk_mobile/shared/extensions/datetime_extensions.dart';
import 'package:solodesk_mobile/shared/widgets/async_value_widget.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/ui/perforated_divider.dart';
import 'package:solodesk_mobile/ui/section_label.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

/// Tab "Lịch sử" — dòng thời gian hoạt động của thương vụ, nối
/// `GET /deals/{id}/activity`.
///
/// Trước khi backend mở endpoint này (`feat/deals-activity-timeline`), bản
/// web dựng tab tương đương bằng cách ghép localStorage của trình duyệt —
/// xem `web/src/features/deals/dealHistoryStorage.ts:1-4`. Dữ liệu đó nằm
/// trong máy từng người, mobile không đọc được nên KHÔNG cố tái tạo; tab này
/// chỉ hiển thị đúng những gì backend đã thật sự ghi lại.
class DealActivityTab extends ConsumerWidget {
  const DealActivityTab({super.key, required this.dealId});

  final String dealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(dealActivitiesProvider(dealId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppGap.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Lịch sử'),
          const SizedBox(height: AppGap.sectionBottom),
          AsyncValueWidget<List<DealActivity>>(
            value: activitiesAsync,
            onRetry: () => ref.invalidate(dealActivitiesProvider(dealId)),
            loadingWidget: const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            ),
            data: (activities) {
              if (activities.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppGap.xl),
                  child: Center(
                    child: Text(
                      'Chưa có hoạt động nào được ghi lại.',
                      style: AppText.mut,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppGap.card,
                    vertical: AppGap.sm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < activities.length; i++) ...[
                        _ActivityRow(activity: activities[i]),
                        if (i < activities.length - 1)
                          const PerforatedDivider(),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final DealActivity activity;

  SoloIconData get _icon => switch (activity.entryType) {
    DealActivityType.stageChange => SoloIcons.check,
    DealActivityType.noteAdded => SoloIcons.file,
    DealActivityType.documentAttached => SoloIcons.file,
    DealActivityType.aiQualification => SoloIcons.ai,
  };

  @override
  Widget build(BuildContext context) {
    final previous = activity.previousStage;
    final next = activity.newStage;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppGap.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoloIcon(_icon, label: null, size: SoloIcon.sm, color: AppColors.ink3),
          const SizedBox(width: AppGap.row),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(activity.description, style: AppText.bodyStrong),
                if (previous != null && next != null) ...[
                  const SizedBox(height: AppGap.xs),
                  Text(
                    '${previous.label} → ${next.label}',
                    style: AppText.sub,
                  ),
                ],
                const SizedBox(height: AppGap.xs),
                Text(activity.createdAt.toDisplayDateTime(), style: AppText.mut),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
