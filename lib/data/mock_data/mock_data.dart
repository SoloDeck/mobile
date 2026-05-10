import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/domain/models/app_notification.dart';
import 'package:mobile/domain/models/deal.dart';
import 'package:mobile/domain/models/lead.dart';
import 'package:mobile/domain/models/proposal.dart';
import 'package:mobile/domain/models/user.dart';

/// Dữ liệu giả lập tập trung cho toàn bộ ứng dụng.
class MockData {
  MockData._();

  // ─── User ───────────────────────────────────────────────────────────
  static final User mockUser = User(
    id: 'usr_001',
    email: 'test@solodesk.vn',
    fullName: 'Nguyễn Minh Tuấn',
    avatarUrl: null,
    createdAt: DateTime(2024, 1, 15),
  );

  // ─── Deals ──────────────────────────────────────────────────────────
  static final List<Deal> deals = [
    // New Lead
    Deal(
      id: 'deal_001',
      title: 'Thiết kế website bán hàng',
      customerName: 'Nguyễn Văn An',
      customerEmail: 'an.nguyen@gmail.com',
      customerPhone: '0901234567',
      value: 15000000,
      stageId: 'new_lead',
      description: 'Khách hàng cần website bán hàng online cho cửa hàng thời trang.',
      createdAt: DateTime(2025, 5, 1),
    ),
    Deal(
      id: 'deal_002',
      title: 'Landing page sự kiện',
      customerName: 'Trần Thị Bình',
      customerEmail: 'binh.tran@gmail.com',
      value: 5000000,
      stageId: 'new_lead',
      description: 'Landing page cho sự kiện ra mắt sản phẩm mới.',
      createdAt: DateTime(2025, 5, 3),
    ),
    Deal(
      id: 'deal_003',
      title: 'Redesign brand identity',
      customerName: 'Phạm Minh Đức',
      customerPhone: '0912345678',
      value: 25000000,
      stageId: 'new_lead',
      createdAt: DateTime(2025, 5, 5),
    ),

    // Qualified
    Deal(
      id: 'deal_004',
      title: 'App quản lý kho',
      customerName: 'Lê Hoàng Cường',
      customerEmail: 'cuong.le@techcorp.vn',
      customerPhone: '0923456789',
      value: 80000000,
      stageId: 'qualified',
      description: 'Ứng dụng mobile quản lý kho cho chuỗi cửa hàng.',
      createdAt: DateTime(2025, 4, 20),
    ),
    Deal(
      id: 'deal_005',
      title: 'Tư vấn SEO tổng thể',
      customerName: 'Hoàng Thị Lan',
      customerEmail: 'lan.hoang@startup.vn',
      value: 12000000,
      stageId: 'qualified',
      description: 'Tư vấn chiến lược SEO 6 tháng.',
      createdAt: DateTime(2025, 4, 22),
    ),

    // Proposal Sent
    Deal(
      id: 'deal_006',
      title: 'Hệ thống CRM custom',
      customerName: 'Võ Thanh Hải',
      customerEmail: 'hai.vo@bigcorp.vn',
      customerPhone: '0934567890',
      value: 150000000,
      stageId: 'proposal_sent',
      description: 'Phát triển hệ thống CRM tùy chỉnh cho doanh nghiệp lớn.',
      createdAt: DateTime(2025, 4, 10),
    ),
    Deal(
      id: 'deal_007',
      title: 'Chatbot AI cho website',
      customerName: 'Đặng Văn Phong',
      customerEmail: 'phong.dang@ecom.vn',
      value: 35000000,
      stageId: 'proposal_sent',
      createdAt: DateTime(2025, 4, 15),
    ),

    // In Negotiation
    Deal(
      id: 'deal_008',
      title: 'Phát triển app mobile',
      customerName: 'Bùi Thị Mai',
      customerEmail: 'mai.bui@foodtech.vn',
      customerPhone: '0945678901',
      value: 120000000,
      stageId: 'in_negotiation',
      description: 'App đặt đồ ăn online cho chuỗi nhà hàng.',
      createdAt: DateTime(2025, 3, 25),
    ),
    Deal(
      id: 'deal_009',
      title: 'Website thương mại điện tử',
      customerName: 'Trương Minh Khoa',
      customerEmail: 'khoa.truong@retail.vn',
      value: 95000000,
      stageId: 'in_negotiation',
      createdAt: DateTime(2025, 3, 28),
    ),

    // Active
    Deal(
      id: 'deal_010',
      title: 'Quản lý mạng xã hội',
      customerName: 'Ngô Thùy Dung',
      customerEmail: 'dung.ngo@beauty.vn',
      customerPhone: '0956789012',
      value: 8000000,
      stageId: 'active',
      description: 'Quản lý fanpage + content marketing 3 tháng.',
      createdAt: DateTime(2025, 3, 10),
    ),
    Deal(
      id: 'deal_011',
      title: 'Thiết kế UI/UX app',
      customerName: 'Lý Văn Trung',
      customerEmail: 'trung.ly@fintech.vn',
      value: 45000000,
      stageId: 'active',
      createdAt: DateTime(2025, 3, 15),
    ),
    Deal(
      id: 'deal_012',
      title: 'Nâng cấp hệ thống backend',
      customerName: 'Phan Thanh Sơn',
      customerEmail: 'son.phan@logistic.vn',
      customerPhone: '0967890123',
      value: 65000000,
      stageId: 'active',
      createdAt: DateTime(2025, 3, 18),
    ),

    // Completed & Billed
    Deal(
      id: 'deal_013',
      title: 'Logo & bộ nhận diện',
      customerName: 'Đinh Thị Hoa',
      customerEmail: 'hoa.dinh@cafe.vn',
      value: 10000000,
      stageId: 'completed_billed',
      createdAt: DateTime(2025, 2, 1),
      updatedAt: DateTime(2025, 3, 1),
    ),
    Deal(
      id: 'deal_014',
      title: 'Website portfolio',
      customerName: 'Hồ Quốc Bảo',
      customerEmail: 'bao.ho@photo.vn',
      value: 7000000,
      stageId: 'completed_billed',
      createdAt: DateTime(2025, 1, 20),
      updatedAt: DateTime(2025, 2, 20),
    ),
    Deal(
      id: 'deal_015',
      title: 'Email marketing setup',
      customerName: 'Vũ Thị Ngọc',
      customerEmail: 'ngoc.vu@edu.vn',
      value: 3000000,
      stageId: 'completed_billed',
      createdAt: DateTime(2025, 1, 5),
      updatedAt: DateTime(2025, 2, 5),
    ),
  ];

