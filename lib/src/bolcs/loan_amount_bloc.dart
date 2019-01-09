import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import './bloc_provider.dart';
export './bloc_provider.dart';
import '../models/loan_item.dart';
import '../models/loan_item_amount.dart';
export '../models/loan_item.dart';
export '../models/loan_item_amount.dart';

import '../shared/date_formatter.dart';

class UpdateLoanAmountField {
  final LoanAmountFieldKey key;
  final String value;

  const UpdateLoanAmountField({
    this.key,
    this.value,
  });
}

class LoanAmountBloc implements BlocBase {
  final BehaviorSubject<LoanItem> _currentLoanCtrl;
  final BehaviorSubject<LoanAmount> _currentLoanAmountCtrl;

  BehaviorSubject<double> _amountSubject;
  Stream<double> get amount => _amountSubject.stream;

  BehaviorSubject<DateTime> _dateSubject;
  Stream<DateTime> get date => _dateSubject.stream;
  DateTime get dateValue => _dateSubject.value;

  // actions to update data
  PublishSubject _actionsSubject = PublishSubject();
  Function(dynamic) get loanAmountAction => _actionsSubject.sink.add;

  DocumentReference _fireStore =
      Firestore.instance.collection('loan-tracker').document('LoanTrackerDoc');

  Stream<LoanItem> get currentLoan => _currentLoanCtrl.stream;
  Function(LoanItem) get updateCurrentLoan => _currentLoanCtrl.sink.add;

  Stream<LoanAmount> get currentLoanAmount => _currentLoanAmountCtrl.stream;
  LoanAmount get currentLoanAmountValue => _currentLoanAmountCtrl.value;
  Function(LoanAmount) get updateCurrentLoanAmount =>
      _currentLoanAmountCtrl.sink.add;

  PublishSubject<void> _createRoiSubject = PublishSubject<void>();
  // Stream<void> get loanAmountCreated => _createRoiSubject.stream;
  Function(void) get createLoanAmount => _createRoiSubject.sink.add;

  final Map<LoanAmountFieldKey, Subject> _fieldSubjectMap = {};

  final LoanItem loanItem;
  final LoanAmount loanAmount;
  LoanAmountBloc({@required this.loanItem, @required this.loanAmount})
      : assert(loanItem != null),
        assert(loanAmount != null),
        _currentLoanCtrl = BehaviorSubject<LoanItem>(seedValue: loanItem),
        _currentLoanAmountCtrl =
            BehaviorSubject<LoanAmount>(seedValue: loanAmount),
        _dateSubject = BehaviorSubject<DateTime>(seedValue: loanAmount.date),
        _amountSubject = BehaviorSubject<double>(seedValue: loanAmount.amount) {
    _setupActionsListener();
    _setupFieldStreamMap();
    _setupFieldListeners();
  }

  _setupFieldListeners() {
    _currentLoanAmountCtrl.listen((loanAmount) {
      _amountSubject.add(loanAmount.amount);
      _dateSubject.add(loanAmount.date);
    });
    _fieldSubjectMap.forEach((key, subject) {
      subject.stream.listen((value) {
        LoanAmount loanAmount = _currentLoanAmountCtrl.value;
        if (loanAmount.reference == null) return;
        if (loanAmount.getValue(key) == value) return;
        if (loanAmount.setValue(key: key, value: value) == null) return;
        dynamic convertedValue = value;
        if (value.runtimeType == DateTime) {
          final DateTime dateValue = value;
          convertedValue = DateFormatter.formatFullWithFormat(
              dateValue, LoanAmount.dateFormat);
        }
        print('updating firestore: $key : $convertedValue');
        loanAmount.reference.updateData({
          key.toString().split('.').last: convertedValue,
        }).catchError((err) => subject.sink.addError(err));
      });
    });
  }

  _setupActionsListener() {
    _createRoiSubject.listen((_) {
      // final LoanAmount loanAmount = _currentLoanAmountCtrl.value;
      // if (loanAmount.reference != null) return; //not a new ROI
      _fireStore
          .collection('loans')
          .document(loanItem.reference.documentID)
          .collection('amounts')
          .reference()
          .add({
        'amount': _amountSubject.value,
        'date': DateFormatter.formatFullWithFormat(
            _dateSubject.value, LoanAmount.dateFormat)
      });
    });
    _actionsSubject.stream
        .debounce(Duration(milliseconds: 1000))
        .distinct()
        .listen((action) {
      switch (action.runtimeType) {
        case UpdateLoanAmountField:
          _onUpdateLoanAmountField(action);
          break;
      }
    });
  }

  _setupFieldStreamMap() {
    _fieldSubjectMap.putIfAbsent(
        LoanAmountFieldKey.amount, () => _amountSubject);
    _fieldSubjectMap.putIfAbsent(LoanAmountFieldKey.date, () => _dateSubject);
  }

  _onUpdateLoanAmountField(UpdateLoanAmountField action) {
    String validationError = _validateLoanAmountField(
      key: action.key,
      value: action.value,
    );
    if (!_fieldSubjectMap.containsKey(action.key)) return;
    final Subject currentSubject = _fieldSubjectMap[action.key];
    if (validationError != null && validationError.isNotEmpty) {
      currentSubject.sink.addError(validationError);
      return;
    }
    switch (action.key) {
      case LoanAmountFieldKey.amount:
        currentSubject.sink.add(double.tryParse(action.value));
        break;
      case LoanAmountFieldKey.date:
        currentSubject.sink.add(DateFormatter.parseDateM(action.value));
        break;
      default:
        currentSubject.sink.add(action.value);
    }
  }

  String _validateLoanAmountField({LoanAmountFieldKey key, String value}) {
    String validationError;
    double dblValue;

    //check for mandatory fields
    if (key == LoanAmountFieldKey.amount || key == LoanAmountFieldKey.date) {
      if (value == null || value.trim().isEmpty)
        validationError = '${key.toString().split('.').last} can\'t be empty';
      return validationError;
    }
    switch (key) {
      case LoanAmountFieldKey.amount:
        dblValue = double.tryParse(value);
        if (dblValue == null)
          validationError = 'Not a valid ${key.toString().split('.').last}';
        break;
      case LoanAmountFieldKey.date:
        if (DateTime.tryParse(value) == null)
          validationError = 'Not a valid ${key.toString().split('.').last}';
        break;
      default:
    }
    return validationError;
  }

  @override
  void dispose() {
    print('disposing:LoanAmount bloc');
    _actionsSubject.close();
    _currentLoanCtrl.close();
    _createRoiSubject.close();
    _fieldSubjectMap.forEach((_, stream) => stream.close());
  }
}
