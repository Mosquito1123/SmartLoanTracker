import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import './bloc_provider.dart';
export './bloc_provider.dart';
import '../models/loan_item.dart';
import '../models/loan_item_roi.dart';
export '../models/loan_item.dart';
export '../models/loan_item_roi.dart';

import '../shared/date_formatter.dart';

class UpdateLoanRoiField {
  final LoanRoiFieldKey key;
  final String value;

  const UpdateLoanRoiField({
    this.key,
    this.value,
  });
}

class LoanRoiBloc implements BlocBase {
  final BehaviorSubject<LoanItem> _currentLoanCtrl;
  final BehaviorSubject<LoanRoi> _currentLoanRoiCtrl;

  BehaviorSubject<double> _roiSubject;
  Stream<double> get roi => _roiSubject.stream;

  BehaviorSubject<DateTime> _startDateSubject;
  Stream<DateTime> get startDate => _startDateSubject.stream;
  DateTime get startDateValue => _startDateSubject.value;

  // actions to update data
  PublishSubject _actionsSubject = PublishSubject();
  Function(dynamic) get loanRoiAction => _actionsSubject.sink.add;

  DocumentReference _fireStore =
      Firestore.instance.collection('loan-tracker').document('LoanTrackerDoc');

  Stream<LoanItem> get currentLoan => _currentLoanCtrl.stream;
  Function(LoanItem) get updateCurrentLoan => _currentLoanCtrl.sink.add;

  Stream<LoanRoi> get currentLoanRoi => _currentLoanRoiCtrl.stream;
  LoanRoi get currentLoanRoiValue => _currentLoanRoiCtrl.value;
  Function(LoanRoi) get updateCurrentLoanRoi => _currentLoanRoiCtrl.sink.add;

  PublishSubject<void> _createRoiSubject = PublishSubject<void>();
  // Stream<void> get loanRoiCreated => _createRoiSubject.stream;
  Function(void) get createLoanRoi => _createRoiSubject.sink.add;

  final Map<LoanRoiFieldKey, Subject> _fieldSubjectMap = {};

  final LoanItem loanItem;
  final LoanRoi loanRoi;
  LoanRoiBloc({@required this.loanItem, @required this.loanRoi})
      : assert(loanItem != null),
        assert(loanRoi != null),
        _currentLoanCtrl = BehaviorSubject<LoanItem>(seedValue: loanItem),
        _currentLoanRoiCtrl = BehaviorSubject<LoanRoi>(seedValue: loanRoi),
        _startDateSubject =
            BehaviorSubject<DateTime>(seedValue: loanRoi.startDate),
        _roiSubject = BehaviorSubject<double>(seedValue: loanRoi.roi) {
    _setupActionsListener();
    _setupFieldStreamMap();
    _setupFieldListeners();
  }

  _setupFieldListeners() {
    _currentLoanRoiCtrl.listen((loanRoi) {
      _roiSubject.add(loanRoi.roi);
      _startDateSubject.add(loanRoi.startDate);
    });
    _fieldSubjectMap.forEach((key, subject) {
      subject.stream.listen((value) {
        LoanRoi loanRoi = _currentLoanRoiCtrl.value;
        if (loanRoi.reference == null) return;
        if (loanRoi.getValue(key) == value) return;
        if (loanRoi.setValue(key: key, value: value) == null) return;
        dynamic convertedValue = value;
        if (value.runtimeType == DateTime) {
          final DateTime dateValue = value;
          convertedValue = dateValue.millisecondsSinceEpoch;
        }
        print('updating firestore: $key : $convertedValue');
        loanRoi.reference.updateData({
          key.toString().split('.').last: convertedValue,
        }).catchError((err) => subject.sink.addError(err));
      });
    });
  }

  _setupActionsListener() {
    _createRoiSubject.listen((_) {
      // final LoanRoi loanRoi = _currentLoanRoiCtrl.value;
      // if (loanRoi.reference != null) return; //not a new ROI
      _fireStore
          .collection('loans')
          .document(loanItem.reference.documentID)
          .collection('rois')
          .reference()
          .add({
        'roi': _roiSubject.value,
        'startDate': _startDateSubject.value.millisecondsSinceEpoch
      });
    });
    _actionsSubject.stream
        .debounce(Duration(milliseconds: 1000))
        .distinct()
        .listen((action) {
      switch (action.runtimeType) {
        case UpdateLoanRoiField:
          _onUpdateLoanRoiField(action);
          break;
      }
    });
  }

  _setupFieldStreamMap() {
    _fieldSubjectMap.putIfAbsent(LoanRoiFieldKey.roi, () => _roiSubject);
    _fieldSubjectMap.putIfAbsent(
        LoanRoiFieldKey.startDate, () => _startDateSubject);
  }

  _onUpdateLoanRoiField(UpdateLoanRoiField action) {
    String validationError = _validateLoanRoiField(
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
      case LoanRoiFieldKey.roi:
        currentSubject.sink.add(double.tryParse(action.value));
        break;
      case LoanRoiFieldKey.startDate:
        currentSubject.sink.add(DateFormatter.parseDateM(action.value));
        break;
      default:
        currentSubject.sink.add(action.value);
    }
  }

  String _validateLoanRoiField({LoanRoiFieldKey key, String value}) {
    String validationError;
    double dblValue;

    //check for mandatory fields
    if (key == LoanRoiFieldKey.roi || key == LoanRoiFieldKey.startDate) {
      if (value == null || value.trim().isEmpty)
        validationError = '${key.toString().split('.').last} can\'t be empty';
      return validationError;
    }
    switch (key) {
      case LoanRoiFieldKey.roi:
        dblValue = double.tryParse(value);
        if (dblValue == null)
          validationError = 'Not a valid ${key.toString().split('.').last}';
        break;
      case LoanRoiFieldKey.startDate:
        if (DateTime.tryParse(value) == null)
          validationError = 'Not a valid ${key.toString().split('.').last}';
        break;
      default:
    }
    return validationError;
  }

  @override
  void dispose() {
    print('disposing:LoanRoi bloc');
    _actionsSubject.close();
    _currentLoanCtrl.close();
    _createRoiSubject.close();
    _fieldSubjectMap.forEach((_, stream) => stream.close());
  }
}
