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
    return double.parse((amount * r * (rTmp / (rTmp - 1))).toStringAsFixed(2));
  }

  double getROIOfMonth(DateTime date, double currentROI) {
    try {
      final LoanRoi loanRoi = loanRois?.lastWhere((loanRoi) {
        return DateCalculations.isSameDayOrAfter(date, loanRoi.startDate);
      });
      return loanRoi.roi;
    } catch (excption) {
      return currentROI;
    }
  }

  double getExtraPaymentsOfMonth(DateTime date) {
    double amount = 0.0;
    final monthAgo = DateCalculations.subtractMonth(date);
    loanAmounts?.forEach((loanAmount) {
      if (DateCalculations.isBetween(loanAmount.date, monthAgo, date,
          inclusiveStart: true)) {
        amount += loanAmount.amount;
      }
    });
    return amount;
  }

  List<LoanCalculationSplit> calculateEMISplits(
      {bool byYear = false,
      bool ignoreRois = false,
      bool ignoreAmounts = false}) {
    print('${this.runtimeType}: calculateEMISplits');
    final List<LoanCalculationSplit> splits = [];
    double currentROI = loanItem.roi;
    DateTime momentDate = loanItem.startDate;
    double balancePrinciple = loanItem.amount;

    while (balancePrinciple > 0) {
      currentROI =
          ignoreRois ? currentROI : getROIOfMonth(momentDate, currentROI);

      double r = (currentROI * 0.00083333); // (roi/12/100)

      final LoanCalculationSplit split = LoanCalculationSplit(
        date: momentDate,
        emiPaid: loanItem.emiPaid,
      );

      double extraAmount = 0;
      extraAmount = ignoreAmounts ? 0.0 : getExtraPaymentsOfMonth(momentDate);

      split.emiPaid += extraAmount;

      split.interest = (balancePrinciple * r);

      if (balancePrinciple + split.interest < split.emiPaid)
        split.emiPaid = balancePrinciple + split.interest;

      split.principle = split.emiPaid - split.interest;
      balancePrinciple -= split.principle;
      split.balancePrinciple = balancePrinciple;
      split.finishedPercent = (100 - balancePrinciple / loanItem.amount * 100);
      // split.finishedPercent =
      //     (10000 - balancePrinciple / loanItem.amount * 10000) / 100;

      split.principle = double.parse(split.principle.toStringAsFixed(2));
      split.balancePrinciple =
          double.parse(split.balancePrinciple.toStringAsFixed(2));
      split.finishedPercent =
          double.parse(split.finishedPercent.toStringAsFixed(2));
      split.interest = double.parse(split.interest.toStringAsFixed(2));

      splits.add(split);
      momentDate = DateCalculations.addMonth(momentDate);

      // print(
      //     '${split.date.year},${split.interest},${split.principle},${split.balancePrinciple},${split.finishedPercent}%');
    }

    if (byYear) {
      final List<LoanCalculationSplit> yearSplits = [];

      final mStartDate = loanItem.startDate;
      DateTime currYearDate = DateCalculations.cloneToEndOfYear(mStartDate);

      LoanCalculationSplit currentSplit;

      splits.forEach((split) {
        if (currYearDate.year == split.date.year) {
          if (currentSplit == null) {
            currentSplit = split.clone();
            currentSplit.date = currYearDate;
          } else {
            currentSplit.principle += split.principle;
            currentSplit.interest += split.interest;
            currentSplit.principle =
                double.parse(currentSplit.principle.toStringAsFixed(2));
            currentSplit.interest =
                double.parse(currentSplit.interest.toStringAsFixed(2));
            currentSplit.balancePrinciple = split.balancePrinciple;
            currentSplit.finishedPercent = split.finishedPercent;
          }
        } else {
          currYearDate = DateCalculations.cloneToEndOfYear(split.date);
          // print(
          //     '${currentSplit.date.year},${currentSplit.interest},${currentSplit.principle},${currentSplit.balancePrinciple},${currentSplit.finishedPercent}%');
          yearSplits.add(currentSplit);
          currentSplit = split.clone();
          currentSplit.date = currYearDate;
        }
      });
      // print(
      //     '${currentSplit.date.year},${currentSplit.interest},${currentSplit.principle},${currentSplit.balancePrinciple},${currentSplit.finishedPercent}%');
      yearSplits.add(currentSplit);
      return yearSplits;
    }

    return splits;
  }

  LoanCalculationSplitsWithStats calculateEMISplitsWithStats(
      {bool byYear = false,
      bool ignoreRois = false,
      bool ignoreAmounts = false}) {
    print('${this.runtimeType}: calculateEMISplitsWithStats');
    final splits = calculateEMISplits(
      byYear: byYear,
      ignoreAmounts: ignoreAmounts,
      ignoreRois: ignoreRois,
    );

    final stats = LoanCalculationStats(
      total: 0,
      interest: 0,
      interestPercent: 0,
    );

    if (splits != null) {
      splits.forEach((split) {
        stats.interest += split.interest;
        stats.interest = double.parse((stats.interest.toStringAsFixed(2)));
      });
      stats.total =
          double.parse((loanItem.amount + stats.interest).toStringAsFixed(2));
      stats.interestPercent = double.parse(
          ((stats.interest / stats.total * 1000) / 10).toStringAsFixed(2));
    }
    // console.log("Stats: ", stats.total, stats.interest, stats.interestPercent);
    return LoanCalculationSplitsWithStats(splits: splits, stats: stats);
  }
}

class LoanCalculationSplitsWithStats {
  List<LoanCalculationSplit> splits;
  LoanCalculationStats stats;
  LoanCalculationSplitsWithStats({this.splits, this.stats});
}

class LoanCalculationStats {
  double interest, total, interestPercent;
  LoanCalculationStats({this.interest, this.total, this.interestPercent});
}

class LoanCalculationSplit {
  DateTime date;
  double emiPaid;
  double principle;
  double interest;
  double balancePrinciple;
  double finishedPercent;
  LoanCalculationSplit({
    this.date,
    this.emiPaid,
    this.principle = 0.0,
    this.interest = 0.0,
    this.balancePrinciple = 0.0,
    this.finishedPercent = 0.0,
  });

  LoanCalculationSplit clone() {
    return LoanCalculationSplit(
      date: this.date,
      emiPaid: this.emiPaid,
      principle: this.principle,
      interest: this.interest,
      balancePrinciple: this.balancePrinciple,
      finishedPercent: this.finishedPercent,
    );
  }
}
