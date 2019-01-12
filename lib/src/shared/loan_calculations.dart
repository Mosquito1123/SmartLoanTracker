import 'dart:math';

import '../shared/date_calculations.dart';

import '../models/loan_item.dart';
import '../models/loan_item_roi.dart';
import '../models/loan_item_amount.dart';

class LoanCalculations {
  final LoanItem loanItem;
  final List<LoanRoi> loanRois;
  final List<LoanAmount> loanAmounts;

  LoanCalculations({this.loanItem, this.loanRois, this.loanAmounts});

  static double calculateEMI(double amount, double roi, int term) {
    // p * r * ( ((1+r) ^ n) / (((1+r) ^ n) - 1 ))

    final double r = roi / 12 / 100;

    final double rTmp = pow(1 + r, term);

    return (amount * r * (rTmp / (rTmp - 1)));
  }

  double _getROIOfMonth(DateTime date, double currentROI) {
    LoanRoi loanRoi = loanRois.singleWhere((loanRoi) {
      return DateCalculations.isSameDayOrAfter(date, loanRoi.startDate);
    });
    return loanRoi.roi;
  }
}
