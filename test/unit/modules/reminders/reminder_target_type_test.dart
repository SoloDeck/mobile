import 'package:flutter_test/flutter_test.dart';
import 'package:solodesk_mobile/modules/reminders/domain/value_objects/reminder_target_type.dart';

void main() {
  test(
    'wireValue của ReminderTargetType chỉ có đúng 4 giá trị, KHÔNG có proposal',
    () {
      final wireValues = ReminderTargetType.values
          .map((e) => e.wireValue)
          .toSet();

      expect(wireValues, {'deal', 'client', 'invoice', 'contract'});
      expect(wireValues, isNot(contains('proposal')));
    },
  );
}
