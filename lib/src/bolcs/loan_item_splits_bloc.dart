import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import './bloc_provider.dart';
export './bloc_provider.dart';

import '../bolcs/loan_items_bloc.dart';
import '../bolcs/loan_rois_bloc.dart';
import '../bolcs/loan_amounts_bloc.dart';
import '../shared/loan_calculations.dart';

import '../models/loan_item.dart';
import '../models/loan_item_amount.dart';
export '../models/loan_item.dart';
export '../models/loan_item_amount.dart';

import '../shared/date_formatter.dart';

class LoanItemSplitsBloc implements BlocBase {
  LoanItemsBloc loanItemsBloc;
  LoanAmountsBloc loanAmountsBloc;
  LoanRoisBloc loanRoisBloc;
  StreamSubscription loanCalcSub;

  LoanCalculations _loanCalculations;

  BehaviorSubject<LoanCalculationSplitsWithStats> _loanSplitsWithStats =
      BehaviorSubject();

  Stream<LoanCalculationSplitsWithStats> get loansCalculations =>
      _loanSplitsWithStats?.stream;

  BehaviorSubject<LoanCalculationSplitsWithStats> _loanComputedSplitsWithStats =
      BehaviorSubject();

  Stream<LoanCalculationSplitsWithStats> get loansComputedCalculations =>
      _loanComputedSplitsWithStats?.stream;

  BehaviorSubject<List<LoanCalculationSplit>> _loanSplitsByYear =
      BehaviorSubject();

  Stream<List<LoanCalculationSplit>> get loanSplitsByYear =>
      _loanSplitsByYear?.stream;

  BehaviorSubject<List<LoanCalculationSplit>> _loanSplitsComputedByYear =
      BehaviorSubject();

  Stream<List<LoanCalculationSplit>> get loanSplitsComputedByYear =>
      _loanSplitsComputedByYear?.stream;

  LoanItemSplitsBloc({this.loanItemsBloc}) {
    if (loanItemsBloc.currentLoanItemValue == null) return;
    print('${this.runtimeType}: constructing');
    loanRoisBloc = LoanRoisBloc(loanItem: loanItemsBloc.currentLoanItemValue);
    loanAmountsBloc =
        LoanAmountsBloc(loanItem: loanItemsBloc.currentLoanItemValue);
    loanCalcSub = CombineLatestStream.combine3(
        loanItemsBloc.currentLoanItem,
        loanRoisBloc.loanRoisList,
        loanAmountsBloc.loanAmountsList, (loanItem, rois, amounts) {
      return LoanCalculations(
          loanItem: loanItem, loanRois: rois, loanAmounts: amounts);
    }).listen((calculations) {
      _loanCalculations = calculations;
      _loanSplitsWithStats.add(_loanCalculations.calculateEMISplitsWithStats(
        ignoreAmounts: true,
        ignoreRois: true,
      ));
      _loanComputedSplitsWithStats
          .add(_loanCalculations.calculateEMISplitsWithStats());
      _loanSplitsByYear.add(_loanCalculations.calculateEMISplits(
        byYear: true,
        ignoreAmounts: true,
        ignoreRois: true,
      ));
      _loanSplitsComputedByYear
          .add(_loanCalculations.calculateEMISplits(byYear: true));
    });
  }

  dispose() {
    print('${this.runtimeType}: disposing');
    loanCalcSub?.cancel();
    _loanSplitsWithStats.close();
    _loanComputedSplitsWithStats.close();
  }
}
