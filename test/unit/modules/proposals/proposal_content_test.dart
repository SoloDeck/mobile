import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal_content.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_gap.dart';

/// 10 khoá `content` đầy đủ — dùng làm baseline cho các test "thiếu từng
/// khoá một" bên dưới.
const _fullMap = <String, dynamic>{
  'project_overview': 'Tổng quan dự án ABC',
  'scope_of_work': ['Logo', 'Brand guideline'],
  'deliverables': ['File AI', 'File PDF'],
  'timeline': '01/07 → 31/07',
  'pricing': '15,000,000 VNĐ trọn gói',
  'payment_terms': 'Cọc 50%, duyệt nháp 30%, bàn giao 20%',
  'assumptions': 'Khách cung cấp brief đầy đủ trước khi bắt đầu',
  'revision_rounds': 2,
  'valid_until': '2026-08-08T00:00:00.000Z',
  'total': 15000000,
};

void main() {
  group('ProposalContentX.fromMap({})', () {
    test('mọi field null/rỗng, gaps trả về 9 phần tử', () {
      final content = ProposalContentX.fromMap(const {});

      expect(content.projectOverview, isNull);
      expect(content.scopeOfWork, isEmpty);
      expect(content.deliverables, isEmpty);
      expect(content.timeline, isNull);
      expect(content.pricing, isNull);
      expect(content.paymentTerms, isNull);
      expect(content.assumptions, isNull);
      expect(content.revisionRounds, isNull);
      expect(content.validUntil, isNull);
      expect(content.total, isNull);
      expect(content.unknown, isEmpty);
      expect(content.gaps, hasLength(9));
    });
  });

  group('thiếu TỪNG khoá một trong 7 khoá AI', () {
    // Baseline: tất cả 10 khoá đều có giá trị. Mỗi test bên dưới xoá đúng
    // MỘT khoá và kỳ vọng đúng field đó null/rỗng, các field khác giữ
    // nguyên như baseline (so bằng freezed copyWith + equality).
    final baseline = ProposalContentX.fromMap(_fullMap);

    Map<String, dynamic> without(String key) => {..._fullMap}..remove(key);

    test('thiếu project_overview -> null, còn lại giữ nguyên', () {
      final content = ProposalContentX.fromMap(without('project_overview'));
      expect(content, baseline.copyWith(projectOverview: null));
    });

    test('thiếu scope_of_work -> rỗng, còn lại giữ nguyên', () {
      final content = ProposalContentX.fromMap(without('scope_of_work'));
      expect(content, baseline.copyWith(scopeOfWork: const []));
    });

    test('thiếu deliverables -> rỗng, còn lại giữ nguyên', () {
      final content = ProposalContentX.fromMap(without('deliverables'));
      expect(content, baseline.copyWith(deliverables: const []));
    });

    test('thiếu timeline -> null, còn lại giữ nguyên', () {
      final content = ProposalContentX.fromMap(without('timeline'));
      expect(content, baseline.copyWith(timeline: null));
    });

    test('thiếu pricing -> null, còn lại giữ nguyên', () {
      final content = ProposalContentX.fromMap(without('pricing'));
      expect(content, baseline.copyWith(pricing: null));
    });

    test('thiếu payment_terms -> null, còn lại giữ nguyên', () {
      final content = ProposalContentX.fromMap(without('payment_terms'));
      expect(content, baseline.copyWith(paymentTerms: null));
    });

    test('thiếu assumptions -> null, còn lại giữ nguyên', () {
      final content = ProposalContentX.fromMap(without('assumptions'));
      expect(content, baseline.copyWith(assumptions: null));
    });
  });

  group('sentinel "Thông tin chưa được cung cấp" ở project_overview', () {
    for (final variant in <String>[
      'Thông tin chưa được cung cấp',
      'THÔNG TIN CHƯA ĐƯỢC CUNG CẤP',
      '  Thông tin chưa được cung cấp  ',
      'thông tin CHƯA được cung cấp',
    ]) {
      test('"$variant" -> coi như null', () {
        final content = ProposalContentX.fromMap({'project_overview': variant});
        expect(content.projectOverview, isNull);
      });
    }
  });

  test('scope_of_work là String thay vì List -> _strList tách theo dòng', () {
    final content = ProposalContentX.fromMap({
      'scope_of_work': 'Logo\nBrand guideline',
    });
    expect(content.scopeOfWork, ['Logo', 'Brand guideline']);
  });

  test('khoá lạ nằm trong unknown và round-trip qua toMap()', () {
    final content = ProposalContentX.fromMap({
      'project_overview': 'ABC',
      'extra_field': 'x',
    });

    expect(content.unknown, {'extra_field': 'x'});

    final map = content.toMap();
    expect(map['extra_field'], 'x');
  });

  test('toMap() đầy đủ 10 khoá + unknown, không ghi khoá null', () {
    final content = ProposalContentX.fromMap({
      ..._fullMap,
      'legacy_key': 'giữ nguyên',
    });

    final map = content.toMap();

    expect(map.keys.toSet(), {
      'project_overview',
      'scope_of_work',
      'deliverables',
      'timeline',
      'pricing',
      'payment_terms',
      'assumptions',
      'revision_rounds',
      'valid_until',
      'total',
      'legacy_key',
    });
    expect(map.values, isNot(contains(null)));
    expect(map['legacy_key'], 'giữ nguyên');
    expect(
      map['valid_until'],
      DateTime.parse('2026-08-08T00:00:00.000Z').toIso8601String(),
    );
  });

  test('ví dụ CHÍNH XÁC dùng lại cho golden test proposals sau: '
      'gaps == [deliverables, revisionRounds]', () {
    // Fixture này được thiết kế có chủ đích: mọi field đều có giá trị TRỪ
    // deliverables (rỗng) và revisionRounds (null) — để gaps() chỉ trả về
    // đúng 2 phần tử theo đúng thứ tự khai báo enum ProposalGap.
    const content = ProposalContent(
      projectOverview: 'Xây dựng bộ nhận diện thương hiệu cho quán cà phê.',
      scopeOfWork: ['Logo', 'Brand guideline'],
      deliverables: [],
      timeline: '01/07 → 31/07',
      pricing: '15,000,000 VNĐ trọn gói',
      paymentTerms: 'Cọc 50%, duyệt nháp 30%, bàn giao 20%',
      assumptions: 'Khách cung cấp brief đầy đủ trước khi bắt đầu.',
      revisionRounds: null,
      validUntil: null,
    );
    final withValidUntil = content.copyWith(validUntil: DateTime(2026, 8, 8));

    expect(withValidUntil.gaps, [
      ProposalGap.deliverables,
      ProposalGap.revisionRounds,
    ]);
  });
}
