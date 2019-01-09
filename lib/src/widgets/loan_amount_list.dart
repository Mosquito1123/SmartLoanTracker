import 'dart:async';

import 'package:flutter/material.dart';

import '../bolcs/loan_amounts_bloc.dart';
import '../bolcs/loan_amount_bloc.dart';

import '../shared/date_formatter.dart';

class LoanAmountList extends StatelessWidget {
  LoanAmountsBloc bloc;
  TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of(context);
    return WillPopScope(
      child: Column(
        children: <Widget>[
          Expanded(child: _buildList()),
          StreamBuilder<LoanAmount>(
            stream: bloc.currentLoanAmount,
            builder:
                (BuildContext context, AsyncSnapshot<LoanAmount> snapshot) {
              print(
                  'building loanamount ${snapshot.data?.amount}, ${snapshot.data?.date}');
              if (snapshot?.data == null) {
                LoanAmount loanAmount = LoanAmount.fromMap({
                  'amount': 0.0,
                  'date': DateFormatter.formatFullWithFormat(
                      DateTime.now(), LoanAmount.dateFormat),
                });
                bloc.updateCurrentLoanAmount(loanAmount);
                return Text('loading...');
              }
              return BlocProvider(
                bloc: LoanAmountBloc(
                    loanItem: bloc.loanItem, loanAmount: snapshot.data),
                child: _LoanAmountAdder(
                  focusNode: FocusNode(),
                ),
              );
            },
          ),
        ],
      ),
      onWillPop: () {
        Navigator.pop(context);
        Future.value(false);
      },
    );
  }

  Widget _buildList() {
    return StreamBuilder<List<LoanAmount>>(
      stream: bloc.loanAmountsList,
      builder:
          (BuildContext context, AsyncSnapshot<List<LoanAmount>> snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text('Loading...');
          default:
            return ListView(
              children: snapshot.data.map((LoanAmount item) {
                return _buildListItem(context, bloc, item);
              }).toList(),
            );
        }
      },
    );
  }

  Widget _buildListItem(
      BuildContext context, LoanAmountsBloc bloc, LoanAmount item) {
    // final item = LoanItem.fromDocSnapshot(document);
    return Dismissible(
      key: Key(item.reference.documentID),
      child: ListTile(
        title: Text('${item.amount}'),
        subtitle: Text(DateFormatter.formatFull(item.date)),
        onTap: () {
          bloc.updateCurrentLoanAmount(item);
        },
      ),
      background: Container(
        color: Colors.redAccent,
      ),
      onDismissed: (direction) async {
        await bloc.deleteRoi(item);
        bloc.updateCurrentLoanAmount(LoanAmount.fromMap({
          'amount': 0.0,
          'date': DateFormatter.formatFullWithFormat(
              DateTime.now(), LoanAmount.dateFormat),
        }));
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Item Deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              bloc.undoDeleteRoi(item);
            },
          ),
        ));
      },
    );
  }
}

class _LoanAmountAdder extends StatefulWidget {
  FocusNode focusNode;
  TextEditingController textEditingController;

  _LoanAmountAdder({this.focusNode, this.textEditingController}) {
// textEditingController.text = loanAmount.amount.toString();
  }

  @override
  _LoanAmountAdderState createState() => _LoanAmountAdderState();
}

class _LoanAmountAdderState extends State<_LoanAmountAdder> {
  FocusNode _focusNode;
  TextEditingController _textEditingController;
  LoanAmountBloc loanAmountBloc;
  LoanAmountsBloc loanAmountsBloc;

  _LoanAmountAdderState() {}

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _textEditingController = TextEditingController();
    print('loanAmountAdder: initState');
  }

  didChangeDependencies() {
    super.didChangeDependencies();
    loanAmountsBloc = BlocProvider.of(context);
    print('loanAmountAdder: didChangeDependencies');
  }

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
      loanAmountBloc.loanAmountAction(UpdateLoanAmountField(
        key: LoanAmountFieldKey.date,
        value: stringDate,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    loanAmountBloc = BlocProvider.of(context);

    _textEditingController.text =
        loanAmountBloc.currentLoanAmountValue.amount.toString();

    print('building RoiAdder ');
    // print(
    //     'building RoiAdder ${widget.loanAmount?.amount}, ${widget.loanAmount?.date}');
    Widget _buildRoiTextField = StreamBuilder(
      stream: loanAmountBloc.amount,
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
        print('stream builder loan amount ${snapshot?.data}');
        // _textEditingController.text = snapshot?.data.toString();
        return TextField(
          focusNode: _focusNode,
          controller: _textEditingController,
          onChanged: (value) {
            loanAmountBloc.loanAmountAction(UpdateLoanAmountField(
              key: LoanAmountFieldKey.amount,
              value: value,
            ));
          },
          decoration: InputDecoration(
            labelText: 'Interest Rate',
            errorText: snapshot?.error,
          ),
        );
      },
    );
    Widget _buildRoiDateField = StreamBuilder(
        stream: loanAmountBloc.date,
        builder: (BuildContext context, AsyncSnapshot<DateTime> snapshot) {
          print('stream builder loan amount date ${snapshot?.data}');
          return FlatButton(
            child: Text(DateFormatter.safeFormatDateM(snapshot?.data)),
            // child: Text('test'),
            onPressed: () {
              _selectStartDate(snapshot?.data);
            },
          );
        });
    Widget _buildLoanAmountForm = Row(
      children: <Widget>[
        Expanded(
          child: _buildRoiTextField,
        ),
        const SizedBox(width: 8.0),
        _buildRoiDateField,
      ],
    );
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 10.0)]),
      child: SizedBox(
        height: 64.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: loanAmountBloc.loanAmount.reference == null
              ? <Widget>[
                  const SizedBox(width: 16.0),
                  Text('Please select an Item for Update/Copy'),
                ]
              : <Widget>[
                  const SizedBox(width: 16.0),
                  Expanded(child: _buildLoanAmountForm),
                  // const SizedBox(width: 8.0),
                  Material(
                    child: IconButton(
                      color: Theme.of(context).primaryColor,
                      icon: Icon(
                        Icons.content_copy,
                        semanticLabel: 'Copy New',
                      ),
                      onPressed: () {
                        loanAmountBloc.createLoanAmount(null);
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    print('disposing RoiAdder');
    // loanAmountBloc.dispose();
  }
}
