/// Khoảng cách lấy nguyên từ bản phác thảo, khung tham chiếu 390 × 844 pt.
///
/// **Dùng khi:** đặt bất kỳ `padding`, `margin`, hay `gap` nào trong `lib/ui/`
/// và `lib/features/`.
///
/// **KHÔNG dùng khi:** con số trong bản phác thảo không có ở đây. Đừng viết
/// cứng — bản phác thảo ghi khoảng cách theo đúng khung 390 pt nên chép thẳng,
/// và nếu là giá trị mới thì thêm hằng số vào đây kèm chỗ nó xuất hiện.
///
/// Nhóm trên là khoảng cách *có vai trò* — ưu tiên dùng chúng vì tên nói rõ ý
/// đồ. Nhóm dưới là thang số trần, chỉ dùng khi không có tên nào hợp.
abstract final class AppGap {
  // ─── Có vai trò ───────────────────────────────────────────────────

  /// Lề trái/phải của mọi màn hình. Không có ngoại lệ.
  static const double screen = 18;

  /// Padding trong một `Card`.
  static const double card = 14;

  /// Padding trong một `SlipCard`.
  static const double slip = 15;

  /// Khoảng cách giữa hai `Card` liền nhau.
  static const double betweenCards = 10;

  /// Khoảng cách giữa các chip trong một dải lọc.
  static const double betweenChips = 7;

  /// Padding dọc bên trong một chip. Ngang dùng [md].
  static const double chipVertical = 4;

  /// Khoảng cách giữa các nút trong một hàng nút.
  static const double betweenButtons = 9;

  /// Gap mặc định của một hàng icon + chữ.
  static const double row = 10;

  /// Khoảng trống phía trên một nhãn mục.
  static const double sectionTop = 18;

  /// Khoảng trống phía dưới một nhãn mục.
  static const double sectionBottom = 9;

  /// Chừa chỗ cho thanh tab nổi ở đáy khi màn có `SoloNavBar`.
  static const double navBarInset = 96;

  // ─── Thang số trần ────────────────────────────────────────────────

  static const double xxs = 3;
  static const double xs = 5;
  static const double sm = 7;
  static const double md = 9;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 22;
  static const double xxxl = 26;
}
