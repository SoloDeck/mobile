abstract final class RouteNames {
  static const splash = '/';

  /// MÀN 01 — màn đăng nhập gốc (Google trên cùng, email là lối phụ).
  static const login = '/login';

  /// Form email + mật khẩu, mở ra từ MÀN 01.
  static const loginEmail = '/login/email';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/auth/reset-password';

  static const home = '/home';

  /// MÀN 15 — biến thể ngoại tuyến của trang chủ. Màn riêng chứ không phải cờ
  /// trên [home] vì nó tự mang `SoloNavBar(offline: true)`.
  ///
  /// Đường dẫn `/offline` chứ không phải `/home/offline`: `/home` là một nhánh
  /// của `StatefulShellRoute`, để màn này thành đường dẫn con của nó thì nó sẽ
  /// dựng *bên trong* shell và dính luôn thanh tab thứ hai.
  static const offline = '/offline';

  /// MÀN 03 — thông báo đẩy.
  static const notifications = '/notifications';

  static const clients = '/clients';
  static const clientDetail = '/clients/:id';

  static const deals = '/deals';
  static const dealDetail = '/deals/:id';

  static const projects = '/projects';
  static const projectDetail = '/projects/:id';

  /// MÀN 09 — task trong dự án.
  static const projectTasks = '/projects/:id/tasks';

  /// MÀN 10 — kho bằng chứng bàn giao của dự án.
  static const projectEvidence = '/projects/:id/evidence';

  static const tasks = '/tasks';
  static const taskDetail = '/tasks/:id';

  static const proposals = '/proposals';
  static const proposalDetail = '/proposals/:id';

  /// MÀN 08 — duyệt và gửi báo giá.
  ///
  /// Có tham số `:id` để không khớp nhầm với [proposalDetail] khi màn đó
  /// được đăng ký sau này — `/proposals/review` (dạng cũ) sẽ va với
  /// `/proposals/:id`.
  static const proposalReview = '/proposals/:id/review';
  static String proposalReviewOf(String id) => '/proposals/$id/review';

  static const contracts = '/contracts';
  static const contractDetail = '/contracts/:id';

  static const invoices = '/invoices';
  static const invoiceDetail = '/invoices/:id';

  static const reminders = '/reminders';

  /// MÀN 12 — soạn lời nhắc thu tiền.
  ///
  /// Nhận `invoiceId` qua query string (`?invoiceId=...`) thay vì tham số
  /// đường dẫn, để không va với `/reminders/:id` nếu màn đó được đăng ký sau
  /// này (go_router khớp theo thứ tự khai báo — `compose` phải đứng trước).
  static const reminderCompose = '/reminders/compose';
  static String reminderComposeOf(String invoiceId) =>
      '/reminders/compose?invoiceId=$invoiceId';

  static const analytics = '/analytics';

  /// Tab "Tôi" — nơi tập trung mọi màn không có tab riêng. Bốn tab của
  /// `SoloNavBar` không đủ chỗ cho Doanh thu, Khách hàng, Hoá đơn, Gói, Mẫu và
  /// Thông báo, nên chúng mở ra từ đây.
  /// Các màn mở ra từ đây đều là đường dẫn gốc chứ không phải con của `/me`, vì
  /// cùng lý do với [offline]: đường dẫn con của một nhánh shell sẽ dựng bên
  /// trong shell và chồng thêm một thanh tab.
  static const me = '/me';

  /// MÀN 11 — doanh thu.
  static const revenue = '/revenue';

  /// MÀN 13 — gói và thanh toán MoMo.
  static const plans = '/plans';

  /// MÀN 14 — thư viện mẫu.
  static const templates = '/templates';

  static const settings = '/settings';

  /// MÀN 06 — ghi nhanh bằng giọng nói.
  static const voiceCapture = '/voice-capture';

  /// MÀN 07 — kết quả chấm điểm lead.
  static const leadScore = '/voice-capture/score';
}
