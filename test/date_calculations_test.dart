import 'package:test/test.dart';

import 'package:loan_tracker_flt/src/shared/date_calculations.dart';

void main() {
  group('subtractMonth', () {
    test('given date, should be privious month', () {
      DateTime srcDate = DateTime.utc(2018, 10, 10);
      DateTime expectedDate = DateTime.utc(2018, 09, 10);

      DateTime resultDate = DateCalculations.subtractMonth(srcDate);

      expect(resultDate, expectedDate);
    });
    test('given date nov - 10 month, should be jan month', () {
      DateTime srcDate = DateTime.utc(2018, 11, 10);
      DateTime expectedDate = DateTime.utc(2018, 01, 10);

      DateTime resultDate = DateCalculations.subtractMonth(srcDate, 10);

      expect(resultDate, expectedDate);
    });
    test('given date nov - 24 month, should be nov month 2 years ago', () {
      DateTime srcDate = DateTime.utc(2018, 11, 10);
      DateTime expectedDate = DateTime.utc(2016, 11, 10);

      DateTime resultDate = DateCalculations.subtractMonth(srcDate, 24);

      expect(resultDate, expectedDate);
    });
    test('given end of march, should be end of feb', () {
      DateTime srcDate = DateTime.utc(2018, 03, 31);
      DateTime expectedDate = DateTime.utc(2018, 02, 28);

      DateTime resultDate = DateCalculations.subtractMonth(srcDate);

      expect(resultDate, expectedDate);
    });
    test('given end of march (leap year), should be end of feb', () {
      DateTime srcDate = DateTime.utc(2020, 03, 31);
      DateTime expectedDate = DateTime.utc(2020, 02, 29);

      DateTime resultDate = DateCalculations.subtractMonth(srcDate);

      expect(resultDate, expectedDate);
    });
    test('given start of year, should be privious dec month', () {
      DateTime srcDate = DateTime.utc(2018, 01, 31);
      DateTime expectedDate = DateTime.utc(2017, 12, 31);

      DateTime resultDate = DateCalculations.subtractMonth(srcDate);

      expect(resultDate, expectedDate);
    });
    test('given date oct - 10, should be privious dec month', () {
      DateTime srcDate = DateTime.utc(2018, 10, 31);
      DateTime expectedDate = DateTime.utc(2017, 12, 31);

      DateTime resultDate = DateCalculations.subtractMonth(srcDate, 10);

      expect(resultDate, expectedDate);
    });
    test('given end of year - 11 months, should be privious Feb month end', () {
      DateTime srcDate = DateTime.utc(2018, 01, 31);
      DateTime expectedDate = DateTime.utc(2017, 02, 28);

      DateTime resultDate = DateCalculations.subtractMonth(srcDate, 11);

      expect(resultDate, expectedDate);
    });
  });
  group('isBetween', () {
    test('given middle date, should be true', () {
      DateTime startDate = DateTime.utc(2018, 10, 10);
      DateTime endDate = DateTime.utc(2018, 11, 10);
      DateTime currDate = DateTime.utc(2018, 10, 20);

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
