import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/reminders/domain/services/reminder_message_composer.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_tone.dart';

void main() {
  const clientName = 'Chị Hoa';
  final dueDate = DateTime.utc(2026, 7, 20);
  const amount = 5000000.0;

  group('ReminderMessageComposer.compose', () {
    for (final tone in ReminderTone.values) {
      test('giọng ${tone.name} chứa số tiền định dạng đúng và ngày dd/MM', () {
        final body = ReminderMessageComposer.compose(
          tone: tone,
          clientName: clientName,
          amount: amount,
          dueDate: dueDate,
          attachPaymentLink: false,
        );

        expect(body, contains('5.000.000 ₫'));
        expect(body, contains('20/07'));
      });
    }

    test("giọng 'polite' chứa đúng 3 cụm cố định", () {
      final body = ReminderMessageComposer.compose(
        tone: ReminderTone.polite,
        clientName: clientName,
        amount: amount,
        dueDate: dueDate,
        attachPaymentLink: false,
      );

      expect(body, contains('trị giá '));
      expect(body, contains(', đến hạn ngày '));
      expect(body, contains('xuất hoá đơn hay lùi lịch'));
    });

    test('attachPaymentLink: false -> KHÔNG chứa "MoMo"', () {
      final body = ReminderMessageComposer.compose(
        tone: ReminderTone.polite,
        clientName: clientName,
        amount: amount,
        dueDate: dueDate,
        attachPaymentLink: false,
      );

      expect(body, isNot(contains('MoMo')));
    });

    test('attachPaymentLink: true -> CÓ chứa "MoMo"', () {
      final body = ReminderMessageComposer.compose(
        tone: ReminderTone.polite,
        clientName: clientName,
        amount: amount,
        dueDate: dueDate,
        attachPaymentLink: true,
      );

      expect(body, contains('MoMo'));
    });
  });
}
