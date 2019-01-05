import 'package:cloud_firestore/cloud_firestore.dart';

class LoanItem {
  double amount, emi, roi;
  String id, title;
  int startDate, term;
  final DocumentReference reference;

  LoanItem.fromDocSnapshot(DocumentSnapshot document)
      : this.fromMap(document.data, reference: document.reference);

  LoanItem.fromMap(Map<String, dynamic> map, {this.reference}) {
    id = map['id'];
    amount = map['amount'].toDouble();
    emi = map['emi'].toDouble();
    roi = map['roi'].toDouble();
    title = map['title'];
    startDate = map['startDate'];
    term = map['term'];
  }
}