  // ─── Leads ──────────────────────────────────────────────────────────
  static final List<Lead> leads = [
    Lead(
      id: 'lead_001',
      name: 'Trần Quốc Huy',
      phone: '0978123456',
      email: 'huy.tran@startup.vn',
      company: 'TechStartup VN',
      source: LeadSource.voice,
      rawTranscript:
          'Anh Huy bên TechStartup liên hệ muốn làm app di động cho startup, '
          'budget khoảng 100 triệu, cần hoàn thành trong 3 tháng.',
      notes: 'Cần app mobile, budget 100tr, deadline 3 tháng',
      createdAt: DateTime(2025, 5, 8),
    ),
    Lead(
      id: 'lead_002',
      name: 'Nguyễn Thị Hồng',
      phone: '0989234567',
      email: 'hong.nguyen@fashion.vn',
      company: 'Hồng Fashion',
      source: LeadSource.manual,
      notes: 'Cần thiết kế lại website bán hàng, tích hợp thanh toán online.',
      createdAt: DateTime(2025, 5, 7),
    ),
    Lead(
      id: 'lead_003',
      name: 'Lê Minh Tuấn',
      phone: '0990345678',
      source: LeadSource.voice,
      rawTranscript:
          'Tuấn gọi hỏi về dịch vụ quản lý fanpage, '
          'có 3 page cần quản lý, mỗi page post 2 bài/ngày.',
      notes: 'Quản lý 3 fanpage, 2 bài/ngày/page',
      createdAt: DateTime(2025, 5, 6),
    ),
    Lead(
      id: 'lead_004',
      name: 'Phạm Văn Đạt',
      email: 'dat.pham@realestate.vn',
      company: 'Bất động sản Đạt Phát',
      source: LeadSource.webForm,
      notes: 'Đăng ký qua form website, cần landing page cho dự án BĐS mới.',
      createdAt: DateTime(2025, 5, 5),
    ),
    Lead(
      id: 'lead_005',
      name: 'Hoàng Thanh Thảo',
      phone: '0901456789',
      email: 'thao.hoang@clinic.vn',
      company: 'Phòng khám Thanh Thảo',
      source: LeadSource.voice,
      rawTranscript:
          'Chị Thảo bên phòng khám cần hệ thống đặt lịch khám online '
          'và quản lý bệnh nhân, ưu tiên bảo mật dữ liệu.',
      notes: 'Hệ thống đặt lịch khám + quản lý bệnh nhân, cần bảo mật cao',
      createdAt: DateTime(2025, 5, 4),
    ),
  ];

