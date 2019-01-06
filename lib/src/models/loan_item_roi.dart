import 'package:cloud_firestore/cloud_firestore.dart';

enum LoanRoiFieldKey {
  id,
  roi,
  startDate,
}

class LoanItemRoi {
  double roi;
  String id;
  DateTime startDate;
  final DocumentReference reference;

  LoanItemRoi.fromDocSnapshot(DocumentSnapshot document)
      : this.fromMap(document.data, reference: document.reference);

  LoanItemRoi.fromMap(Map<String, dynamic> map, {this.reference}) {
    id = map['id'];
    roi = map['roi'].toDouble();
    startDate = DateTime.fromMillisecondsSinceEpoch(map['startDate']);
  }

  dynamic getValue(LoanRoiFieldKey key) {
    switch (key) {
      case LoanRoiFieldKey.id:
        return id;
      case LoanRoiFieldKey.roi:
        return roi;
      case LoanRoiFieldKey.startDate:
        return startDate;
      default:
        return null;
    }
  }

  LoanRoiFieldKey setValue({LoanRoiFieldKey key, dynamic value}) {
    switch (key) {
      case LoanRoiFieldKey.id:
        id = value;
        break;
      case LoanRoiFieldKey.roi:
        roi = value;
        break;
      case LoanRoiFieldKey.startDate:
        startDate = value;
        break;
      default:
        return null;
    }
    return key;
  }
}
