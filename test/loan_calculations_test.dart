import 'package:test/test.dart';

import 'package:loan_tracker_flt/src/models/loan_item.dart';
import 'package:loan_tracker_flt/src/models/loan_item_amount.dart';
import 'package:loan_tracker_flt/src/models/loan_item_roi.dart';
import 'package:loan_tracker_flt/src/shared/loan_calculations.dart';

void main() {
  LoanCalculations loanCalc,
      loanCalcNoRois,
      loanCalcNoAmounts,
      loanCalcHeadOnly;

  group('Fetch Extra Payment Amounts', () {
    test('should return 0, when no amounts available', () {
      double resultExpected = 0.0;

      double result =
          loanCalcHeadOnly.getExtraPaymentsOfMonth(DateTime.utc(2016, 01));

      expect(result, resultExpected);
    });
    test('should return 0, when no amounts available for given month', () {
      double resultExpected = 0.0;

      double result = loanCalc.getExtraPaymentsOfMonth(DateTime.utc(2015, 10));

      expect(result, resultExpected);
    });
    test(
        'should return single amount, when single amount available for given month',
        () {
      double resultExpected = 100.0;

      double result =
          loanCalc.getExtraPaymentsOfMonth(DateTime.utc(2016, 01, 10));

      expect(result, resultExpected);
    });
    test(
        'should return total amount, when multiple amounts available for given month',
        () {
      double resultExpected = 200.0;

      double result =
          loanCalc.getExtraPaymentsOfMonth(DateTime.utc(2017, 06, 09));

      expect(result, resultExpected);
    });
    test('should exclude amounts on calculation date', () {
      double resultExpected = 200.0;

      double result =
          loanCalc.getExtraPaymentsOfMonth(DateTime.utc(2017, 06, 10));

      expect(result, resultExpected);
    });
  });
  group('Fetch Rate Of Interest', () {
    test('should return ROI rate, when roi available (first)', () {
      double resultExpected = loanCalc.loanRois[0].roi;

      double result = loanCalc.getROIOfMonth(DateTime.utc(2016, 01));

      expect(result, resultExpected);
    });
    test('should return ROI rate, when roi available (second)', () {
      double resultExpected = loanCalc.loanRois[1].roi;

      double result = loanCalc.getROIOfMonth(DateTime.utc(2016, 05));

      expect(result, resultExpected);
    });
    test('should return loanItem ROI, when roi not yet started for given month',
        () {
      double resultExpected = loanCalc.loanItem.roi;

      double result = loanCalc.getROIOfMonth(DateTime.utc(2015, 08));

      expect(result, resultExpected);
    });
    test('should return loanItem ROI, when no roi items available', () {
      double resultExpected = loanCalcHeadOnly.loanItem.roi;

      double result = loanCalcHeadOnly.getROIOfMonth(DateTime.now());

      expect(result, resultExpected);
    });
  });

  test('Calculates EMI', () {
    double resultExpected = loanCalc.loanItem.emi;

    double result = LoanCalculations.calculateEMI(loanCalc.loanItem.amount,
            loanCalc.loanItem.roi, loanCalc.loanItem.term)
        .roundToDouble();

    expect(result, resultExpected);
  });

  setUpAll(() {
    LoanItem loanItem = LoanItem.fromMap({
      'title': 'Sample Loan',
      'startDate': DateTime.tryParse('2015-06-10').millisecondsSinceEpoch,
      'amount': 100000.0,
      'roi': 6.0,
      'term': 120,
      'emi': 1110.0,
    });
    final List<LoanRoi> loanRois = [];
    loanRois.add(LoanRoi.fromMap({
      'roi': 10.0,
      'startDate': DateTime.utc(2015, 12).millisecondsSinceEpoch
    }));
    loanRois.add(LoanRoi.fromMap({
      'roi': 15.0,
      'startDate': DateTime.utc(2016, 5).millisecondsSinceEpoch
    }));
    final List<LoanAmount> loanAmounts = [];
    loanAmounts
        .add(LoanAmount.fromMap({'amount': 100.0, 'date': '2016-01-01'}));
    loanAmounts
        .add(LoanAmount.fromMap({'amount': 100.0, 'date': '2017-06-01'}));
    loanAmounts
        .add(LoanAmount.fromMap({'amount': 100.0, 'date': '2017-06-08'}));
    loanAmounts
        .add(LoanAmount.fromMap({'amount': 100.0, 'date': '2017-06-10'}));
    loanCalcHeadOnly = LoanCalculations(loanItem: loanItem);
    loanCalc = LoanCalculations(
        loanItem: loanItem, loanRois: loanRois, loanAmounts: loanAmounts);
    loanCalcNoRois =
        LoanCalculations(loanItem: loanItem, loanAmounts: loanAmounts);
    loanCalcNoAmounts =
        LoanCalculations(loanItem: loanItem, loanRois: loanRois);
  });
}
