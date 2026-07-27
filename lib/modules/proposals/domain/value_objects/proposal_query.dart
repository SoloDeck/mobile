import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_status.dart';

/// Bộ lọc danh sách báo giá trên MÀN 08. [status] và [dealId] là hai trục lọc
/// mobile hiển thị; backend hỗ trợ thêm nhưng chưa cần cho v1.
class ProposalListFilter {
  const ProposalListFilter({this.status, this.dealId});

  final ProposalStatus? status;
  final String? dealId;

  /// Predicate dùng để lọc cache offline theo đúng cách backend sẽ lọc.
  bool matches(Proposal p) =>
      (status == null || p.status == status) &&
      (dealId == null || p.dealId == dealId);

  @override
  bool operator ==(Object other) =>
      other is ProposalListFilter &&
      other.status == status &&
      other.dealId == dealId;

  @override
  int get hashCode => Object.hash(status, dealId);
}

/// Một trang báo giá cùng cờ còn trang tiếp theo hay không — phục vụ infinite
/// scroll của danh sách.
class ProposalListPage {
  const ProposalListPage({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  final List<Proposal> items;
  final int page;
  final bool hasMore;
}
