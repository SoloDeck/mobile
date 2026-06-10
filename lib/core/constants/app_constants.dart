/// Các hằng số và enum dùng chung trong ứng dụng SoloDesk Mobile.
library;

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Pipeline Stages
// ---------------------------------------------------------------------------

/// Thông tin một giai đoạn trong pipeline.
class PipelineStageInfo {
  final String id;
  final String name;
  final String nameVi;
  final int order;
  final Color color;
  final IconData icon;

  const PipelineStageInfo({
    required this.id,
    required this.name,
    required this.nameVi,
    required this.order,
    required this.color,
    required this.icon,
  });
}

/// Danh sách 6 giai đoạn pipeline mặc định.
class AppConstants {
  AppConstants._();

  static const String appName = 'SoloDesk';

  /// Thời gian giả lập network delay (mock).
  static const Duration mockNetworkDelay = Duration(seconds: 1);

  /// Tỷ lệ lỗi giả lập (10%).
  static const double mockErrorRate = 0.10;

  static const List<PipelineStageInfo> pipelineStages = [
    PipelineStageInfo(
      id: 'new_lead',
      name: 'New Lead',
      nameVi: 'Khách hàng mới',
      order: 0,
      color: Color(0xFF6366F1), // Indigo
      icon: Icons.person_add_outlined,
    ),
    PipelineStageInfo(
      id: 'qualified',
      name: 'Qualified',
      nameVi: 'Đã đánh giá',
      order: 1,
      color: Color(0xFF8B5CF6), // Violet
      icon: Icons.verified_outlined,
    ),
    PipelineStageInfo(
      id: 'proposal_sent',
      name: 'Proposal Sent',
      nameVi: 'Đã gửi đề xuất',
      order: 2,
      color: Color(0xFFF59E0B), // Amber
      icon: Icons.send_outlined,
    ),
    PipelineStageInfo(
      id: 'in_negotiation',
      name: 'In Negotiation',
      nameVi: 'Đang thương lượng',
      order: 3,
      color: Color(0xFFF97316), // Orange
      icon: Icons.handshake_outlined,
    ),
    PipelineStageInfo(
      id: 'active',
      name: 'Active',
      nameVi: 'Đang hoạt động',
      order: 4,
      color: Color(0xFF10B981), // Emerald
      icon: Icons.rocket_launch_outlined,
    ),
    PipelineStageInfo(
      id: 'completed_billed',
      name: 'Completed & Billed',
      nameVi: 'Hoàn thành & Thanh toán',
      order: 5,
      color: Color(0xFF3B82F6), // Blue
      icon: Icons.check_circle_outlined,
    ),
  ];

  /// Tìm stage info theo id.
  static PipelineStageInfo? stageById(String id) {
    try {
      return pipelineStages.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// Notification Type
// ---------------------------------------------------------------------------

enum NotificationType { paymentOverdue, reminder, newLead }

// ---------------------------------------------------------------------------
// Lead Source
// ---------------------------------------------------------------------------

enum LeadSource { voice, manual, webForm }

// ---------------------------------------------------------------------------
// Proposal Status
// ---------------------------------------------------------------------------

enum ProposalStatus { draft, approved, sent }

// ---------------------------------------------------------------------------
// Lead Score — output của AI Lead Qualifier (be-py: lead_qualifier/chain.py)
// ---------------------------------------------------------------------------

/// Mức độ tiềm năng của lead, do AI Lead Qualifier chấm điểm.
enum LeadScore {
  hot, // Khách hàng tiềm năng cao — nên ưu tiên
  warm, // Khách hàng trung bình — cần thêm thông tin
  cold, // Khách hàng ít tiềm năng — cân nhắc bỏ qua
}

// ---------------------------------------------------------------------------
// Lead Urgency — độ khẩn cấp trích xuất từ transcript
// ---------------------------------------------------------------------------

enum LeadUrgency {
  low, // Không gấp
  medium, // Bình thường
  high, // Gấp / cần xử lý ngay
}
