import 'package:test/test.dart';

import 'package:loan_tracker_flt/src/shared/loan_calculations.dart';

void main() {
  test('Calculates EMI', () {
    double amount = 100000.0;
    double roi = 6.0;
    int term = 120;

    double resultExpected = 1110.0;

    double result =
        LoanCalculations.calculateEMI(amount, roi, term).roundToDouble();

    expect(result, resultExpected, reason: 'EMI Calculation Failed');
  });
}
