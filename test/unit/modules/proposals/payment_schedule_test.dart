import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/payment_schedule.dart';

void main() {
  group('PaymentSchedule.parse', () {
    test("'Cọc 50%, duyệt nháp 30%, bàn giao 20%' -> 3 đợt đúng label/percent, "
        'isComplete, không fallback', () {
      final schedule = PaymentSchedule.parse(
        'Cọc 50%, duyệt nháp 30%, bàn giao 20%',
      );

      expect(schedule.stages, hasLength(3));
      expect(schedule.stages.map((s) => s.label).toList(), [
        'Cọc',
        'Duyệt nháp',
        'Bàn giao',
      ]);
      expect(schedule.stages.map((s) => s.percent).toList(), [50, 30, 20]);
      expect(schedule.isComplete, isTrue);
      expect(schedule.isFallback, isFalse);
    });

    test('null -> PaymentSchedule.standard', () {
      final schedule = PaymentSchedule.parse(null);

      expect(schedule.isFallback, isTrue);
      expect(schedule.stages.map((s) => s.label).toList(), [
        'Cọc',
        'Duyệt nháp',
        'Bàn giao',
      ]);
      expect(schedule.stages.map((s) => s.percent).toList(), [50, 30, 20]);
    });

    test("'' (chuỗi rỗng) -> PaymentSchedule.standard", () {
      final schedule = PaymentSchedule.parse('');
      expect(schedule.isFallback, isTrue);
    });

    test("'không có phần trăm nào' (< 2 khớp) -> PaymentSchedule.standard", () {
      final schedule = PaymentSchedule.parse('không có phần trăm nào');
      expect(schedule.isFallback, isTrue);
    });

    test("'A 60%, B 60%' (tổng > 100) -> PaymentSchedule.standard", () {
      final schedule = PaymentSchedule.parse('A 60%, B 60%');
      expect(schedule.isFallback, isTrue);
    });
  });

  group('opacityAt', () {
    const schedule = PaymentSchedule.standard;

    test('stage 0/1/2/3 -> đúng [0.9, 0.62, 0.35, 0.2]', () {
      expect(schedule.opacityAt(0), 0.9);
      expect(schedule.opacityAt(1), 0.62);
      expect(schedule.opacityAt(2), 0.35);
      expect(schedule.opacityAt(3), 0.2);
    });

    test('stage 4 (ngoài bảng tra cứu) -> 0.2', () {
      expect(schedule.opacityAt(4), 0.2);
    });
  });
}
