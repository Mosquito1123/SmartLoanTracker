import 'package:flutter/material.dart';

import '../bolcs/loan_items_bloc.dart';
import '../bolcs/loan_item_bloc.dart';
import '../widgets/side_drawer.dart';

import '../shared/date_formatter.dart';

class LoanEditPage extends StatefulWidget {
  final LoanItem loanItem;
  LoanEditPage(this.loanItem) {
    print('building LoanEditPage');
  }
  @override
  _LoanEditPageState createState() => _LoanEditPageState(loanItem);
}

class _LoanEditPageState extends State<LoanEditPage> {
  LoanItemBloc loanItemBloc;
  TextEditingController titleCtrl,
      amountCtrl,
      roiCtrl,
      termCtrl,
      startDateCtrl,
      emiCtrl,
      emiPaidCtrl;

  final LoanItem loanItem;
  _LoanEditPageState(this.loanItem);

  @override
  void initState() {
    super.initState();
    print('state init');
    titleCtrl = TextEditingController(text: loanItem.title);
    amountCtrl = TextEditingController(text: loanItem.amount.toString());
    roiCtrl = TextEditingController(text: loanItem.roi.toString());
    termCtrl = TextEditingController(text: loanItem.term.toString());
    startDateCtrl = TextEditingController(
        text: DateFormatter.formatDateM(loanItem.startDate));
    emiCtrl = TextEditingController(text: loanItem.emi.toString());
    emiPaidCtrl = TextEditingController(text: loanItem.emiPaid.toString());
    loanItemBloc = LoanItemBloc(loanItem: loanItem);
  }

  @override
  Widget build(BuildContext context) {
    print('building LoanEditPageState');
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit'),
      ),
      body: _buildLoanForm(context),
      drawer: SideDrawer(),
    );
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
              _selectStartDate(loanItem.startDate);
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

  @override
  void dispose() {
    loanItemBloc.dispose();
    super.dispose();
  }
}
