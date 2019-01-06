import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import './bloc_provider.dart';
export './bloc_provider.dart';
import '../models/loan_item.dart';
import '../models/loan_item_roi.dart';
export '../models/loan_item_roi.dart';

class LoanRoisBloc implements BlocBase {
  BehaviorSubject<LoanRoi> _currentLoanRoiCtrl = BehaviorSubject<LoanRoi>();
  // BehaviorSubject<List<LoanRoi>> _loanRoisListCtrl = BehaviorSubject<List<LoanRoi>>();

  DocumentReference _fireStore =
      Firestore.instance.collection('loan-tracker').document('LoanTrackerDoc');

  Stream<List<LoanRoi>> get loanRoisList => _fireStore
      .collection('loans')
      .document(loanItem.reference.documentID)
      .collection('rois')
      .snapshots()
      .map((snapshot) => snapshot.documents
          .map((DocumentSnapshot document) => LoanRoi.fromDocSnapshot(document))
          .toList());

  LoanRoi get currentLoanRoiValue => _currentLoanRoiCtrl.value;
  Stream<LoanRoi> get currentLoanRoi => _currentLoanRoiCtrl.stream;
  Function(LoanRoi) get updateCurrentLoanRoi => _currentLoanRoiCtrl.sink.add;

  final LoanItem loanItem;
  LoanRoisBloc({@required this.loanItem});

  @override
  void dispose() {
    print('disposing:ROIs bloc');
    _currentLoanRoiCtrl.close();
  }
}
