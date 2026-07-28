import 'package:flutter/material.dart';
import 'package:solodesk_mobile/modules/invoices/domain/value_objects/invoice_status.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// Ngữ nghĩa màu + icon của một trạng thái hóa đơn, dùng chung cho chip trạng
/// thái và ô icon dẫn đầu trong `InvoiceCard`.
///
/// [InvoiceStatus.overdue] cố ý dùng [Tone.money] (hồng) chứ không phải màu
/// lỗi đỏ — quá hạn nghĩa là "tiền đang phải đòi", đúng quy ước tô màu tiền
/// của app, không phải một lỗi hệ thống.
extension InvoiceStatusVisual on InvoiceStatus {
  Tone get tone => switch (this) {
    InvoiceStatus.draft => Tone.neutral,
    InvoiceStatus.sent => Tone.neutral,
    InvoiceStatus.partiallyPaid => Tone.warn,
    InvoiceStatus.paid => Tone.ok,
    InvoiceStatus.overdue => Tone.money,
    InvoiceStatus.voided => Tone.neutral,
  };

  SoloIconData get icon => switch (this) {
    InvoiceStatus.draft => SoloIcons.file,
    InvoiceStatus.sent => SoloIcons.send,
    InvoiceStatus.partiallyPaid => SoloIcons.clock,
    InvoiceStatus.paid => SoloIcons.check,
    InvoiceStatus.overdue => SoloIcons.clock,
    InvoiceStatus.voided => SoloIcons.dots,
  };
}

/// A compact status chip (icon + label) for cards and the detail header.
class InvoiceStatusBadge extends StatelessWidget {
  const InvoiceStatusBadge({super.key, required this.status});

  final InvoiceStatus status;

  @override
  Widget build(BuildContext context) {
    // StatusChip alone only exposes its visible label to screen readers; add
    // an explicit "Trạng thái: …" label so the status reads unambiguously,
    // and exclude the chip's own (redundant) semantics to avoid double
    // announcement.
    return Semantics(
      label: 'Trạng thái: ${status.label}',
      child: ExcludeSemantics(
        child: StatusChip(status.label, tone: status.tone, icon: status.icon),
      ),
    );
  }
}
