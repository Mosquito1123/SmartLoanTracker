import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import './bloc_provider.dart';
export './bloc_provider.dart';
import '../models/loan_item.dart';
import '../models/loan_item_amount.dart';
export '../models/loan_item_amount.dart';

class LoanAmountsBloc implements BlocBase {
  PublishSubject<LoanAmount> _currentLoanAmountCtrl =
      PublishSubject<LoanAmount>();
  // BehaviorSubject<List<LoanAmount>> _loanAmountsListCtrl = BehaviorSubject<List<LoanAmount>>();

  DocumentReference _fireStore =
      Firestore.instance.collection('loan-tracker').document('LoanTrackerDoc');

  Stream<List<LoanAmount>> get loanAmountsList => _fireStore
      .collection('loans')
      .document(loanItem.reference.documentID)
      .collection('amounts')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.documents
          .map((DocumentSnapshot document) =>
              LoanAmount.fromDocSnapshot(document))
          .toList());

  // LoanAmount get currentLoanAmountValue => _currentLoanAmountCtrl.value;
  Stream<LoanAmount> get currentLoanAmount => _currentLoanAmountCtrl.stream;
  Function(LoanAmount) get updateCurrentLoanAmount =>
      _currentLoanAmountCtrl.sink.add;

  final LoanItem loanItem;
  LoanAmountsBloc({@required this.loanItem});

  Future<void> deleteRoi(LoanAmount loanAmount) {
    return loanAmount.reference?.delete();
  }

  Future<DocumentReference> undoDeleteRoi(LoanAmount loanAmount) {
    return _fireStore
        .collection('loans')
        .document(loanItem.reference.documentID)
        .collection('amounts')
        .add({
      'roi': loanAmount.amount,
      'startDate': loanAmount.date.millisecondsSinceEpoch,
    });
  }

  @override
  void dispose() {
    print('disposing:ROIs bloc');
    _currentLoanAmountCtrl.close();
  }
}
