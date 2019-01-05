import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import './bloc_provider.dart';
export './bloc_provider.dart';
import '../models/loan_item.dart';
export '../models/loan_item.dart';

class UpdateLoanField {
  final LoanFieldKey key;
  final String value;

  const UpdateLoanField({
    this.key,
    this.value,
  });
}

class LoanItemBloc implements BlocBase {
  final BehaviorSubject<LoanItem> _currentLoanCtrl;

  PublishSubject<String> _titleSubject = PublishSubject<String>();
  Stream<String> get title => _titleSubject.stream;
  // Function(String) get updateTitle => _titleSubject.sink.add;

  PublishSubject<double> _amountSubject = PublishSubject<double>();
  Stream<double> get amount => _amountSubject.stream;

  PublishSubject<double> _roiSubject = PublishSubject<double>();
  Stream<double> get roi => _roiSubject.stream;

  PublishSubject<double> _emiSubject = PublishSubject<double>();
  Stream<double> get emi => _emiSubject.stream;

  PublishSubject<double> _emiPaidSubject = PublishSubject<double>();
  Stream<double> get emiPaid => _emiPaidSubject.stream;

  PublishSubject<int> _termSubject = PublishSubject<int>();
  Stream<int> get term => _termSubject.stream;

  PublishSubject<DateTime> _startDateSubject = PublishSubject<DateTime>();
  Stream<DateTime> get startDate => _startDateSubject.stream;

  // actions to update data
  PublishSubject _actionsSubject = PublishSubject();
  Function(dynamic) get loanItemAction => _actionsSubject.sink.add;

  DocumentReference _fireStore =
      Firestore.instance.collection('loan-tracker').document('LoanTrackerDoc');

  Stream<LoanItem> get currentLoanItem => _currentLoanCtrl.stream;
  Function(LoanItem) get updateCurrentLoanItem => _currentLoanCtrl.sink.add;

  final Map<LoanFieldKey, Subject> _fieldSubjectMap = {};

  final LoanItem loanItem;
  LoanItemBloc({this.loanItem})
      : _currentLoanCtrl = BehaviorSubject<LoanItem>(seedValue: loanItem) {
    _setupActionsListener();
    _setupFieldStreamMap();
    _setupFieldListeners();
  }

  _setupFieldListeners() {
    _fieldSubjectMap.forEach((key, subject) {
      subject.stream.listen((value) {
        if (loanItem.getValue(key) == value) return;
        if (loanItem.setValue(key: key, value: value) == null) return;
        dynamic convertedValue = value;
        if (value.runtimeType == DateTime) {
          final DateTime dateValue = value;
          convertedValue = dateValue.millisecondsSinceEpoch;
        }
        print('updating firestore: $key : $convertedValue');
        loanItem.reference.updateData({
          key.toString().split('.').last: convertedValue,
        }).catchError((err) => subject.sink.addError(err));
      });
    });
    // _titleSubject.stream.listen((title) {
    //   if (title == loanItem.title) return;
    //   print('updating firestore : title : $title');
    //   loanItem.reference.updateData({
    //     'title': title,
    //   }).catchError((err) => _titleSubject.sink.addError(err));
    // });
  }

  _setupActionsListener() {
    _actionsSubject.stream
        .debounce(Duration(milliseconds: 1000))
        .distinct()
        .listen((action) {
      switch (action.runtimeType) {
        case UpdateLoanField:
          _onUpdateLoanField(action);
          break;
      }
    });
  }

  _setupFieldStreamMap() {
    _fieldSubjectMap.putIfAbsent(LoanFieldKey.title, () => _titleSubject);
    _fieldSubjectMap.putIfAbsent(LoanFieldKey.amount, () => _amountSubject);
    _fieldSubjectMap.putIfAbsent(LoanFieldKey.roi, () => _roiSubject);
    _fieldSubjectMap.putIfAbsent(LoanFieldKey.emi, () => _emiSubject);
    _fieldSubjectMap.putIfAbsent(LoanFieldKey.emiPaid, () => _emiPaidSubject);
    _fieldSubjectMap.putIfAbsent(LoanFieldKey.term, () => _termSubject);
    _fieldSubjectMap.putIfAbsent(
        LoanFieldKey.startDate, () => _startDateSubject);
  }

  _onUpdateLoanField(UpdateLoanField action) {
    String validationError = _validateLoanField(
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
      case LoanFieldKey.amount:
      case LoanFieldKey.roi:
      case LoanFieldKey.emi:
      case LoanFieldKey.emiPaid:
        currentSubject.sink.add(double.tryParse(action.value));
        break;
      case LoanFieldKey.startDate:
        currentSubject.sink.add(DateTime.tryParse(action.value));
        break;
      case LoanFieldKey.term:
        currentSubject.sink.add(int.tryParse(action.value));
        break;
      default:
        currentSubject.sink.add(action.value);
    }
  }

  String _validateLoanField({LoanFieldKey key, String value}) {
    String validationError;
    double dblValue;

    //check for mandatory fields
    if (key == LoanFieldKey.title ||
        key == LoanFieldKey.amount ||
        key == LoanFieldKey.roi ||
        key == LoanFieldKey.term ||
        key == LoanFieldKey.startDate) {
      if (value == null || value.trim().isEmpty)
        validationError = '${key.toString().split('.').last} can\'t be empty';
      return validationError;
    }
    switch (key) {
      case LoanFieldKey.title:
        break;
      case LoanFieldKey.amount:
      case LoanFieldKey.emi:
      case LoanFieldKey.emiPaid:
      case LoanFieldKey.roi:
        dblValue = double.tryParse(value);
        if (dblValue == null)
          validationError = 'Not a valid ${key.toString().split('.').last}';
        break;
      case LoanFieldKey.term:
        if (int.tryParse(value) == null)
          validationError = 'Not a valid ${key.toString().split('.').last}';
        break;
      case LoanFieldKey.startDate:
        if (DateTime.tryParse(value) == null)
          validationError = 'Not a valid ${key.toString().split('.').last}';
        break;
      default:
    }
    return validationError;
  }

  @override
  void dispose() {
    _actionsSubject.close();
    _currentLoanCtrl.close();
    _fieldSubjectMap.forEach((_, stream) => stream.close());
  }
}
