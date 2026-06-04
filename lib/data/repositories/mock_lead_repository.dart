import 'dart:math';

import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/data/mock_data/mock_data.dart';
import 'package:mobile/domain/models/lead.dart';
import 'package:mobile/domain/repositories/lead_repository.dart';

/// Mock implementation của [LeadRepository].
///
/// createLeadFromVoice() giả lập đầy đủ output của be-py AIFacade.qualify_lead():
/// leadScore (Hot/Warm/Cold), scoreRationale, projectType, estimatedScope,
/// budgetSignal, urgency, suggestedPriceMin/Max, redFlags.
class MockLeadRepository implements LeadRepository {
  final _random = Random();
  final List<Lead> _leads = List.from(MockData.leads);

  @override
  Future<List<Lead>> getLeads() async {
    await Future.delayed(AppConstants.mockNetworkDelay);
    return List.unmodifiable(
      _leads..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  @override
  Future<Lead> createLead(Lead lead) async {
    await Future.delayed(AppConstants.mockNetworkDelay);
    _leads.add(lead);
    return lead;
  }

  @override
  Future<Lead> createLeadFromVoice(String transcript) async {
    // Giả lập AI processing — gồm speech-to-lead + qualify_lead chain
    await Future.delayed(const Duration(milliseconds: 2500));

    final qualification = _mockQualifyLead(transcript);

    final lead = Lead(
      id: 'lead_${DateTime.now().millisecondsSinceEpoch}',
      name: _extractName(transcript),
      phone: _extractPhone(transcript),
      email: null,
      company: _extractCompany(transcript),
      source: LeadSource.voice,
      rawTranscript: transcript,
      notes: transcript,
      createdAt: DateTime.now(),
      // AI Qualification fields — mirror be-py lead_qualifier/chain.py output
      leadScore: qualification.score,
      scoreRationale: qualification.rationale,
      projectType: qualification.projectType,
      estimatedScope: qualification.estimatedScope,
      budgetSignal: qualification.budgetSignal,
      urgency: qualification.urgency,
      suggestedPriceMin: qualification.priceMin,
      suggestedPriceMax: qualification.priceMax,
      redFlags: qualification.redFlags,
      isQualified: true,
    );

    _leads.add(lead);
    return lead;
  }

  @override
  Future<void> deleteLead(String id) async {
    await Future.delayed(AppConstants.mockNetworkDelay);
    _leads.removeWhere((l) => l.id == id);
  }

  // ── Mock AI Lead Qualifier (mirrors be-py AIFacade.qualify_lead output) ───

  _LeadQualification _mockQualifyLead(String transcript) {
    final t = transcript.toLowerCase();

    // Phát hiện red flags
    final redFlags = <String>[];
    if (t.contains('rẻ') || t.contains('giảm giá') || t.contains('phí thấp') ||
        t.contains('giá rẻ') || t.contains('discount')) {
      redFlags.add('Khách đang tìm giá rẻ — có thể trả giá nhiều');
    }
    if (t.contains('không biết') || t.contains('chưa rõ') || t.contains('tùy bạn') ||
        t.contains('tùy anh') || t.contains('tùy chị')) {
      redFlags.add('Mô tả yêu cầu chưa rõ ràng');
    }
    if (t.contains('gấp') || t.contains('urgently') || t.contains('ngay')) {
      redFlags.add('Khách yêu cầu gấp — cần xác nhận timeline thực tế');
    }

    // Phát hiện project type
    final projectType = _detectProjectType(t);

    // Phát hiện urgency
    final urgency = _detectUrgency(t);

    // Phát hiện budget signal
    String budgetSignal;
    int priceMin, priceMax;
    if (RegExp(r'\d+\s*(?:triệu|tr|m)').hasMatch(t)) {
      budgetSignal = 'Khách đã đề cập ngân sách cụ thể';
      priceMin = _extractBudget(t) ?? 5000000;
      priceMax = priceMin + (priceMin ~/ 2);
    } else if (t.contains('ngân sách') || t.contains('budget')) {
      budgetSignal = 'Khách đề cập ngân sách nhưng chưa rõ con số';
      priceMin = _defaultPriceMin(projectType);
      priceMax = _defaultPriceMax(projectType);
    } else {
      budgetSignal = 'Chưa đề cập ngân sách — cần khai thác thêm';
      priceMin = _defaultPriceMin(projectType);
      priceMax = _defaultPriceMax(projectType);
    }

    final estimatedScope = _estimateScope(t, projectType);

    // Tính lead score dựa trên tổng hợp tín hiệu
    final LeadScore score;
    final String rationale;

    if (redFlags.length >= 2) {
      score = LeadScore.cold;
      rationale =
          'Lead có ${redFlags.length} dấu hiệu cảnh báo: ${redFlags.join("; ")}. '
          'Nên xác nhận lại yêu cầu và ngân sách trước khi đầu tư thêm thời gian.';
    } else if (redFlags.isEmpty &&
        budgetSignal.startsWith('Khách đã đề cập ngân sách cụ thể') &&
        urgency != LeadUrgency.low) {
      score = LeadScore.hot;
      rationale =
          'Lead có ngân sách rõ ràng, yêu cầu cụ thể và mức độ khẩn cấp ${ urgency == LeadUrgency.high ? "cao" : "vừa"}. '
          'Nên ưu tiên liên hệ lại trong vòng 24 giờ để chốt scope và timeline.';
    } else {
      score = LeadScore.warm;
      rationale =
          'Lead có tiềm năng nhưng cần thêm thông tin về ngân sách và phạm vi. '
          '${redFlags.isEmpty ? "Không có dấu hiệu cảnh báo." : "Lưu ý: ${redFlags.first}."} '
          'Gợi ý liên hệ để làm rõ yêu cầu trước khi lập đề xuất.';
    }

    return _LeadQualification(
      score: score,
      rationale: rationale,
      projectType: projectType,
      estimatedScope: estimatedScope,
      budgetSignal: budgetSignal,
      urgency: urgency,
      priceMin: priceMin,
      priceMax: priceMax,
      redFlags: redFlags.isEmpty ? null : redFlags,
    );
  }

  String _detectProjectType(String t) {
    if (t.contains('website') || t.contains('web')) return 'Thiết kế Website';
    if (t.contains('app') || t.contains('mobile') || t.contains('ứng dụng')) {
      return 'Phát triển App Mobile';
    }
    if (t.contains('logo') || t.contains('brand') || t.contains('nhận diện')) {
      return 'Thiết kế Brand Identity';
    }
    if (t.contains('seo') || t.contains('marketing') || t.contains('quảng cáo')) {
      return 'Tư vấn Digital Marketing';
    }
    if (t.contains('video') || t.contains('clip') || t.contains('quay')) {
      return 'Sản xuất Video';
    }
    if (t.contains('content') || t.contains('bài viết') || t.contains('copywriting')) {
      return 'Viết Content / Copywriting';
    }
    return 'Dịch vụ khác';
  }

  LeadUrgency _detectUrgency(String t) {
    if (t.contains('gấp') || t.contains('ngay') || t.contains('sớm nhất') ||
        t.contains('urgent') || t.contains('tuần này')) {
      return LeadUrgency.high;
    }
    if (t.contains('tháng này') || t.contains('sắp') || t.contains('tháng tới')) {
      return LeadUrgency.medium;
    }
    return LeadUrgency.low;
  }

  String _estimateScope(String t, String projectType) {
    if (t.contains('đơn giản') || t.contains('basic') || t.contains('nhỏ')) {
      return 'Quy mô nhỏ — $projectType cơ bản';
    }
    if (t.contains('lớn') || t.contains('phức tạp') || t.contains('enterprise') ||
        t.contains('hệ thống')) {
      return 'Quy mô lớn — $projectType đầy đủ tính năng';
    }
    return 'Quy mô trung bình — $projectType tiêu chuẩn';
  }

  int? _extractBudget(String t) {
    final match = RegExp(r'(\d+(?:[.,]\d+)?)\s*(?:triệu|tr\b)').firstMatch(t);
    if (match == null) return null;
    final raw = match.group(1)!.replaceAll(',', '').replaceAll('.', '');
    final millions = int.tryParse(raw);
    return millions != null ? millions * 1000000 : null;
  }

  int _defaultPriceMin(String projectType) {
    return switch (projectType) {
      'Phát triển App Mobile' => 30000000,
      'Thiết kế Website' => 8000000,
      'Tư vấn Digital Marketing' => 10000000,
      'Thiết kế Brand Identity' => 5000000,
      'Sản xuất Video' => 5000000,
      _ => 3000000,
    };
  }

  int _defaultPriceMax(String projectType) {
    return switch (projectType) {
      'Phát triển App Mobile' => 80000000,
      'Thiết kế Website' => 25000000,
      'Tư vấn Digital Marketing' => 30000000,
      'Thiết kế Brand Identity' => 15000000,
      'Sản xuất Video' => 20000000,
      _ => 10000000,
    };
  }

  // ── Mock extraction helpers ──────────────────────────────────────────────

  String _extractName(String transcript) {
    final patterns = [
      RegExp(r'(?:anh|chị|bạn)\s+(\w+(?:\s+\w+)?)', caseSensitive: false),
      RegExp(r'tên\s+(?:là\s+)?(\w+(?:\s+\w+)?)', caseSensitive: false),
    ];
    for (final p in patterns) {
      final match = p.firstMatch(transcript);
      if (match != null) return match.group(1) ?? 'Khách hàng mới';
    }
    return 'Khách hàng mới #${_random.nextInt(999)}';
  }

  String? _extractPhone(String transcript) {
    final match = RegExp(r'0\d{9,10}').firstMatch(transcript);
    return match?.group(0);
  }

  String? _extractCompany(String transcript) {
    final patterns = [
      RegExp(r'(?:công ty|cty|bên)\s+(\w+(?:\s+\w+){0,3})',
          caseSensitive: false),
    ];
    for (final p in patterns) {
      final match = p.firstMatch(transcript);
      if (match != null) return match.group(1);
    }
    return null;
  }
}

/// Kết quả mock từ Lead Qualifier chain (tương đương output dict của be-py).
class _LeadQualification {
  final LeadScore score;
  final String rationale;
  final String projectType;
  final String estimatedScope;
  final String budgetSignal;
  final LeadUrgency urgency;
  final int priceMin;
  final int priceMax;
  final List<String>? redFlags;

  const _LeadQualification({
    required this.score,
    required this.rationale,
    required this.projectType,
    required this.estimatedScope,
    required this.budgetSignal,
    required this.urgency,
    required this.priceMin,
    required this.priceMax,
    this.redFlags,
  });
}
