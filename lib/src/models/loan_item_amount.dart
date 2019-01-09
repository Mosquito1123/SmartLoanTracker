import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/date_formatter.dart';

enum LoanAmountFieldKey {
  id,
  amount,
  date,
}

class LoanAmount {
  static const String dateFormat = 'y-M-d';

  double amount;
  String id;
  DateTime date;
  final DocumentReference reference;

  LoanAmount.fromDocSnapshot(DocumentSnapshot document)
      : this.fromMap(document.data, reference: document.reference);

  LoanAmount.fromMap(Map<String, dynamic> map, {this.reference}) {
    id = map['id'];
    amount = map['amount'].toDouble();
    date = DateFormatter.parseDateWithFormat(map['date'], dateFormat);
  }

  dynamic getValue(LoanAmountFieldKey key) {
    switch (key) {
      case LoanAmountFieldKey.id:
        return id;
      case LoanAmountFieldKey.amount:
        return amount;
      case LoanAmountFieldKey.date:
        return date;
      default:
        return null;
    }
  }

  LoanAmountFieldKey setValue({LoanAmountFieldKey key, dynamic value}) {
    switch (key) {
      case LoanAmountFieldKey.id:
        id = value;
        break;
      case LoanAmountFieldKey.amount:
        amount = value;
        break;
      case LoanAmountFieldKey.date:
        date = value;
        break;
      default:
        return null;
    }
    return key;
  }
}
