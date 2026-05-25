import 'package:cleanmate_rush/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatXp', () {
    test('formats fractional XP', () {
      expect(formatXp(0.005), '0.005');
      expect(formatXp(0.015), '0.015');
      expect(formatXp(1), '1');
    });
  });
}
