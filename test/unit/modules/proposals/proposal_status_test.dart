import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_status.dart';

void main() {
  test('allowedTargets đúng máy trạng thái backend', () {
    expect(ProposalStatus.draft.allowedTargets, {ProposalStatus.sent});
    expect(ProposalStatus.sent.allowedTargets, {
      ProposalStatus.accepted,
      ProposalStatus.rejected,
      ProposalStatus.expired,
    });
    expect(ProposalStatus.accepted.allowedTargets, isEmpty);
    expect(ProposalStatus.rejected.allowedTargets, isEmpty);
    expect(ProposalStatus.expired.allowedTargets, isEmpty);
    expect(ProposalStatus.superseded.allowedTargets, isEmpty);
  });

  test('canEdit chỉ true khi draft', () {
    expect(ProposalStatus.draft.canEdit, isTrue);
    for (final s in ProposalStatus.values) {
      if (s == ProposalStatus.draft) continue;
      expect(s.canEdit, isFalse, reason: '$s không được phép canEdit');
    }
  });

  test('canSend chỉ true khi draft', () {
    expect(ProposalStatus.draft.canSend, isTrue);
    for (final s in ProposalStatus.values) {
      if (s == ProposalStatus.draft) continue;
      expect(s.canSend, isFalse, reason: '$s không được phép canSend');
    }
  });

  test('wireValue khớp đúng chuỗi backend cho cả 6 giá trị', () {
    expect(ProposalStatus.draft.wireValue, 'draft');
    expect(ProposalStatus.sent.wireValue, 'sent');
    expect(ProposalStatus.accepted.wireValue, 'accepted');
    expect(ProposalStatus.rejected.wireValue, 'rejected');
    expect(ProposalStatus.expired.wireValue, 'expired');
    expect(ProposalStatus.superseded.wireValue, 'superseded');
  });

  test('proposalStatusFromWire là nghịch đảo đúng của wireValue', () {
    for (final s in ProposalStatus.values) {
      expect(proposalStatusFromWire(s.wireValue), s);
    }
  });

  test('proposalStatusFromWire ném lỗi hợp lý với chuỗi không khớp', () {
    expect(
      () => proposalStatusFromWire('not-a-real-status'),
      throwsA(isA<ArgumentError>()),
    );
  });
}
