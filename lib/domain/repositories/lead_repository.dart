import 'package:mobile/domain/models/lead.dart';

/// Interface cho repository quản lý Lead.
abstract class LeadRepository {
  /// Lấy tất cả leads.
  Future<List<Lead>> getLeads();

  /// Tạo lead mới từ dữ liệu thủ công.
  Future<Lead> createLead(Lead lead);

  /// Tạo lead từ transcript giọng nói (AI sẽ trích xuất thông tin).
  Future<Lead> createLeadFromVoice(String transcript);

  /// Xóa lead.
  Future<void> deleteLead(String id);
}
