import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/deals/domain/entities/deal.dart';
import 'package:solodesk_mobile/modules/deals/presentation/providers/deals_provider.dart';
import 'package:solodesk_mobile/modules/proposals/application/usecases/get_proposal_usecase.dart';
import 'package:solodesk_mobile/modules/proposals/application/usecases/list_proposals_usecase.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/payment_schedule.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_gap.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_query.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/repository/proposals_repository_impl.dart';
import 'package:solodesk_mobile/modules/templates/domain/entities/template.dart';
import 'package:solodesk_mobile/modules/templates/domain/value_objects/template_category.dart';
import 'package:solodesk_mobile/modules/templates/presentation/providers/templates_provider.dart';

part 'proposals_provider.g.dart';

/// Một báo giá theo [id] — dùng khi mở riêng MÀN 08.
@riverpod
Future<Proposal> proposalDetail(Ref ref, String id) =>
    GetProposalUseCase(ref.watch(proposalsRepositoryProvider))(id);

/// Toàn bộ báo giá của một deal — dùng để làm mới danh sách sau khi gửi.
@riverpod
Future<ProposalListPage> dealProposals(Ref ref, String dealId) =>
    ListProposalsUseCase(ref.watch(proposalsRepositoryProvider))(
      filter: ProposalListFilter(dealId: dealId),
    );

/// Gộp dữ liệu cho MÀN 08: báo giá + thương vụ + mẫu mặc định (nếu có) + tổng
/// tiền đã giải quyết + lịch thanh toán + danh sách ô còn trống.
class ProposalReviewData {
  const ProposalReviewData({
    required this.proposal,
    required this.deal,
    required this.template,
    required this.total,
    required this.schedule,
    required this.gaps,
  });

  final Proposal proposal;
  final Deal deal;
  final Template? template;
  final double? total;
  final PaymentSchedule schedule;
  final List<ProposalGap> gaps;
}

@riverpod
Future<ProposalReviewData> proposalReview(Ref ref, String id) async {
  final proposal = await ref.watch(proposalDetailProvider(id).future);
  final deal = await ref.watch(dealDetailProvider(proposal.dealId).future);
  final content = proposal.content;

  double? total = content.total ?? deal.actualValue ?? deal.estimatedValue;
  // Phương án chót — KHÔNG bao giờ double.parse(content.pricing) trực tiếp,
  // "pricing" là chuỗi tự do; chỉ thử bóc một cụm số đủ dài (>=7 chữ số) rồi
  // bỏ dấu chấm phân cách nghìn.
  if (total == null && content.pricing != null) {
    final match = RegExp(r'[\d.]{7,}').firstMatch(content.pricing!);
    if (match != null) {
      total = double.tryParse(match.group(0)!.replaceAll('.', ''));
    }
  }

  Template? template;
  try {
    final templates = await ref.watch(
      templatesProvider(TemplateCategory.proposal).future,
    );
    template =
        templates.where((t) => t.isDefault).firstOrNull ??
        templates.where((t) => t.isSystem).firstOrNull;
  } on Object {
    template = null; // màn vẫn hiển thị được, chỉ thiếu chip "Mẫu: ..."
  }

  final schedule = PaymentSchedule.parse(content.paymentTerms);
  final gaps = resolveProposalGaps(content, resolvedTotal: total);

  return ProposalReviewData(
    proposal: proposal,
    deal: deal,
    template: template,
    total: total,
    schedule: schedule,
    gaps: gaps,
  );
}
