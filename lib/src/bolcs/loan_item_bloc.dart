import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import './bloc_provider.dart';
export './bloc_provider.dart';
import '../models/loan_item.dart';
export '../models/loan_item.dart';

class LoanItemBloc implements BlocBase {
  final BehaviorSubject<LoanItem> _currentLoanCtrl;
  PublishSubject<String> _titleSubject;

  DocumentReference _fireStore =
      Firestore.instance.collection('loan-tracker').document('LoanTrackerDoc');

  Stream<LoanItem> get currentLoanItem => _currentLoanCtrl.stream;
  Function(LoanItem) get updateCurrentLoanItem => _currentLoanCtrl.sink.add;

  final LoanItem loanItem;
  LoanItemBloc({this.loanItem})
      : _currentLoanCtrl = BehaviorSubject<LoanItem>(seedValue: loanItem),
        _titleSubject = PublishSubject<String>() {
    title.listen((title) {
      print('updating firestore : title : $title');
      loanItem.reference.updateData({
        'title': title,
      }).catchError((err) => _titleSubject.sink.addError(err));
    });
  }

  Stream<String> get title => _titleSubject.stream
          .debounce(Duration(milliseconds: 1000))
          .distinct()
          .transform(StreamTransformer<String, String>.fromHandlers(
              handleData: (data, sink) {
        if (data.isEmpty)
          sink.addError('Title can\'t be empty');
        else
          sink.add(data);
      }));
  Function(String) get updateTitle => _titleSubject.sink.add;

  @override
  void dispose() {
    _titleSubject.close();
    _currentLoanCtrl.close();
  }
}
