import 'dart:async';

import 'package:flutter/material.dart';

import '../models/loan_item.dart';
import '../bolcs/loan_rois_bloc.dart';
import '../bolcs/loan_roi_bloc.dart';

import '../shared/date_formatter.dart';

class LoanRoiList extends StatelessWidget {
  LoanRoisBloc bloc;
  TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of(context);
    return WillPopScope(
      child: Column(
        children: <Widget>[
          Expanded(child: _buildList()),
          StreamBuilder<LoanRoi>(
            stream: bloc.currentLoanRoi,
            builder: (BuildContext context, AsyncSnapshot<LoanRoi> snapshot) {
              print(
                  'building loanroi ${snapshot.data?.roi}, ${snapshot.data?.startDate}');
              if (snapshot?.data == null) {
                LoanRoi loanRoi = LoanRoi.fromMap({
                  'roi': 0.0,
                  'startDate': DateTime.now().millisecondsSinceEpoch
                });
                bloc.updateCurrentLoanRoi(loanRoi);
                return Text('loading...');
              }
              return BlocProvider(
                bloc: LoanRoiBloc(
                    loanItem: bloc.loanItem, loanRoi: snapshot.data),
                child: _LoanRoiAdder(
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
    return StreamBuilder<List<LoanRoi>>(
      stream: bloc.loanRoisList,
      builder: (BuildContext context, AsyncSnapshot<List<LoanRoi>> snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text('Loading...');
          default:
            return ListView(
              children: snapshot.data.map((LoanRoi item) {
                return _buildListItem(context, bloc, item);
              }).toList(),
            );
        }
      },
    );
  }

  Widget _buildListItem(BuildContext context, LoanRoisBloc bloc, LoanRoi item) {
    // final item = LoanItem.fromDocSnapshot(document);
    return Dismissible(
      key: Key(item.reference.documentID),
      child: ListTile(
        title: Text('${item.roi}'),
        subtitle: Text(DateFormatter.formatFull(item.startDate)),
        onTap: () {
          bloc.updateCurrentLoanRoi(item);
        },
      ),
      background: Container(
        color: Colors.redAccent,
      ),
      onDismissed: (direction) async {
        await bloc.deleteRoi(item);
        bloc.updateCurrentLoanRoi(LoanRoi.fromMap(
            {'roi': 0.0, 'startDate': DateTime.now().millisecondsSinceEpoch}));
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

class _LoanRoiAdder extends StatefulWidget {
  FocusNode focusNode;
  TextEditingController textEditingController;

  _LoanRoiAdder({this.focusNode, this.textEditingController}) {
// textEditingController.text = loanRoi.roi.toString();
  }

  @override
  _LoanRoiAdderState createState() => _LoanRoiAdderState();
}

class _LoanRoiAdderState extends State<_LoanRoiAdder> {
  FocusNode _focusNode;
  TextEditingController _textEditingController;
  LoanRoiBloc loanRoiBloc;
  LoanRoisBloc loanRoisBloc;

  _LoanRoiAdderState() {}

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _textEditingController = TextEditingController();
    print('loanRoiAdder: initState');
  }

  didChangeDependencies() {
    super.didChangeDependencies();
    loanRoisBloc = BlocProvider.of(context);
    print('loanRoiAdder: didChangeDependencies');
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
      loanRoiBloc.loanRoiAction(UpdateLoanRoiField(
        key: LoanRoiFieldKey.startDate,
        value: stringDate,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    loanRoiBloc = BlocProvider.of(context);

    _textEditingController.text =
        loanRoiBloc.currentLoanRoiValue.roi.toString();

    print('building RoiAdder ');
    // print(
    //     'building RoiAdder ${widget.loanRoi?.roi}, ${widget.loanRoi?.startDate}');
    Widget _buildRoiTextField = StreamBuilder(
      stream: loanRoiBloc.roi,
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
        print('stream builder loan roi ${snapshot?.data}');
        // _textEditingController.text = snapshot?.data.toString();
        return TextField(
          focusNode: _focusNode,
          controller: _textEditingController,
          onChanged: (value) {
            loanRoiBloc.loanRoiAction(UpdateLoanRoiField(
              key: LoanRoiFieldKey.roi,
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
        stream: loanRoiBloc.startDate,
        builder: (BuildContext context, AsyncSnapshot<DateTime> snapshot) {
          print('stream builder loan roi startDate ${snapshot?.data}');
          return FlatButton(
            child: Text(DateFormatter.safeFormatDateM(snapshot?.data)),
            // child: Text('test'),
            onPressed: () {
              _selectStartDate(snapshot?.data);
            },
          );
        });
    Widget _buildLoanRoiForm = Row(
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
          children: loanRoiBloc.loanRoi.reference == null
              ? <Widget>[
                  const SizedBox(width: 16.0),
                  Text('Please select an Item for Update/Copy'),
                ]
              : <Widget>[
                  const SizedBox(width: 16.0),
                  Expanded(child: _buildLoanRoiForm),
                  // const SizedBox(width: 8.0),
                  Material(
                    child: IconButton(
                      color: Theme.of(context).primaryColor,
                      icon: Icon(
                        Icons.content_copy,
                        semanticLabel: 'Copy New',
                      ),
                      onPressed: () {
                        loanRoiBloc.createLoanRoi(null);
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
    // loanRoiBloc.dispose();
  }
}
