import 'dart:math';

import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/data/mock_data/mock_data.dart';
import 'package:mobile/domain/models/lead.dart';
import 'package:mobile/domain/repositories/lead_repository.dart';

/// Mock implementation của [LeadRepository].
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
    // Giả lập AI processing — mất thêm 1.5s
    await Future.delayed(const Duration(milliseconds: 2500));

    // Mock AI extraction: trích xuất thông tin từ transcript
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
    );

    _leads.add(lead);
    return lead;
  }

  @override
  Future<void> deleteLead(String id) async {
    await Future.delayed(AppConstants.mockNetworkDelay);
    _leads.removeWhere((l) => l.id == id);
  }

  // ── Mock AI extraction helpers ──────────────────────────────────────

  String _extractName(String transcript) {
    // Tìm patterns phổ biến: "anh/chị X", "tên Y"
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
