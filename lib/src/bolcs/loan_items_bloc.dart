import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

import './bloc_provider.dart';
export './bloc_provider.dart';
import '../models/loan_item.dart';
export '../models/loan_item.dart';

class LoanItemsBloc implements BlocBase {
  BehaviorSubject<LoanItem> _currentLoanCtrl = BehaviorSubject<LoanItem>();
  // BehaviorSubject<List<LoanItem>> _loansListCtrl = BehaviorSubject<List<LoanItem>>();

  DocumentReference _fireStore =
      Firestore.instance.collection('loan-tracker').document('LoanTrackerDoc');

  Stream<List<LoanItem>> get loansList => _fireStore
      .collection('loans')
      .snapshots()
      .map((snapshot) => snapshot.documents
          .map(
              (DocumentSnapshot document) => LoanItem.fromDocSnapshot(document))
          .toList());

  LoanItem get currentLoanItemValue => _currentLoanCtrl.value;
  Stream<LoanItem> get currentLoanItem => _currentLoanCtrl.stream;
  Function(LoanItem) get updateCurrentLoanItem => _currentLoanCtrl.sink.add;

  LoanItemsBloc() {
    StreamSubscription listener;
    listener = loansList.listen((loans) {
      _currentLoanCtrl.add(loans.first);
      listener.cancel();
    });
  }

  @override
  void dispose() {
    print('disposing:LoanItems bloc');
    _currentLoanCtrl.close();
  }
}
