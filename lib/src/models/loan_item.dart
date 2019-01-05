import 'package:cloud_firestore/cloud_firestore.dart';

enum LoanFieldKey {
  id,
  title,
  amount,
  roi,
  term,
  startDate,
  emi,
  emiPaid,
}

class LoanItem {
  double amount, emi, roi, emiPaid;
  String id, title;
  int term;
  DateTime startDate;
  final DocumentReference reference;

  LoanItem.fromDocSnapshot(DocumentSnapshot document)
      : this.fromMap(document.data, reference: document.reference);

  LoanItem.fromMap(Map<String, dynamic> map, {this.reference}) {
    id = map['id'];
    amount = map['amount'].toDouble();
    emi = map['emi'].toDouble();
    emiPaid = map['emiPaid'].toDouble();
    roi = map['roi'].toDouble();
    title = map['title'];
    startDate = DateTime.fromMillisecondsSinceEpoch(map['startDate']);
    term = map['term'];
  }

  dynamic getValue(LoanFieldKey key) {
    switch (key) {
      case LoanFieldKey.id:
        return id;
      case LoanFieldKey.amount:
        return amount;
      case LoanFieldKey.emi:
        return emi;
      case LoanFieldKey.emiPaid:
        return emiPaid;
      case LoanFieldKey.roi:
        return roi;
      case LoanFieldKey.title:
        return title;
      case LoanFieldKey.startDate:
        return startDate;
      case LoanFieldKey.term:
        return term;
      default:
        return null;
    }
  }

  LoanFieldKey setValue({LoanFieldKey key, dynamic value}) {
    switch (key) {
      case LoanFieldKey.id:
        id = value;
        break;
      case LoanFieldKey.amount:
        amount = value;
        break;
      case LoanFieldKey.emi:
        emi = value;
        break;
      case LoanFieldKey.emiPaid:
        emiPaid = value;
        break;
      case LoanFieldKey.roi:
        roi = value;
        break;
      case LoanFieldKey.title:
        title = value;
        break;
      case LoanFieldKey.startDate:
        startDate = value;
        break;
      case LoanFieldKey.term:
        term = value;
        break;
      default:
        return null;
    }
    return key;
  }
}
