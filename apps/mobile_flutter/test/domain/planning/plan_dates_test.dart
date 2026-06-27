import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';

void main() {
  group('startOfDay', () {
    test('strips time components from a DateTime', () {
      final DateTime input = DateTime(2026, 6, 15, 14, 30, 45, 123);
      final DateTime result = startOfDay(input);

      expect(result, DateTime(2026, 6, 15));
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
      expect(result.millisecond, 0);
    });

    test('returns the same value when time is already midnight', () {
      final DateTime midnight = DateTime(2026, 3);
      expect(startOfDay(midnight), midnight);
    });
  });

  group('dayKeyForDate', () {
    test('formats a date as YYYY-MM-DD', () {
      expect(dayKeyForDate(DateTime(2026, 6, 15)), '2026-06-15');
    });

    test('zero-pads single-digit months and days', () {
      expect(dayKeyForDate(DateTime(2026, 1, 5)), '2026-01-05');
    });

    test('ignores time components', () {
      expect(
        dayKeyForDate(DateTime(2026, 12, 25, 23, 59, 59)),
        '2026-12-25',
      );
    });
  });

  group('remainingDaysInWeek', () {
    test('returns days from the given date through end of the week', () {
      // Wednesday June 24, 2026 (weekday == 3)
      final DateTime wednesday = DateTime(2026, 6, 24);
      final List<DateTime> days = remainingDaysInWeek(wednesday);

      expect(days.length, DateTime.daysPerWeek - wednesday.weekday + 1);
      expect(days.first, startOfDay(wednesday));
      expect(days.last.weekday, DateTime.sunday);
    });

    test('returns a single day when called on Sunday', () {
      // Sunday June 28, 2026 (weekday == 7)
      final DateTime sunday = DateTime(2026, 6, 28);
      final List<DateTime> days = remainingDaysInWeek(sunday);

      expect(days.length, 1);
      expect(days.single, startOfDay(sunday));
    });

    test('returns a full week when called on Monday', () {
      // Monday June 22, 2026 (weekday == 1)
      final DateTime monday = DateTime(2026, 6, 22);
      final List<DateTime> days = remainingDaysInWeek(monday);

      expect(days.length, 7);
      expect(days.first.weekday, DateTime.monday);
      expect(days.last.weekday, DateTime.sunday);
    });

    test('strips time from the anchor date', () {
      final DateTime afternoon = DateTime(2026, 6, 24, 15, 30);
      final List<DateTime> days = remainingDaysInWeek(afternoon);

      for (final DateTime day in days) {
        expect(day.hour, 0);
        expect(day.minute, 0);
      }
    });

    test('produces consecutive dates', () {
      final DateTime tuesday = DateTime(2026, 6, 23);
      final List<DateTime> days = remainingDaysInWeek(tuesday);

      for (int i = 1; i < days.length; i++) {
        expect(
          days[i].difference(days[i - 1]),
          const Duration(days: 1),
        );
      }
    });
  });
}
