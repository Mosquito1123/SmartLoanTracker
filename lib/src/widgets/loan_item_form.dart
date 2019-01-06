import 'package:flutter/material.dart';

import '../bolcs/loan_items_bloc.dart';
import '../bolcs/loan_item_bloc.dart';

import '../shared/date_formatter.dart';

class LoanItemForm extends StatefulWidget {
  final LoanItem loanItem;

  LoanItemForm({this.loanItem});

  @override
  _LoanItemFormState createState() => _LoanItemFormState();
}

class _LoanItemFormState extends State<LoanItemForm> {
  TextEditingController titleCtrl,
      amountCtrl,
      roiCtrl,
      termCtrl,
      startDateCtrl,
      emiCtrl,
      emiPaidCtrl;
  LoanItemBloc loanItemBloc;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.loanItem.title);
    amountCtrl = TextEditingController(text: widget.loanItem.amount.toString());
    roiCtrl = TextEditingController(text: widget.loanItem.roi.toString());
    termCtrl = TextEditingController(text: widget.loanItem.term.toString());
    startDateCtrl = TextEditingController(
        text: DateFormatter.formatDateM(widget.loanItem.startDate));
    emiCtrl = TextEditingController(text: widget.loanItem.emi.toString());
    emiPaidCtrl =
        TextEditingController(text: widget.loanItem.emiPaid.toString());
  }

  @override
  Widget build(BuildContext context) {
    loanItemBloc = BlocProvider.of(context);
    return _buildLoanForm(context);
  }

  Widget _buildLoanForm(BuildContext context) {
    final Widget _buildTitleField = StreamBuilder(
      stream: loanItemBloc.title,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) =>
          TextField(
            controller: titleCtrl,
            onChanged: (value) => loanItemBloc?.loanItemAction(UpdateLoanField(
                  key: LoanFieldKey.title,
                  value: value,
                )),
            decoration: InputDecoration(
              labelText: 'Title',
              errorText: snapshot?.error,
            ),
          ),
    );

    final Widget _buildAmountField = StreamBuilder(
      stream: loanItemBloc.amount,
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) =>
          TextField(
            controller: amountCtrl,
            onChanged: (value) => loanItemBloc?.loanItemAction(UpdateLoanField(
                  key: LoanFieldKey.amount,
                  value: value,
                )),
            decoration: InputDecoration(
              labelText: 'Amount',
              errorText: snapshot?.error,
            ),
          ),
    );

    final Widget _buildInterestRateField = StreamBuilder(
      stream: loanItemBloc.roi,
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) =>
          TextField(
            controller: roiCtrl,
            onChanged: (value) => loanItemBloc?.loanItemAction(UpdateLoanField(
                  key: LoanFieldKey.roi,
                  value: value,
                )),
            decoration: InputDecoration(
              labelText: 'InterestRate',
              errorText: snapshot?.error,
            ),
          ),
    );

    final Widget _buildTermField = StreamBuilder(
      stream: loanItemBloc.term,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) => TextField(
            controller: termCtrl,
            onChanged: (value) => loanItemBloc?.loanItemAction(UpdateLoanField(
                  key: LoanFieldKey.term,
                  value: value,
                )),
            decoration: InputDecoration(
              labelText: 'Term',
              errorText: snapshot?.error,
            ),
          ),
    );

    Future _selectStartDate(date) async {
      final DateTime currentDate = DateTime.now();
      DateTime picked = await showDatePicker(
        context: context,
        initialDate: date ?? currentDate,
        firstDate: new DateTime(2000),
        lastDate: new DateTime(currentDate.year + 10),
      );
      if (picked != null) {
        final stringDate = DateFormatter.formatDateM(picked);
        loanItemBloc?.loanItemAction(UpdateLoanField(
          key: LoanFieldKey.startDate,
          value: stringDate,
        ));
        startDateCtrl.text = stringDate;
      }
    }

    final Widget _buildStartDateField = StreamBuilder(
      stream: loanItemBloc.startDate,
      builder: (BuildContext context, AsyncSnapshot<DateTime> snapshot) =>
          GestureDetector(
            onTap: () {
              _selectStartDate(snapshot?.data);
            },
            child: AbsorbPointer(
              child: TextField(
                controller: startDateCtrl,
                decoration: InputDecoration(
                  labelText: 'StartDate',
                  errorText: snapshot?.error,
                ),
              ),
            ),
          ),
    );

    final Widget _buildActualEMIField = StreamBuilder(
      stream: loanItemBloc.emi,
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) =>
          TextField(
            controller: emiCtrl,
            onChanged: (value) => loanItemBloc?.loanItemAction(UpdateLoanField(
                  key: LoanFieldKey.emi,
                  value: value,
                )),
            decoration: InputDecoration(
              labelText: 'ActualEMI',
              errorText: snapshot?.error,
            ),
          ),
    );

    final Widget _buildPaidEMIField = StreamBuilder(
      stream: loanItemBloc.emiPaid,
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) =>
          TextField(
            controller: emiPaidCtrl,
            onChanged: (value) => loanItemBloc?.loanItemAction(UpdateLoanField(
                  key: LoanFieldKey.emiPaid,
                  value: value,
                )),
            decoration: InputDecoration(
              labelText: 'PaidEMI',
              errorText: snapshot?.error,
            ),
          ),
    );

    return ListView(
      children: <Widget>[
        _buildTitleField,
        _buildAmountField,
        _buildInterestRateField,
        _buildTermField,
        _buildStartDateField,
        _buildActualEMIField,
        _buildPaidEMIField,
      ],
    );
  }
}