  // ─── Proposals ──────────────────────────────────────────────────────
  static final List<Proposal> proposals = [
    Proposal(
      id: 'prop_001',
      dealId: 'deal_006',
      dealTitle: 'Hệ thống CRM custom',
      customerName: 'Võ Thanh Hải',
      title: 'Đề xuất phát triển CRM - BigCorp',
      content:
          'Kính gửi Anh Hải,\n\n'
          'Cảm ơn Anh đã quan tâm đến dịch vụ phát triển CRM của chúng tôi. '
          'Dựa trên buổi trao đổi, chúng tôi xin gửi đề xuất như sau:\n\n'
          '1. Phạm vi dự án: Phát triển hệ thống CRM tùy chỉnh\n'
          '2. Thời gian: 4 tháng\n'
          '3. Chi phí: 150.000.000 VNĐ\n'
          '4. Bao gồm: Training + Support 3 tháng\n\n'
          'Trân trọng,\nSoloDesk Team',
      status: ProposalStatus.draft,
      createdAt: DateTime(2025, 5, 6),
    ),
    Proposal(
      id: 'prop_002',
      dealId: 'deal_007',
      dealTitle: 'Chatbot AI cho website',
      customerName: 'Đặng Văn Phong',
      title: 'Đề xuất Chatbot AI - ECom',
      content:
          'Kính gửi Anh Phong,\n\n'
          'Chúng tôi xin gửi đề xuất triển khai Chatbot AI cho website:\n\n'
          '1. Chatbot hỗ trợ khách hàng 24/7\n'
          '2. Tích hợp GPT-4 cho câu trả lời tự nhiên\n'
          '3. Training với dữ liệu sản phẩm của Anh\n'
          '4. Chi phí: 35.000.000 VNĐ\n\n'
          'Trân trọng,\nSoloDesk Team',
      status: ProposalStatus.draft,
      createdAt: DateTime(2025, 5, 5),
    ),
    Proposal(
      id: 'prop_003',
      dealId: 'deal_008',
      dealTitle: 'Phát triển app mobile',
      customerName: 'Bùi Thị Mai',
      title: 'Đề xuất App đặt đồ ăn - FoodTech',
      content:
          'Kính gửi Chị Mai,\n\n'
          'Đề xuất phát triển app đặt đồ ăn:\n\n'
          '1. App iOS + Android (Flutter)\n'
          '2. Tích hợp thanh toán online\n'
          '3. Hệ thống quản lý đơn hàng\n'
          '4. Chi phí: 120.000.000 VNĐ\n'
          '5. Thời gian: 5 tháng\n\n'
          'Trân trọng,\nSoloDesk Team',
      status: ProposalStatus.approved,
      createdAt: DateTime(2025, 4, 28),
    ),
    Proposal(
      id: 'prop_004',
      dealId: 'deal_010',
      dealTitle: 'Quản lý mạng xã hội',
      customerName: 'Ngô Thùy Dung',
      title: 'Nhắc nhở thanh toán đợt 2',
      content:
          'Kính gửi Chị Dung,\n\n'
          'Đây là tin nhắn nhắc nhở thanh toán đợt 2 cho dự án '
          'Quản lý mạng xã hội.\n\n'
          'Số tiền: 4.000.000 VNĐ\n'
          'Hạn thanh toán: 15/05/2025\n\n'
          'Trân trọng,\nSoloDesk Team',
      status: ProposalStatus.draft,
      createdAt: DateTime(2025, 5, 8),
    ),
    Proposal(
      id: 'prop_005',
      dealId: 'deal_011',
      dealTitle: 'Thiết kế UI/UX app',
      customerName: 'Lý Văn Trung',
      title: 'Cập nhật tiến độ dự án UI/UX',
      content:
          'Kính gửi Anh Trung,\n\n'
          'Cập nhật tiến độ thiết kế UI/UX:\n\n'
          '- Wireframe: Hoàn thành 100%\n'
          '- UI Design: Hoàn thành 60%\n'
          '- Prototype: Đang thực hiện\n\n'
          'Dự kiến bàn giao prototype vào 20/05/2025.\n\n'
          'Trân trọng,\nSoloDesk Team',
      status: ProposalStatus.sent,
      createdAt: DateTime(2025, 5, 2),
      sentAt: DateTime(2025, 5, 3),
    ),
  ];

