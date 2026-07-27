import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal_content.dart';

/// Một "lỗ hổng" thông tin trong nội dung báo giá — thứ tự khai báo khớp thứ
/// tự hiển thị trên MÀN 08 (checklist "Thông tin còn thiếu").
enum ProposalGap {
  projectOverview,
  scopeOfWork,
  deliverables,
  timeline,
  pricing,
  paymentTerms,
  assumptions,
  revisionRounds,
  validUntil,
  total,
}

extension ProposalGapX on ProposalGap {
  String get label => switch (this) {
    ProposalGap.projectOverview => 'Tổng quan dự án',
    ProposalGap.scopeOfWork => 'Phạm vi công việc',
    ProposalGap.deliverables => 'Hạng mục bàn giao',
    ProposalGap.timeline => 'Tiến độ',
    ProposalGap.pricing => 'Chi phí',
    ProposalGap.paymentTerms => 'Điều khoản thanh toán',
    ProposalGap.assumptions => 'Giả định',
    ProposalGap.revisionRounds => 'Số vòng sửa',
    ProposalGap.validUntil => 'Hiệu lực đến',
    ProposalGap.total => 'Tổng cộng',
  };

  /// 7 khoá đầu (`index < 7`) là 7 khoá AI generator thật sự sinh ra. Thiếu
  /// một trong 7 khoá này thì `GET /proposals/{id}/pdf` sẽ 500 ở backend
  /// (service đọc content bằng toán tử `[]`, không dùng `.get()` an toàn).
  bool get blocksPdf => index < 7;
}

extension ProposalContentGaps on ProposalContent {
  /// CHỈ 9 gap tính được từ riêng content (loại `total` — total cần ghép
  /// thêm dữ liệu deal, tính ở tầng view-model ngoài domain, xem
  /// [resolveProposalGaps]). Trả về theo đúng thứ tự khai báo enum.
  List<ProposalGap> get gaps {
    final result = <ProposalGap>[];
    if (projectOverview == null) result.add(ProposalGap.projectOverview);
    if (scopeOfWork.isEmpty) result.add(ProposalGap.scopeOfWork);
    if (deliverables.isEmpty) result.add(ProposalGap.deliverables);
    if (timeline == null) result.add(ProposalGap.timeline);
    if (pricing == null) result.add(ProposalGap.pricing);
    if (paymentTerms == null) result.add(ProposalGap.paymentTerms);
    if (assumptions == null) result.add(ProposalGap.assumptions);
    if (revisionRounds == null) result.add(ProposalGap.revisionRounds);
    if (validUntil == null) result.add(ProposalGap.validUntil);
    return result;
  }

  /// Gap nằm trong 7 khoá AI sinh — chặn xuất PDF nếu còn sót.
  List<ProposalGap> get pdfBlockingGaps =>
      gaps.where((g) => g.blocksPdf).toList();

  bool get canExportPdf => pdfBlockingGaps.isEmpty;
}

/// Gộp gap của content với gap `total` — `total` được tính từ [resolvedTotal]
/// do tầng ngoài truyền vào (ví dụ lấy từ `deal.actualValue` /
/// `deal.estimatedValue` khi `content.total == null`), vì entity
/// [ProposalContent] không biết gì về deal.
List<ProposalGap> resolveProposalGaps(
  ProposalContent content, {
  required double? resolvedTotal,
}) => [...content.gaps, if (resolvedTotal == null) ProposalGap.total];
