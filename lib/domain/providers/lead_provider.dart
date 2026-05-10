import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/repositories/mock_lead_repository.dart';
import 'package:mobile/domain/models/lead.dart';
import 'package:mobile/domain/repositories/lead_repository.dart';

/// Provider cho [LeadRepository].
final leadRepositoryProvider = Provider<LeadRepository>((ref) {
  return MockLeadRepository();
});

/// Provider quản lý danh sách Lead.
final leadProvider =
    AsyncNotifierProvider<LeadNotifier, List<Lead>>(LeadNotifier.new);

class LeadNotifier extends AsyncNotifier<List<Lead>> {
  @override
  FutureOr<List<Lead>> build() async {
    final repo = ref.read(leadRepositoryProvider);
    return repo.getLeads();
  }

  /// Tạo lead từ transcript giọng nói (AI extraction).
  Future<Lead?> createLeadFromVoice(String transcript) async {
    final repo = ref.read(leadRepositoryProvider);
    try {
      final lead = await repo.createLeadFromVoice(transcript);
      // Refresh danh sách
      state = AsyncData([lead, ...state.value ?? []]);
      return lead;
    } catch (e) {
      return null;
    }
  }

  /// Tạo lead thủ công.
  Future<Lead?> createLead(Lead lead) async {
    final repo = ref.read(leadRepositoryProvider);
    try {
      final created = await repo.createLead(lead);
      state = AsyncData([created, ...state.value ?? []]);
      return created;
    } catch (e) {
      return null;
    }
  }

  /// Xóa lead.
  Future<void> deleteLead(String id) async {
    final repo = ref.read(leadRepositoryProvider);
    await repo.deleteLead(id);
    state = AsyncData(
      (state.value ?? []).where((l) => l.id != id).toList(),
    );
  }
}