  // ─── Notifications ──────────────────────────────────────────────────
  static final List<AppNotification> notifications = [
    AppNotification(
      id: 'noti_001',
      title: 'Thanh toán quá hạn',
      body: 'Deal "Quản lý mạng xã hội" - Đợt 2 đã quá hạn thanh toán 3 ngày.',
      type: NotificationType.paymentOverdue,
      isRead: false,
      createdAt: DateTime(2025, 5, 9, 9, 0),
      referenceId: 'deal_010',
    ),
    AppNotification(
      id: 'noti_002',
      title: 'Lead mới từ website',
      body: 'Phạm Văn Đạt đã đăng ký qua form liên hệ trên website.',
      type: NotificationType.newLead,
      isRead: false,
      createdAt: DateTime(2025, 5, 9, 8, 30),
      referenceId: 'lead_004',
    ),
    AppNotification(
      id: 'noti_003',
      title: 'Nhắc nhở liên hệ',
      body: 'Hôm nay cần liên hệ Lê Hoàng Cường về dự án App quản lý kho.',
      type: NotificationType.reminder,
      isRead: false,
      createdAt: DateTime(2025, 5, 9, 7, 0),
      referenceId: 'deal_004',
    ),
    AppNotification(
      id: 'noti_004',
      title: 'Thanh toán quá hạn',
      body: 'Deal "Nâng cấp hệ thống backend" - Đợt 1 chưa thanh toán.',
      type: NotificationType.paymentOverdue,
      isRead: true,
      createdAt: DateTime(2025, 5, 8, 14, 0),
      referenceId: 'deal_012',
    ),
    AppNotification(
      id: 'noti_005',
      title: 'Lead mới từ giọng nói',
      body: 'Bạn vừa tạo lead mới: Trần Quốc Huy - TechStartup VN.',
      type: NotificationType.newLead,
      isRead: true,
      createdAt: DateTime(2025, 5, 8, 10, 15),
      referenceId: 'lead_001',
    ),
    AppNotification(
      id: 'noti_006',
      title: 'Nhắc nhở theo dõi',
      body: 'Cần follow-up với Hoàng Thị Lan về tư vấn SEO.',
      type: NotificationType.reminder,
      isRead: true,
      createdAt: DateTime(2025, 5, 7, 9, 0),
      referenceId: 'deal_005',
    ),
    AppNotification(
      id: 'noti_007',
      title: 'Đề xuất đã gửi',
      body: 'Đề xuất "Cập nhật tiến độ dự án UI/UX" đã được gửi cho Lý Văn Trung.',
      type: NotificationType.reminder,
      isRead: true,
      createdAt: DateTime(2025, 5, 3, 16, 0),
      referenceId: 'prop_005',
    ),
    AppNotification(
      id: 'noti_008',
      title: 'Lead mới từ website',
      body: 'Hoàng Thanh Thảo - Phòng khám Thanh Thảo đã đăng ký tư vấn.',
      type: NotificationType.newLead,
      isRead: true,
      createdAt: DateTime(2025, 5, 4, 11, 0),
      referenceId: 'lead_005',
    ),
  ];
}
