import 'package:test/test.dart';

import 'package:loan_tracker_flt/src/shared/date_calculations.dart';

void main() {
  group('isBetween', () {
    test('given middle date, should be true', () {
      DateTime startDate = DateTime.utc(2018, 10, 10);
      DateTime endDate = DateTime.utc(2018, 11, 10);
      DateTime currDate = DateTime.utc(2018, 10, 20);

      DateTime date = DateTime.utc(2018, 03, 31);
      print(DateCalculations.cloneToEndOfYear(date).toString());
      print(DateCalculations.cloneToPreviousMonth(date).toString());

      bool resultExpected = true;

      bool result = DateCalculations.isBetween(currDate, startDate, endDate);

      expect(result, resultExpected);
    });
    test('given date before, should be false', () {
      DateTime startDate = DateTime.utc(2018, 10, 10);
      DateTime endDate = DateTime.utc(2018, 11, 10);
      DateTime currDate = DateTime.utc(2018, 10, 09);

      bool resultExpected = false;

      bool result = DateCalculations.isBetween(currDate, startDate, endDate);

      expect(result, resultExpected);
    });
    test('given date after, should be false', () {
      DateTime startDate = DateTime.utc(2018, 10, 10);
      DateTime endDate = DateTime.utc(2018, 11, 10);
      DateTime currDate = DateTime.utc(2018, 11, 11);

      bool resultExpected = false;

      bool result = DateCalculations.isBetween(currDate, startDate, endDate);

      expect(result, resultExpected);
    });
    test('given start date (exclusive Start), should be false', () {
      DateTime startDate = DateTime.utc(2018, 10, 10);
      DateTime endDate = DateTime.utc(2018, 11, 10);
      DateTime currDate = DateTime.utc(2018, 10, 10);

      bool resultExpected = false;

      bool result = DateCalculations.isBetween(currDate, startDate, endDate);

      expect(result, resultExpected);
    });
    test('given end date (exclusive End), should be false', () {
      DateTime startDate = DateTime.utc(2018, 10, 10);
      DateTime endDate = DateTime.utc(2018, 11, 10);
      DateTime currDate = DateTime.utc(2018, 11, 10);

      bool resultExpected = false;

      bool result = DateCalculations.isBetween(currDate, startDate, endDate);

      expect(result, resultExpected);
    });
    test('given start date (inclusive Start), should be true', () {
      DateTime startDate = DateTime.utc(2018, 10, 10);
      DateTime endDate = DateTime.utc(2018, 11, 10);
      DateTime currDate = DateTime.utc(2018, 10, 10);

      bool resultExpected = true;

      bool result = DateCalculations.isBetween(currDate, startDate, endDate,
          inclusiveStart: true);

      expect(result, resultExpected);
    });
    test('given end date (inclusive End), should be true', () {
      DateTime startDate = DateTime.utc(2018, 10, 10);
      DateTime endDate = DateTime.utc(2018, 11, 10);
      DateTime currDate = DateTime.utc(2018, 11, 10);

      bool resultExpected = true;

      bool result = DateCalculations.isBetween(currDate, startDate, endDate,
          inclusiveEnd: true);

      expect(result, resultExpected);
    });
    test('given all same dates, should be false', () {
      DateTime startDate = DateTime.utc(2018, 10, 10);
      DateTime endDate = DateTime.utc(2018, 10, 10);
      DateTime currDate = DateTime.utc(2018, 10, 10);

      bool resultExpected = false;

      bool result = DateCalculations.isBetween(currDate, startDate, endDate);

      expect(result, resultExpected);
    });
    test(
        'given all same dates (inclusive Start, inclusive End), should be true',
        () {
      DateTime startDate = DateTime.utc(2018, 11, 10);
      DateTime endDate = DateTime.utc(2018, 11, 10);
      DateTime currDate = DateTime.utc(2018, 11, 10);

      bool resultExpected = true;

      bool result = DateCalculations.isBetween(currDate, startDate, endDate,
          inclusiveStart: true, inclusiveEnd: true);

      expect(result, resultExpected);
    });
  });
  group('isSameOrAfter', () {
    test('given after date, should be true', () {
      DateTime srcDate = DateTime.utc(2018, 10, 10);
      DateTime destDate = DateTime.utc(2018, 10, 9);

      bool resultExpected = true;

      bool result = DateCalculations.isSameDayOrAfter(srcDate, destDate);

      expect(result, resultExpected);
    });

    test('given same date, should be true', () {
      DateTime srcDate = DateTime.utc(2018, 10, 10);
      DateTime destDate = DateTime.utc(2018, 10, 10);

      bool resultExpected = true;

      bool result = DateCalculations.isSameDayOrAfter(srcDate, destDate);

      expect(result, resultExpected);
    });
    test('given same date with before time, should be true', () {
      DateTime srcDate = DateTime.utc(2018, 10, 10, 5);
      DateTime destDate = DateTime.utc(2018, 10, 10, 10);

      bool resultExpected = true;

      bool result = DateCalculations.isSameDayOrAfter(srcDate, destDate);

      expect(result, resultExpected);
    });
    test('given same date with after time, should be true', () {
      DateTime srcDate = DateTime.utc(2018, 10, 10, 15);
      DateTime destDate = DateTime.utc(2018, 10, 10, 10);

      bool resultExpected = true;

      bool result = DateCalculations.isSameDayOrAfter(srcDate, destDate);

      expect(result, resultExpected);
    });

    test('given before date, should be false', () {
      DateTime srcDate = DateTime.utc(2018, 10, 10);
      DateTime destDate = DateTime.utc(2018, 10, 11);

      bool resultExpected = false;

      bool result = DateCalculations.isSameDayOrAfter(srcDate, destDate);

      expect(result, resultExpected);
    });
    test('given before date with time, should be false', () {
      DateTime srcDate = DateTime.utc(2018, 10, 09, 20);
      DateTime destDate = DateTime.utc(2018, 10, 10);

      bool resultExpected = false;

      bool result = DateCalculations.isSameDayOrAfter(srcDate, destDate);

      expect(result, resultExpected);
    });
  });
}
