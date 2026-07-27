import 'package:drift/drift.dart';
import 'package:solodesk_mobile/core/database/app_database.dart';

/// Ba mẫu hệ thống mặc định, gieo vào bảng `templates` khi lần đầu mở màn thư
/// viện mẫu (xem `TemplatesLocalDatasource.ensureSeeded`). `id`/`createdAt` cố
/// định để `insertIfAbsent` (InsertMode.insertOrIgnore) idempotent — gọi lại
/// nhiều lần không tạo bản trùng, và không đè mẫu người dùng đã tự sửa.
const List<TemplateRowsCompanion> systemTemplateSeeds = [
  TemplateRowsCompanion(
    id: Value('sys-proposal-standard'),
    name: Value('Báo giá dịch vụ tiêu chuẩn'),
    category: Value('proposal'),
    body: Value(
      'BÁO GIÁ DỊCH VỤ\n'
      '\n'
      'Kính gửi {{client_name}},\n'
      '\n'
      'Phạm vi công việc: {{scope}}\n'
      'Tiến độ dự kiến: {{timeline}}\n'
      'Chi phí: {{pricing}}\n'
      'Điều khoản thanh toán: {{payment_terms}}\n'
      'Giả định: {{assumptions}}',
    ),
    isSystem: Value(true),
    isDefault: Value(false),
    createdAt: Value('2026-01-01T00:00:00.000Z'),
  ),
  TemplateRowsCompanion(
    id: Value('sys-contract-standard'),
    name: Value('Hợp đồng dịch vụ tiêu chuẩn'),
    category: Value('contract'),
    body: Value(
      'HỢP ĐỒNG DỊCH VỤ\n'
      '\n'
      'Điều 1. Thông tin các bên\n'
      '{{freelancer_name}} và {{client_name}} thống nhất ký kết hợp đồng '
      'này.\n'
      '\n'
      'Điều 2. Phạm vi công việc\n'
      '{{scope}}\n'
      '\n'
      'Điều 3. Tiến độ thực hiện\n'
      '{{timeline}}\n'
      '\n'
      'Điều 4. Điều khoản thanh toán\n'
      '{{payment_terms}}\n'
      '\n'
      'Điều 5. Bảo mật thông tin\n'
      '{{confidentiality}}\n'
      '\n'
      'Điều 6. Sửa đổi và bổ sung\n'
      '{{revision_terms}}\n'
      '\n'
      'Điều 7. Chấm dứt hợp đồng\n'
      '{{termination_terms}}',
    ),
    isSystem: Value(true),
    isDefault: Value(false),
    createdAt: Value('2026-01-01T00:00:00.000Z'),
  ),
  TemplateRowsCompanion(
    id: Value('sys-invoice-standard'),
    name: Value('Hoá đơn dịch vụ tiêu chuẩn'),
    category: Value('invoice'),
    body: Value(
      'HOÁ ĐƠN DỊCH VỤ\n'
      '\n'
      'Khách hàng: {{client_name}}\n'
      'Số hoá đơn: {{invoice_number}}\n'
      'Số tiền: {{amount}}\n'
      'Hạn thanh toán: {{due_date}}',
    ),
    isSystem: Value(true),
    isDefault: Value(false),
    createdAt: Value('2026-01-01T00:00:00.000Z'),
  ),
];
